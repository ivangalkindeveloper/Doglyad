# Doglyad — AI-ассистент для анализа УЗИ-исследований
Проект представляет собой AI-ассистента, который анализирует ультразвуковые снимки вместе с описанием анамнеза пациентов и генерирует медицинское заключение.

## Архитектура
Бэкенд разделён на два разворачиваемых по отдельности сервиса: `backend/main` и `backend/inference`.

- **Главный бэкенд** (`backend/main/`) — Python, FastAPI, Docker. Живёт на **не-GPU-виртуалке** и сам инференс не делает: собирает промпт, выбирает модель и маршрутизирует запрос. Отправка заключений на email через SMTP.
- **Сервис инференса** (`backend/inference/`) — Python, FastAPI, Docker. Разворачивается **на GPU-виртуалке** (одна виртуалка на модель) рядом с локальным vLLM и самой моделью. Проверяет App Check и генерирует заключение.
- **iOS-приложение** — SwiftUI, MVVM, SwiftData, Alamofire, MLX (on-device инференс), Firebase, RevenueCat (подписки).

Путь одного запроса на генерацию заключения:

```
iOS ──► backend/main (не-GPU) ──► backend/inference + vllm (GPU-виртуалка модели)
```

App Check проверяется **дважды**: на входе в систему (`backend/main`) и ещё раз на машине с моделью (`backend/inference`). Токен из заголовка `X-Firebase-AppCheck` перекладывается в исходящий запрос без изменений, так что оба раза проверяется один и тот же токен.

Проверка на главном бэкенде защищает внешний вход в систему, а повторная проверка не позволяет обращаться к GPU-виртуалке напрямую в обход главного бэкенда. Обе группы виртуальных машин находятся под контролем разработчика.

Отключить проверку нечем — ни флага, ни режима: закрыт весь роутер `/v1` в любом окружении.

Вне `/v1` живут только ручки конфигов (`/application_config` и три `ultrasound_examination_*`). Они открыты намеренно: приложение читает их до того, как ему есть чем аутентифицироваться, а содержимое публично по природе — до переезда на бэкенд оно лежало в открытом репозитории. Они же служат инфраструктуре проверкой живости.

### Окружения
`ENVIRONMENT` (`development` / `production`) выбирает каталог конфигов в `backend/main/config/` — и больше ничего. Приложение читает те же документы через ручки этого бэкенда, а не из репозитория: иначе пуш новой модели в `master` делал её видимой приложению сразу, а бэкенд узнавал о ней только после выкатки — и врач получал `400`. Оба окружения ходят в сервис инференса по одному и тому же пути и с той же проверкой токена. Именно поэтому проверка на development-стенде что-то значит: это тот же код на том же маршруте, отличаются только список моделей, типы исследований и настройки приложения.

### Таймауты
Вложены строго снаружи внутрь, каждый слой шире того, который оборачивает:

```
iOS-клиент                   300  application.json -> network.timeoutIntervalForRequest
INFERENCE_REQUEST_TIMEOUT    130  главный бэкенд ждёт GPU-виртуалку
VLLM_REQUEST_TIMEOUT         120  виртуалка ждёт свой локальный движок
```

Внутренний таймаут меньше внешнего — иначе вызывающий разорвёт соединение во время генерации, которая ещё выполняется.

Для каждой опубликованной модели в `backend/main/secrets/inference_endpoints.json` должна существовать запись с URL соответствующей GPU-виртуалки. Отсутствие записи является ошибкой конфигурации.

