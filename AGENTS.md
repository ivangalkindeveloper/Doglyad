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
| `backend/app/core/variables.py` | Переменные окружения через `pydantic_settings` (`Variables`): `ENVIRONMENT`, `LLM_MODE`, `EMAIL_*`, `RUNPOD_API_KEY`, `RUNPOD_URLS`, читаются в т.ч. из `backend/.env` |
| `backend/app/core/config.py` | Загрузка конфигов нейромоделей и типов исследований из JSON (`backend/config/<environment>/`), резолверы моделей и заголовков |
| `backend/app/core/llm_mode.py` | Режимы работы LLM — `stub` (заглушка) и `runpod` (реальный инференс) |
| `backend/app/service/` | Абстракция инференса — `ModelService` (`base.py`) и `RunPodService` (`runpod.py`); `init_services`/`resolve_model_service` в `__init__.py` |
| `backend/app/model/` | Pydantic-модели — `neural_model_settings.py`, `runpod_response.py`, подпакет `ultrasound/` (request/data/conclusion/email/scan_photo/type/neural_model) |
| `backend/app/prompt/` | Генерация промптов — `base.py` (`PromptFactory`), локализации `ru.py`/`en.py`, `resolve_prompt_factory` в `__init__.py` |
| `backend/config/` | JSON-конфиги по окружениям (`development/`, `production/`): `application.json`, `ultrasound_examination_neural_models.json`, `ultrasound_examination_types.json` |
| `backend/docker-compose.yml` | Docker Compose — управляется через `ENVIRONMENT`/`LLM_MODE`, читает `backend/.env`, монтирует `./config` |

### `ios/` — iOS-приложение
| Путь | Описание |
|---|---|
| `ios/Doglyad/Application/Application/` | Точка входа `Application.swift`, `ApplicationViewModel`, корневые вью (`MainRootView`, `ErrorRootView`), роутер (`DRouter`, `RouteType`). |
| `ios/Doglyad/Application/Component/` | Переиспользуемые UI-компоненты уровня приложения, а не на уровне дизайн-системы. |
| `ios/Doglyad/Application/Module/` | Экраны и вьюмодели — каждый модуль содержит `*Screen.swift`, `*ScreenView.swift`, `*ViewModel.swift`, `*Arguments.swift`. Модули: `Scan`, `ScanSpeech`, `Select` (тип исследования / нейромодель / дата рождения), `Conclusion`, `RecievedConclusion`, `History`, `Storage`, `Template`, `Settings`, `UserSettings`, `NeuralModel`, `Subscription` (`Paywall`, `CustomerCenter`), `LimitExceeded`, `Share`, `OnBoarding`, `Permission`, `NewVersion`, `WebDocument`, `About` |
| `ios/Doglyad/Core/DependencyContainer.swift` | DI-контейнер — хранит все зависимости приложения (репозитории, менеджеры, конфиги, нейромодель, начальный экран/статус подписки) |
| `ios/Doglyad/Core/Initialization/` | Процесс инициализации через `DependencyInitializer` (пакет). `InitializationProcess` наполняется набором `StepSet` — `stepsTier1…stepsTier5` (`Steps/InitializationStepsTier*.swift`), каждый со `sync`/`async`-шагами; в конце `toContainer` собирает `DependencyContainer` |
| `ios/Doglyad/Core/Environment/` | `EnvironmentProtocol`, `EnvironmentType` — конфигурация окружения (dev/prod) |
| `ios/Doglyad/Domain/` | Доменные модели: `Ultrasound/` (`USExaminationType`, `USExaminationNeuralModel`, `USExaminationRequest`, `USExaminationConclusion`, `USExaminationEmail` и др.), `Config/` (`ApplicationConfig`, `UltrasoundConfig`, `Version`), `Subscription/` (`SubscriptionConfig`), `NeuralModelSettings`, `PatientGender` |
| `ios/Doglyad/Repository/` | Репозитории (протокол + реализация): `Conclusion`, `Model`, `Shared`, `Subscription` (`RevenueCatSubscriptionRepository`), `Template`, `UserSettings` |
| `ios/Doglyad/Utility/` | Расширения (`Extension/`), модификаторы (`Modifier/`), менеджеры (`Manager/` — `PermissionManager`, `ConnectionManager`) |
| `ios/Doglyad/Resources/Localizable.xcstrings` | Локализация |
| `ios/DoglyadUI/` | Дизайн-система: тема (`DTheme`), шрифты (Montserrat), компоненты (`DSegment`, `DCloseButton`, `DButtonCard`, `DMessage`) |
| `ios/DoglyadDatabase/` | SwiftData БД — `DDatabase`, сущности (`*DB.swift`), UserDefaults-обёртки |
| `ios/DoglyadNetwork/` | HTTP-клиент на Alamofire — `DHttpClientProtocol`, `DHttpClient`, `DHttpHeader`, `DHttpError` |
| `ios/DoglyadNeuralModel/` | Интеграция ML-моделей (MLX, Foundation Models) |
| `ios/DoglyadCamera/` | Камера — `DCameraController`, `DCameraView` |
| `ios/DoglyadSpeech/` | Распознавание речи — `DSpeechController` |
| `ios/Config/` | Конфигурация сборки: `Config.xcconfig` (BASE_URL, ENVIRONMENT) генерируется из `Config.Development.xcconfig` / `Config.Production.xcconfig` командами `make init-ios-local` / `make init-ios-production` |
| `ios/GoogleService-Info.plist` | Конфигурация Firebase |

