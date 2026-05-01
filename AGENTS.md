# Doglyad — AI-ассистент для анализа УЗИ-исследований
Проект представляет собой AI-ассистента, который анализирует ультразвуковые снимки вместе с описанием анамнеза пациентов и генерирует медицинское заключение.

## Архитектура
- **Бэкенд** — Python, FastAPI, Docker, vLLM для LLM-инференса.
- **iOS-приложение** — SwiftUI, MVVM, SwiftData, Alamofire, MLX.

## Навигация по коду
### `backend/` — Бэкенд
| Путь | Описание |
|---|---|
| `backend/app/main.py` | FastAPI-приложение, роутер `/v1`, подключение rate limiter |
| `backend/app/route/ultrasound_conclusion.py` | Эндпоинт `POST /v1/ultrasound_conclusion` — принимает данные исследования, отправляет запрос в vLLM, возвращает заключение |
| `backend/app/core/config.py` | Загрузка конфигов моделей и типов исследований из JSON, переменные окружения (`ENVIRONMENT`) |
| `backend/app/core/llm_mode.py` | Режимы работы LLM — `stub` (заглушка) и `inference` (реальный инференс) |
| `backend/app/model/` | Pydantic-модели запросов и ответов |
| `backend/app/prompt/` | Генерация промптов — `base.py`, локализации `ru.py`/`en.py` |
| `backend/docker-compose.yml` | Docker Compose — профили для stub и vLLM |

### `ios/` — iOS-приложение
| Путь | Описание |
|---|---|
| `ios/Doglyad/Application/Application/` | Точка входа `Application.swift`, `ApplicationViewModel`, корневые вью (`MainRootView`, `ErrorRootView`), роутер (`DRouter`, `RouteType`). |
| `ios/Doglyad/Application/Component/` | Переиспользуемые UI-компоненты уровня приложения, а не на уровне дизайн-системы. |
| `ios/Doglyad/Application/Module/` | Экраны и вьюмодели — каждый модуль содержит `*Screen.swift`, `*ScreenView.swift`, `*ViewModel.swift`, `*Arguments.swift` |
| `ios/Doglyad/Core/DependencyContainer.swift` | DI-контейнер — хранит все зависимости приложения |
| `ios/Doglyad/Core/Initialization/` | Процесс инициализации через `DependencyInitializer` (preSyncSteps → asyncSteps → postSyncSteps) |
| `ios/Doglyad/Core/Environment/` | `EnvironmentProtocol`, `EnvironmentType` — конфигурация окружения (dev/prod) |
| `ios/Doglyad/Domain/` | Доменные модели (`USExaminationType`, `USExaminationNeuralModel`, `NeuralModelSettings` и др.) |
| `ios/Doglyad/Repository/` | Репозитории — протокол + реализация для данных (`UltrasoundConclusionRepository`, `SharedRepository`, `TemplateRepository`) |
| `ios/Doglyad/Utility/` | Расширения, менеджеры (`PermissionManager`, `ConnectionManager`) |
| `ios/Doglyad/Resources/Localizable.xcstrings` | Локализация |
| `ios/DoglyadUI/` | Дизайн-система: тема (`DTheme`), шрифты (Montserrat), компоненты (`DSegment`, `DCloseButton`, `DButtonCard`, `DMessage`) |
| `ios/DoglyadDatabase/` | SwiftData БД — `DDatabase`, сущности (`*DB.swift`), UserDefaults-обёртки |
| `ios/DoglyadNetwork/` | HTTP-клиент на Alamofire — `DHttpClientProtocol`, `DHttpClient` |
| `ios/DoglyadNeuralModel/` | Интеграция ML-моделей (MLX, Foundation Models) |
| `ios/DoglyadCamera/` | Камера — `DCameraController`, `DCameraView` |
| `ios/DoglyadSpeech/` | Распознавание речи — `DSpeechController` |
| `ios/Config.xcconfig` | Конфигурация сборки (BASE_URL) — генерируется из `Config.Development.xcconfig` или `Config.Production.xcconfig` |

## Стиль кода
### Python (Бэкенд)
- **Фреймворк**: FastAPI с Pydantic-моделями.
- **Типизация**: `from __future__ import annotations`, аннотации типов везде.
- **Именование**: snake_case для функций и переменных, CamelCase для классов и Pydantic-моделей. camelCase в Pydantic-полях (совместимость с iOS).
- **Асинхронность**: `async/await` для обработчиков и HTTP-запросов (`httpx.AsyncClient`).
- **Зависимости**: `requirements.txt` без фиксированных версий.

### Swift (iOS)
- **Инициализация**:
`DependencyInitializer` запускает `InitializationProcess` через три фазы шагов — `preSyncSteps` → `asyncSteps` → `postSyncSteps`. Каждый шаг наполняет `InitializationProcess`, который в конце преобразуется в `DependencyContainer` (`toContainer`). Контейнер пробрасывается через SwiftUI Environment.
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
Проект разделён на Swift-пакеты — `DoglyadUI`, `DoglyadDatabase`, `DoglyadNetwork`, `DoglyadNeuralModel`, `DoglyadCamera`, `DoglyadSpeech`.

## Ограничения
- Pydantic-модели бэкенда используют camelCase в полях для совместимости с iOS — сохранять эту конвенцию.
- На клиенте для верстки использовать только SwiftUI и покмпоненты из дизайн-системы (`DoglyadUI`).
- На клиенте для взаимодействия с сетевым сллоем использовать только ресурсы из модуля (`DoglyadNetwork`).
- На клиенте для взаимодействия с базой данных использовать только ресурсы из модуля (`DoglyadDatabase`).
- Не модифицировать файлы: `ios/DoglyadNeuralModel/Resources/`, `ios/Config.xcconfig`, `ios/GoogleService-Info.plist`.

## Команды
В файле Makefile описаны все команды для работы с проектом.