## Навигация по коду
### `backend/main/` — Главный бэкенд
| Путь | Описание |
|---|---|
| `backend/main/app/main.py` | FastAPI-приложение, lifespan (загрузка конфигов, создание `httpx.AsyncClient`, инициализация сервисов), закрытый App Check роутер `/v1` и открытый роутер конфигов рядом с ним, rate limiter |
| `backend/main/app/route/ultrasound_conclusion.py` | Эндпоинт `POST /v1/ultrasound_conclusion` — принимает данные исследования, вызывает `ModelService`, пробрасывает в него токен App Check, возвращает заключение |
| `backend/main/app/route/ultrasound_conclusion_send_email.py` | Эндпоинт `POST /v1/ultrasound_conclusion_send_email` — отправка заключения на email через SMTP (`smtplib`) |
| `backend/main/app/route/application_config.py` | Четыре ручки конфигов для приложения — `/application_config`, `/ultrasound_examination_types`, `/ultrasound_examination_neural_models`, `/ultrasound_examination_contextual_strings`. **Вне `/v1`**, то есть без App Check. Отдают файл из образа исходным текстом, без `response_model`: описывать всё дерево конфигов моделями значило бы завести второе место, где оно разъезжается с JSON |
| `backend/main/app/core/variables.py` | Переменные окружения через `pydantic_settings` (`Variables`): `ENVIRONMENT`, `FIREBASE_CREDENTIALS_PATH`, `EMAIL_*`, `INFERENCE_ENDPOINTS_PATH`, таймауты, читаются в т.ч. из `backend/main/secrets/.env` |
| `backend/main/app/core/app_check.py` | Проверка App Check на входе в систему. `APP_CHECK_HEADER`, `init_app_check` и зависимость `verify_app_check`, висящая на роутере `/v1`. Безусловна: без учётных данных Firebase бэкенд не стартует |
| `backend/main/app/core/config.py` | Загрузка конфигов при старте: нейромодели и типы исследований разбираются в объекты, а `SERVED_DOCUMENTS` читаются ещё и текстом — их отдаёт приложению `resolve_config_document`. Плюс резолверы моделей и заголовков |
| `backend/main/app/service/` | Слой инференса. Контракт `ModelService` и запрос `InferenceRequest` (`base.py`), реализация `InferenceService` (`inference.py`). `create_model_service()` (`factory.py`) создаёт сервис один раз в lifespan и кладёт его в `app.state.model_service`; роут просто вызывает его |
| `backend/main/app/model/` | Pydantic-модели — `neural_model_settings.py`, `inference_response.py`, подпакет `ultrasound/` (request/data/conclusion/email/scan_photo/type/neural_model) |
| `backend/main/secrets/inference_endpoints.json` | Карта `modelId -> URL` GPU-виртуалок (путь в `INFERENCE_ENDPOINTS_PATH`). Ведётся вручную: по одной записи на виртуалку. В git не хранится |
| `backend/main/app/prompt/` | Генерация промптов — `base.py` (`PromptFactory`), локализации `ru.py`/`en.py`, `resolve_prompt_factory` в `__init__.py` |
| `backend/main/config/` | JSON-конфиги по окружениям (`development/`, `production/`): `application.json`, `ultrasound_examination_neural_models.json`, `ultrasound_examination_types.json`, `ultrasound_examination_contextual_strings.json`. Читаются бэкендом при старте и **отдаются приложению** через `app/route/application_config.py`. Запечены в образ, см. `backend/main/Dockerfile` |
| `backend/main/docker-compose.yml` | Docker Compose — читает `backend/main/secrets/.env` + профильный `secrets/.env.<профиль>` (выбор через `ENV_FILE`), монтирует только `./secrets` и `./logs`: конфиги запечены в образ |

### `backend/inference/` — сервис инференса
Разворачивается на GPU-виртуалке, по одной виртуалке на модель. Полное описание и инструкция по развёртыванию — в [`backend/inference/README.md`](backend/inference/README.md).

| Путь | Описание |
|---|---|
| `backend/inference/app/main.py` | FastAPI-приложение, lifespan (`httpx.AsyncClient`, App Check, сервис vLLM), единственный роутер `/v1` целиком под App Check — неаутентифицированных ручек у сервиса нет |
| `backend/inference/app/route/conclusion_generation.py` | Эндпоинт `POST /v1/conclusion_generation` — принимает готовые промпты и снимки, возвращает текст заключения |
| `backend/inference/app/service/vllm.py` | `VLLMService` — запрос к локальному vLLM по OpenAI-совместимому `/v1/chat/completions`; сверяет `modelId` с `SERVED_MODEL_ID` |
| `backend/inference/app/core/app_check.py` | Вторая проверка App Check — на машине с моделью. `init_app_check` + зависимость `verify_app_check` на роутере `/v1`. **Безусловна**: без учётных данных Firebase сервис не стартует, отключить проверку нечем |
| `backend/inference/app/core/variables.py` | `FIREBASE_CREDENTIALS_PATH`, `SERVED_MODEL_ID`, `VLLM_*`. `ENVIRONMENT` здесь нет: конфигов по окружениям у этого сервиса не бывает |
| `backend/inference/docker-compose.yml` | Два контейнера: `vllm` (образ модели, GPU) и `inference_backend` (сам сервис). Требует запуска с `--env-file secrets/.env` — см. `make start-backend-inference` |

