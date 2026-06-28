---
name: backend-endpoint
description: Добавление нового HTTP-эндпоинта в бэкенд Doglyad (FastAPI). Создаёт роут под /v1, Pydantic request/response модели с camelCase-полями (совместимость с iOS), подключает rate limiter и регистрирует роутер в main.py. Используй, когда нужен новый API-метод на бэкенде.
---

# backend-endpoint — новый эндпоинт FastAPI

Создаёт эндпоинт по принятым в проекте конвенциям и **полностью** подключает его к приложению. Бэкенд: Python 3.11, FastAPI, Pydantic, общий `httpx.AsyncClient`, slowapi-лимитер.

Каталоги:
- роуты — `backend/app/route/<name>.py`
- модели — `backend/app/model/` (общие) или `backend/app/model/ultrasound/` (доменные УЗИ)
- сборка приложения — `backend/app/main.py`

Перед генерацией **прочитай эталон** `app/route/ultrasound_conclusion.py` (с инференсом/сервисами) или `app/route/ultrasound_conclusion_send_email.py` (без тела ответа) — шаблоны ниже лишь каркас.

## Что уточнить перед началом

1. **Имя эндпоинта** в snake_case, напр. `ultrasound_history`. Из него получаются: файл `app/route/<name>.py`, путь `/<name>`, имя функции.
2. **Метод и форма ответа**: возвращает модель (`response_model=...`) или без тела (`status_code=status.HTTP_204_NO_CONTENT`).
3. **Request-модель**: какие поля приходят (или эндпоинт без body).
4. **Нужен ли LLM-инференс** (тогда подключаем `resolve_model_service` + `resolve_prompt_factory`, см. `ultrasound_conclusion.py`), внешний HTTP (общий клиент из `request.app.state.http_client`) или просто бизнес-логика.

## Жёсткие правила (из AGENTS.md)

- `from __future__ import annotations` в начале каждого файла; аннотации типов везде.
- **Именование**: snake_case для функций/переменных, CamelCase для классов и Pydantic-моделей.
- **camelCase в полях Pydantic-моделей** — это контракт с iOS, не нарушать (`neuralModelSettings`, `recipientEmail`, `modelId`). Не добавляй `alias`/`Field` для перевода в snake_case.
- Асинхронность: `async def` для обработчиков; внешние HTTP — через общий `httpx.AsyncClient` (`request.app.state.http_client`), а не новый клиент на запрос. Блокирующий I/O (SMTP, CPU) — через `asyncio.to_thread`.
- Конфигурация/секреты — только через `variables` из `app/core/variables.py` (читает `backend/.env`). Не хардкодить и не трогать `backend/.env`.
- Ошибки — `raise HTTPException(status_code=..., detail=...)`; логирование через модульный `logger`.
- Rate limit — декоратор `@limiter.limit("30/minute")` (нужен параметр `request: Request` в сигнатуре).

## Шаблон роута

`backend/app/route/<name>.py`:
```python
from __future__ import annotations

import logging

from fastapi import APIRouter, HTTPException, Request

from app.core.limiter import limiter
from app.core.variables import variables
from app.model.<name>_request import <Name>Request
from app.model.<name>_response import <Name>Response

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/<name>", response_model=<Name>Response)
@limiter.limit("30/minute")
async def <name>(
    body: <Name>Request,
    request: Request,
) -> <Name>Response:
    logger.info("Request <name>: ...")

    # бизнес-логика. Для внешнего HTTP: request.app.state.http_client
    # Для блокирующего I/O: await asyncio.to_thread(_blocking_fn, ...)
    # При ошибке: raise HTTPException(status_code=400, detail="...")

    return <Name>Response(...)
```

Вариант **без тела ответа** (как `ultrasound_conclusion_send_email`):
```python
from fastapi import status

@router.post("/<name>", status_code=status.HTTP_204_NO_CONTENT)
@limiter.limit("30/minute")
async def <name>(body: <Name>Request, request: Request) -> None:
    del request  # если request нужен только лимитеру
    ...
```

## Шаблон Pydantic-моделей

`backend/app/model/<name>_request.py` (доменные УЗИ-модели — в `app/model/ultrasound/`, префикс `US`):
```python
from __future__ import annotations

from pydantic import BaseModel


class <Name>Request(BaseModel):
    someField: str            # camelCase — контракт с iOS
    optionalField: str | None = None
```

`backend/app/model/<name>_response.py`:
```python
from __future__ import annotations

from pydantic import BaseModel


class <Name>Response(BaseModel):
    resultField: str
```

Если модель вложенная — выноси под-модели отдельными классами/файлами, как в `app/model/ultrasound/`.

## Регистрация в приложении (обязательно)

В `backend/app/main.py`:

1. Импорт роутера рядом с существующими:
```python
from app.route.<name> import router as <name>_router
```
2. Подключение к `router_v1` (он имеет `prefix="/v1"`, итоговый путь — `/v1/<name>`):
```python
router_v1.include_router(<name>_router)
```

## Если нужен LLM-инференс

Повтори паттерн из `ultrasound_conclusion.py`:
- язык из заголовка: `request.headers.get("accept-language", "en")` → `resolve_prompt_factory(language_code)`;
- ветвление по `variables.llm_mode` (`LLMMode.STUB` / `LLMMode.RUNPOD`) через `match`;
- `model_service = resolve_model_service(variables.llm_mode)` и `await model_service.call(...)`;
- резолверы моделей/типов — из `app/core/config.py` (`resolve_neural_model`, `resolve_examination_title`).
Новый бэкенд-сервис инференса добавляй как реализацию `ModelService` (`app/service/base.py`) и регистрируй в `app/service/__init__.py`.

## Финальные шаги

1. Если эндпоинт меняет контракт — синхронизируй модели на стороне iOS (DTO/доменные модели, camelCase-поля).
2. Прогон: подними бэкенд через `make start-backend-development-stub`, проверь эндпоинт (`/v1/<name>`), посмотри `make start-logs`.
3. Сообщи пользователю: созданные файлы, путь эндпоинта и точку регистрации в `main.py`.