## Стиль кода
### Python (Бэкенд)
- **Фреймворк**: FastAPI с Pydantic-моделями.
- **Типизация**: `from __future__ import annotations`, аннотации типов везде.
- **Именование**: snake_case для функций и переменных, CamelCase для классов и Pydantic-моделей. camelCase в Pydantic-полях (совместимость с iOS).
- **Асинхронность**: `async/await` для обработчиков и HTTP-запросов (общий `httpx.AsyncClient` из `app.state`, создаётся в lifespan).
- **Конфигурация**: переменные окружения через `pydantic_settings` (`app/core/variables.py`), значения из `backend/.env`.
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
- **Именование**:
Префикс `US` для доменных моделей УЗИ (`USExaminationType`, `USExaminationConclusion`).
Суффикс `DB` для моделей базы данных.
Суффикс `DTO` для DTO-моделей.
Префикс `D` присутствует только для базовых компонентов собственных модулей (`DDatabase`, `DTheme`, `DHttpClient`).
- **Модули**:
Проект разделён на локальные фреймворк-таргеты внутри `Doglyad.xcodeproj` — `DoglyadUI`, `DoglyadDatabase`, `DoglyadNetwork`, `DoglyadNeuralModel`, `DoglyadCamera`, `DoglyadSpeech`.
- **Внешние зависимости** (SPM): RevenueCat (`purchases-ios-spm`), Firebase (`firebase-ios-sdk`), MLX (`mlx-swift-lm`: MLXLLM/MLXVLM/MLXEmbedders/MLXLMCommon), `swift-transformers`, Alamofire, `swift-markdown-ui`, SwiftMessages, SwiftUI-Shimmer, BottomSheet, а также собственные пакеты автора `DependencyInitializer`, `NestedObservableObject`, `Handler`, `Router`.

## Ограничения
- Pydantic-модели бэкенда используют camelCase в полях для совместимости с iOS — сохранять эту конвенцию.
- На клиенте для верстки использовать только SwiftUI и покмпоненты из дизайн-системы (`DoglyadUI`).
- На клиенте для взаимодействия с сетевым сллоем использовать только ресурсы из модуля (`DoglyadNetwork`).
- На клиенте для взаимодействия с базой данных использовать только ресурсы из модуля (`DoglyadDatabase`).
- Не модифицировать файлы: `ios/DoglyadNeuralModel/Resources/`, `ios/Config/Config.xcconfig`, `ios/GoogleService-Info.plist`, `backend/.env`.

## Команды
Все команды описаны в `Makefile`. Основные:
- `make venv` / `make pip-install` — окружение Python 3.11 и установка `backend/requirements.txt`.
- `make format` — `swiftformat` для iOS.
- `make init-ios-local` / `make init-ios-production` — генерация `ios/Config/Config.xcconfig` (local подставляет IP из `en0` в `BASE_URL`).
- `make download-examination` — загрузка MLX-модели в `DoglyadNeuralModel/Resources/`.
- `make start-backend-{development,production}-{stub,runpod}` — запуск бэкенда в Docker с нужными `ENVIRONMENT`/`LLM_MODE`.
- `make start-logs` / `make stop-backend` — логи и остановка бэкенда.