from __future__ import annotations

import asyncio
import logging

import firebase_admin
from fastapi import Header, HTTPException, status
from firebase_admin import app_check, credentials

from app.core.variables import variables

logger = logging.getLogger(__name__)

_APP_CHECK_HEADER = "X-Firebase-AppCheck"


def init_app_check() -> None:
    """Инициализирует Firebase Admin SDK для проверки App Check токенов.

    Вызывается один раз при старте приложения. Если проверка отключена
    (`APP_CHECK_ENABLED=false`), ничего не делает. Если проверка включена, но
    `FIREBASE_CREDENTIALS_PATH` не задан — бросает `RuntimeError` (старт прерывается).
    """
    if not variables.app_check_enabled:
        logger.warning("App Check verification is disabled")
        return
    if firebase_admin._apps:
        logger.warning("Firebase Admin SDK is already initialized")
        return
    if not variables.firebase_credentials_path:
        raise RuntimeError(
            "App Check is enabled but FIREBASE_CREDENTIALS_PATH is not set"
        )
    credential = credentials.Certificate(str(variables.firebase_credentials_path))
    firebase_admin.initialize_app(credential)


async def verify_app_check(
    x_firebase_app_check: str | None = Header(default=None, alias=_APP_CHECK_HEADER),
) -> None:
    """Проверяет App Check токен из заголовка `X-Firebase-AppCheck`.

    Подтверждает, что запрос пришёл из подлинного приложения. Бросает 401, если
    токен отсутствует или не проходит проверку.
    """
    if not variables.app_check_enabled:
        return
    if not x_firebase_app_check:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing App Check token",
        )
    try:
        await asyncio.to_thread(app_check.verify_token, x_firebase_app_check)
    except ValueError as error:
        logger.warning("Invalid App Check token: %s", error)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid App Check token",
        ) from error