### `ios/` — iOS-приложение
| Путь | Описание |
|---|---|
| `ios/Doglyad/Application/Application/` | Точка входа `Application.swift`, `ApplicationViewModel`, корневые вью (`MainRootView`, `ErrorRootView`), роутер (`DRouter`, `RouteType`). |
| `ios/Doglyad/Application/Component/` | Переиспользуемые UI-компоненты уровня приложения, а не на уровне дизайн-системы. |
| `ios/Doglyad/Application/Module/` | Экраны и вьюмодели — каждый модуль содержит `*Screen.swift`, `*ScreenView.swift`, `*ViewModel.swift`, `*Arguments.swift`. Модули: `Scan`, `ScanSpeech`, `Select` (тип исследования / нейромодель / дата рождения), `Conclusion`, `RecievedConclusion`, `History`, `Storage`, `Template`, `Settings`, `UserSettings`, `NeuralModel`, `Subscription` (`Paywall`, `CustomerCenter`), `LimitExceeded`, `Share`, `OnBoarding`, `Permission`, `NewVersion`, `WebDocument`, `About` |
| `ios/Doglyad/Core/DependencyContainer.swift` | DI-контейнер — хранит все зависимости приложения (репозитории, менеджеры, конфиги, нейромодель, начальный экран/статус подписки) |
| `ios/Doglyad/Core/Initialization/` | Процесс инициализации через `DependencyInitializer` (пакет). `InitializationProcess` наполняется набором `StepSet` — `stepsTier1…stepsTier5` (`Steps/InitializationStepsTier*.swift`), каждый со `sync`/`async`-шагами; в конце `toContainer` собирает `DependencyContainer` |
| `ios/Doglyad/Core/Environment/` | `EnvironmentProtocol`, `EnvironmentType` — конфигурация окружения (dev/prod) |
| `ios/Doglyad/Domain/` | Доменные модели: `Ultrasound/` (`USExaminationType`, `USExaminationNeuralModel`, `USExaminationRequest`, `USExaminationConclusion`, `USExaminationEmail` и др.), `Config/` (`ApplicationConfig`, `NetworkConfig`, `UltrasoundConfig`, `Version`), `Subscription/` (`SubscriptionConfig`), `NeuralModelSettings`, `PatientGender` |
| `ios/Doglyad/Repository/` | Репозитории (протокол + реализация): `Conclusion`, `Model`, `Shared`, `Subscription` (`RevenueCatSubscriptionRepository`), `Template`, `UserSettings` |
| `ios/Doglyad/Utility/` | Расширения (`Extension/`), модификаторы (`Modifier/`), менеджеры (`Manager/` — `PermissionManager`, `ConnectionManager`) |
| `ios/Doglyad/Resources/Localizable.xcstrings` | Локализация |
| `ios/DoglyadUI/` | Дизайн-система: тема (`DTheme`), шрифты (Montserrat), компоненты (`DSegment`, `DCloseButton`, `DButtonCard`, `DMessage`) |
| `ios/DoglyadDatabase/` | SwiftData БД — `DDatabase`, сущности (`*DB.swift`), UserDefaults-обёртки |
| `ios/DoglyadNetwork/` | HTTP-клиент на Alamofire — `DHttpClientProtocol`, `DHttpClient`, `DHttpHeader`, `DHttpError` |
| `ios/DoglyadNeuralModel/` | Интеграция ML-моделей (MLX, Foundation Models) |
| `ios/DoglyadCamera/` | Камера — `DCameraController`, `DCameraView` |
| `ios/DoglyadSpeech/` | Распознавание речи — `DSpeechController` |
| `ios/Config/` | Конфигурация сборки: `Config.Development.xcconfig` и `Config.Production.xcconfig` (`ENVIRONMENT`, `BASE_URL`, `REVENUECAT_API_KEY`) — по одному на одноимённую конфигурацию Xcode. Окружение выбирается схемой (`Doglyad-Development` / `Doglyad-Production`), файлы не копируются и не подменяются |
| `ios/Firebase/` | Конфигурации Firebase по окружениям: `Development/GoogleService-Info.plist` и `Production/GoogleService-Info.plist`. Нужный кладётся в бандл Run Script-фазой по `$CONFIGURATION`; в репозитории не хранятся |

