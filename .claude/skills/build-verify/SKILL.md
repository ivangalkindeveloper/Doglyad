---
name: build-verify
description: Проверка изменений в проекте Doglyad перед коммитом — сборка/тесты iOS (xcodebuild) и линт/типы/тесты бэкенда (ruff, mypy, pytest). Используй, когда нужно убедиться, что код компилируется и проходит проверки ("проверь сборку", "прогони тесты", "всё ли собирается", "verify").
---

# build-verify — сборка и проверка Doglyad

Замыкает цикл «написал код → убедился, что он рабочий». Запускай после изменений и перед `git-push`. Все команды — из `Makefile`; не изобретай инвокации `xcodebuild`/`pytest` вручную.

## Что уточнить перед началом

1. **Что затронуто** — iOS, бэкенд или оба. Гоняй проверки только релевантной части, чтобы не тратить время.
2. **Симулятор для iOS** — по умолчанию `iPhone 16` (`IOS_DEST`). Если такого нет, спроси или подставь доступный: `make test-ios IOS_DEST='platform=iOS Simulator,name=<имя>'`.

## Бэкенд (Python / FastAPI)

Порядок (от быстрого к медленному):

```bash
make format-backend      # ruff format app — привести стиль
make lint-backend        # ruff check app — линт
make typecheck-backend   # mypy app — типы
make test-backend        # pytest (тесты в backend/tests/)
```

- Dev-инструменты ставятся один раз: `make pip-install-dev`.
- `pytest` при отсутствии тестов вернёт «no tests collected» (exit 5) — это не ошибка кода, отметь и продолжай.
- Конфигурация линтера/типов/тестов — `backend/pyproject.toml`.

## iOS (Swift / SwiftUI)

```bash
make format      # swiftformat (правила в ios/.swiftformat) — обычно уже прогнан хуком
make build-ios   # сборка схемы Doglyad
make test-ios    # DoglyadTests + DoglyadUITests
```

- `xcodebuild` шумный и медленный. При падении ищи в конце вывода `error:` / `** BUILD FAILED **` / `** TEST FAILED **` — не пересказывай весь лог, покажи суть.
- Если симулятор `IOS_DEST` недоступен (`Unable to find a device`), подставь существующий и повтори.

## Финальные шаги

1. Кратко доложи статус по каждой части: что прошло, что упало, с какими ошибками (файл + строка).
2. **Не коммить сам** — это делает skill `git-push`. Если всё зелёное и пользователь хочет отправить изменения, предложи вызвать `git-push`.
3. Если проверки упали — не выдавай результат за успех. Покажи ошибку и предложи починить.
