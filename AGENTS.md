# Doglyad — AI-ассистент для анализа УЗИ-исследований
Проект представляет собой AI-ассистента, который анализирует ультразвуковые снимки вместе с описанием анамнеза пациентов и генерирует медицинское заключение.

## Архитектура
- **Бэкенд** — Python, FastAPI, Docker. LLM-инференс через RunPod (serverless endpoints); режим `stub` для заглушки. Отправка заключений на email через SMTP.
- **iOS-приложение** — SwiftUI, MVVM, SwiftData, Alamofire, MLX (on-device инференс), Firebase, RevenueCat (подписки).

## Навигация по коду
### `backend/` — Бэкенд
| Путь | Описание |
|---|---|
| `backend/app/main.py` | FastAPI-приложение, lifespan (загрузка конфигов, создание `httpx.AsyncClient`, инициализация сервисов), роутер `/v1`, rate limiter |
| `backend/app/route/ultrasound_conclusion.py` | Эндпоинт `POST /v1/ultrasound_conclusion` — принимает данные исследования, вызывает `ModelService`, возвращает заключение |
| `backend/app/route/ultrasound_conclusion_send_email.py` | Эндпоинт `POST /v1/ultrasound_conclusion_send_email` — отправка заключения на email через SMTP (`smtplib`) |
| `backend/app/core/variables.py` | Переменные окружения через `pydantic_settings` (`Variables`): `ENVIRONMENT`, `LLM_MODE`, `EMAIL_*`, `RUNPOD_API_KEY`, `RUNPOD_ENDPOINTS_PATH`, читаются в т.ч. из `backend/secrets/.env` |
| `backend/app/core/config.py` | Загрузка конфигов нейромоделей и типов исследований из JSON (`backend/config/<environment>/`), резолверы моделей и заголовков |
| `backend/app/core/llm_mode.py` | Режимы работы LLM — `stub` (заглушка) и `inference` (реальный инференс; провайдер — RunPod) |
| `backend/app/service/` | Абстракция инференса — `ModelService` (`base.py`) и `RunPodService` (`runpod.py`); `init_services`/`resolve_model_service` в `__init__.py` |
| `backend/app/model/` | Pydantic-модели — `neural_model_settings.py`, `runpod_response.py`, подпакет `ultrasound/` (request/data/conclusion/email/scan_photo/type/neural_model) |
| `backend/app/prompt/` | Генерация промптов — `base.py` (`PromptFactory`), локализации `ru.py`/`en.py`, `resolve_prompt_factory` в `__init__.py` |
| `backend/config/` | JSON-конфиги по окружениям (`development/`, `production/`): `application.json`, `ultrasound_examination_neural_models.json`, `ultrasound_examination_types.json` |
| `backend/config/runpod_endpoints.json` | Желаемое состояние serverless-эндпоинтов RunPod (образ, `env` для vLLM, GPU, скейлинг). Общий для окружений — имена эндпоинтов не привязаны к окружению. Разбор каждой настройки — в [`RUNPOD.md`](RUNPOD.md) |
| `backend/scripts/runpod_sync.py` | Синхронизация эндпоинтов RunPod с конфигом: `plan`/`apply`/`urls`/`destroy` (`make runpod-*`). Печатает карту `modelId -> url` для `backend/secrets/runpod_endpoint.json` |
| `backend/docker-compose.yml` | Docker Compose — читает `backend/secrets/.env` + профильный `secrets/.env.<профиль>` (выбор через `ENV_FILE`), монтирует `./config` |

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
- **Конфигурация**: переменные окружения через `pydantic_settings` (`app/core/variables.py`), значения из `backend/secrets/.env`.
- **Зависимости**: `requirements.txt` с зафиксированными версиями.

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
- Не модифицировать файлы: `ios/DoglyadNeuralModel/Resources/`, `ios/Config/`, `ios/Firebase/`, `backend/secrets/`.

## Команды
Все команды описаны в `Makefile`. Основные:
- `make venv` / `make pip-install` — окружение Python 3.11 и установка `backend/requirements.txt`.
- `make format` — `swiftformat` для iOS и `ruff format` для бэкенда.
- `make init-ios-development` — подставляет IP из `en0` в `BASE_URL` файла `ios/Config/Config.Development.xcconfig`.
- `make build-ios-development` / `make build-ios-production` — сборка соответствующей схемы (`IOS_DEST` переопределяет симулятор).
- `make download-examination` — загрузка MLX-модели (`mlx-community/Qwen2.5-1.5B-Instruct-4bit`) в `DoglyadNeuralModel/Resources/`.
- `make start-backend-development-stub` / `make start-backend-development-inference` / `make start-backend-production` — запуск бэкенда в Docker; `ENVIRONMENT`/`LLM_MODE` берутся из соответствующего `backend/secrets/.env.<профиль>` (поверх общего `backend/secrets/.env`).
- `make start-logs` / `make stop-backend` — логи и остановка бэкенда.