## Стиль кода
### Python (Бэкенд)
- **Фреймворк**: FastAPI с Pydantic-моделями.
- **Типизация**: `from __future__ import annotations`, аннотации типов везде.
- **Именование**: snake_case для функций и переменных, CamelCase для классов и Pydantic-моделей. camelCase в Pydantic-полях (совместимость с iOS).
- **Асинхронность**: `async/await` для обработчиков и HTTP-запросов (общий `httpx.AsyncClient` из `app.state`, создаётся в lifespan).
- **Конфигурация**: переменные окружения через `pydantic_settings` (`app/core/variables.py`), значения из `backend/main/secrets/.env`.
- **Зависимости**: `requirements.txt` с зафиксированными версиями.
- **Логи инференса**: никогда не логировать тело запроса — в нём данные пациента и снимки. Логируются только статус, id модели, количество фото и длины строк.
- **Как собирается путь инференса** — только в `create_model_service()` (`app/service/factory.py`). Связка одна на все окружения, ветвиться не по чему: роут получает готовый `ModelService` из `app.state.model_service` и вызывает его.

### Swift (iOS)
- **Инициализация**:
`DependencyInitializer` (внешний пакет) запускает `InitializationProcess` через последовательность наборов шагов `StepSet` — `stepsTier1…stepsTier5`. Каждый `StepSet` содержит `sync`- и `async`-шаги, наполняющие `InitializationProcess`, который в конце преобразуется в `DependencyContainer` (`toContainer`). Запуск — в `ApplicationViewModel.initialize()`; контейнер пробрасывается через SwiftUI Environment.
- **Асинхронность**:
Swift Concurrency (`async/await`, `Task`), `@MainActor` для UI-кода.
- **Архитектура**:
MVVM. Каждый MVVM-модуль содержит:
`*Screen` - SwiftUI View + создание ViewModel.
`*ScreenView` - чистая View без логики. 
`*ViewModel` - `ObservableObject`-класс вью-модели, необходимо выносить логику отображаения в этот класс.
Если вью-модель зависит от контейнера зависимостей DependencyContainer - необходимо передавать его в вью-модель полностью, а не только конкретные сущности контейнера зависимостей.
`*Arguments`- класс аргументов, передаваемых в модуль.
Менеджмент состояния реализуется через протокол `ObservableObject` с `@Published` для скалярных свойств и `@NestedObservableObject` (пакет `NestedObservableObject`) для вложенных контроллеров-`ObservableObject`. View использует `@StateObject` для владения вью-моделью, `@EnvironmentObject` для передачи через окружение, `@ObservedObject` для внешних контроллеров и `@State` для локального состояния View.
- **Вью-модели не общаются между собой напрямую**. Обмен данными между модулями идёт только через замыкания, которые прокидываются во вью-модель при её создании в `*Screen` (например, `getIsActive`, `getAvailableRequestCount`, `getNeuralModelSettingsAvailability`, `onNeuralModelSelected`). Вью-модель одного модуля не должна знать про вью-модель другого и не должна обращаться к ней ни напрямую, ни через `@EnvironmentObject`.
- **Отображение частей интерфейса регулирует вью-модель своего модуля**, а не чужие вью-модели. Тот же принцип: во вью-модель модуля прокидываются нужные данные/замыкания, а она объявляет собственные вычисляемые флаги и методы для управления показом элементов экрана (например, `isSpeechButtonVisible`, `isNeuralModelSettingsVisible`). `*ScreenView` управляет вёрсткой (условный показ, доступность, ветвление) только через флаги и методы своей вью-модели и не читает сторонние `@EnvironmentObject` для этих решений.
- **Именование**:
Префикс `US` для доменных моделей УЗИ (`USExaminationType`, `USExaminationConclusion`).
Суффикс `DB` для моделей базы данных.
Суффикс `DTO` для DTO-моделей.
Префикс `D` присутствует только для базовых компонентов собственных модулей (`DDatabase`, `DTheme`, `DHttpClient`).
- **Модули**:
Проект разделён на локальные фреймворк-таргеты внутри `Doglyad.xcodeproj` — `DoglyadUI`, `DoglyadDatabase`, `DoglyadNetwork`, `DoglyadNeuralModel`, `DoglyadCamera`, `DoglyadSpeech`.
- **Внешние зависимости** (SPM): RevenueCat (`purchases-ios-spm`), Firebase (`firebase-ios-sdk`), MLX (`mlx-swift-lm`: MLXLLM/MLXVLM/MLXEmbedders/MLXLMCommon), `swift-transformers`, Alamofire, `swift-markdown-ui`, SwiftMessages, SwiftUI-Shimmer, BottomSheet, а также собственные пакеты автора `DependencyInitializer`, `NestedObservableObject`, `Handler`, `Router`.
- **Ветвление по enum**:
Логику, зависящую от значения `enum`-типа, описывать только через исчерпывающий `switch` (без `default`), а не через операторы сравнения (`==`/`!=`). Так добавление нового кейса вызывает ошибку компиляции во всех местах, где он не обработан, и ничего не теряется молча. Пример: флаги видимости во вью-моделях (`isUserEmailButtonVisible`, `is…ProBadgeVisible`) ветвятся по `SubscriptionFeatureAvailability` через `switch`, а не `== .offered`.

