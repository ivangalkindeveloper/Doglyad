---
name: build-verify
description: Проверка изменений в проекте Doglyad перед коммитом — сборка/тесты iOS (xcodebuild) и линт/типы/тесты бэкенда (ruff, mypy, pytest). Используй, когда нужно убедиться, что код компилируется и проходит проверки ("проверь сборку", "прогони тесты", "всё ли собирается", "verify").
---

# build-verify — сборка и проверка Doglyad

Замыкает цикл «написал код → убедился, что он рабочий». Запускай после изменений и перед `git-push`. Все команды — из `Makefile`; не изобретай инвокации `xcodebuild`/`pytest` вручную.

## Что уточнить перед началом

1. **Что затронуто** — iOS, бэкенд или оба. Гоняй проверки только релевантной части, чтобы не тратить время.
2. **Симулятор для iOS** — по умолчанию `iPhone 17` (`IOS_DEST`). Если такого нет, спроси или подставь доступный: `make build-ios-development IOS_DEST='platform=iOS Simulator,name=<имя>'`.
3. **Окружение для iOS** — `Development` или `Production`. По умолчанию проверяй `Development`; `Production` — когда правки касаются продовой конфигурации или готовится релиз.

## Бэкенд (Python / FastAPI)

Бэкенда два, и проверяются они по отдельности: `backend/main` (главный, не-GPU) и `backend/gpu` (сервис инференса на GPU-виртуалке). У каждого свои `pyproject.toml`, `requirements*.txt` и `tests/`. Гоняй тот, который затронут; если правка меняет контракт между ними — оба.

Порядок (от быстрого к медленному). Отдельных make-целей для линта/типов/тестов нет, вызывай напрямую:

```bash
make format                               # ruff format для обоих бэкендов (заодно swiftformat для iOS)

cd backend/main && ruff check app tests   # линт
cd backend/main && mypy                   # типы (files из pyproject)
cd backend/main && pytest                 # тесты (в backend/main/tests/)

cd backend/gpu && ruff check app tests    # то же для GPU-сервиса
cd backend/gpu && mypy
cd backend/gpu && pytest
```

- Dev-инструменты ставятся один раз: `make pip-install-dev` (ставит зависимости `backend/main`; для `backend/gpu` — `pip3 install -r backend/gpu/requirements-dev.txt`).
- `pytest` при отсутствии тестов вернёт «no tests collected» (exit 5) — это не ошибка кода, отметь и продолжай.
- Конфигурация линтера/типов/тестов — `backend/main/pyproject.toml` и `backend/gpu/pyproject.toml`.
- В `backend/main` `mypy` показывает несколько давних ошибок в `ultrasound_conclusion_send_email.py`, `config.py` и `main.py`. Они были там до разделения бэкендов — не выдавай их за поломку своих правок, но и новых не добавляй.

## iOS (Swift / SwiftUI)

```bash
make format                   # swiftformat (правила в ios/.swiftformat) — обычно уже прогнан хуком
make build-ios-development    # сборка схемы Doglyad-Development
make build-ios-production     # сборка схемы Doglyad-Production
```

Отдельной make-цели для тестов нет, вызывай напрямую:

```bash
cd ios && xcodebuild test \
  -project Doglyad.xcodeproj \
  -scheme Doglyad-Development \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

- `xcodebuild` шумный и медленный. При падении ищи в конце вывода `error:` / `** BUILD FAILED **` / `** TEST FAILED **` — не пересказывай весь лог, покажи суть.
- Если симулятор `IOS_DEST` недоступен (`Unable to find a device`), подставь существующий и повтори.
- Схема определяет конфигурацию сборки (`Development` / `Production`), а та — `.xcconfig`, bundle id и `GoogleService-Info.plist`. Никогда не подменяй окружение правкой файлов в `ios/Config/` или `ios/Firebase/` — переключайся схемой.
- Сборка требует `ios/Config/Config.*.xcconfig` и `ios/Firebase/*/GoogleService-Info.plist`; в репозитории их нет. Если отсутствуют — сборка упадёт, запроси файлы у пользователя, не создавай сам.

## Финальные шаги

1. Кратко доложи статус по каждой части: что прошло, что упало, с какими ошибками (файл + строка).
2. **Не коммить сам** — это делает skill `git-push`. Если всё зелёное и пользователь хочет отправить изменения, предложи вызвать `git-push`.
3. Если проверки упали — не выдавай результат за успех. Покажи ошибку и предложи починить.