## Ограничения
- Pydantic-модели бэкенда используют camelCase в полях для совместимости с iOS — сохранять эту конвенцию.
- На клиенте для верстки использовать только SwiftUI и покмпоненты из дизайн-системы (`DoglyadUI`).
- На клиенте для взаимодействия с сетевым сллоем использовать только ресурсы из модуля (`DoglyadNetwork`).
- На клиенте для взаимодействия с базой данных использовать только ресурсы из модуля (`DoglyadDatabase`).
- Не модифицировать файлы: `ios/DoglyadNeuralModel/Resources/`, `ios/Config/`, `ios/Firebase/`, `backend/main/secrets/`, `backend/inference/secrets/`.
- Бэкенд не делает инференс сам: он живёт на не-GPU-виртуалке. Любая работа с моделью — в `backend/inference/`.
- Промпты, локализация и шаблоны живут только в главном бэкенде. Сервис инференса получает готовый текст и выполняет только генерацию.

## Команды
Все команды описаны в `Makefile`. Основные:
- `make venv` / `make pip-install` — окружение Python 3.11 и установка `backend/main/requirements.txt`.
- `make format` — `swiftformat` для iOS и `ruff format` для бэкенда.
- `make init-ios-development` — подставляет IP из `en0` в `BASE_URL` файла `ios/Config/Config.Development.xcconfig`.
- `make build-ios-development` / `make build-ios-production` — сборка соответствующей схемы (`IOS_DEST` переопределяет симулятор).
- `make download-ios-examination-model` — загрузка MLX-модели (`mlx-community/Qwen2.5-1.5B-Instruct-4bit`) в `DoglyadNeuralModel/Resources/`.
- `make start-backend-main-development` / `make start-backend-main-production` — запуск главного бэкенда в Docker; `ENVIRONMENT` берётся из соответствующего `backend/main/secrets/.env.<профиль>` (поверх общего `backend/main/secrets/.env`).
- `make start-backend-main-logs` / `make stop-backend-main` — логи и остановка главного бэкенда.
- `make start-backend-inference` / `make start-backend-inference-logs` / `make stop-backend-inference` — сервис инференса. Запускается **на GPU-виртуалке**, а не на машине разработчика: поднимает vLLM с моделью из `SERVED_MODEL_ID` и сервис `backend/inference` рядом с ней.
