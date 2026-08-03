from __future__ import annotations

import asyncio
import logging

import firebase_admin
from fastapi import Depends, Header, HTTPException, params, status
from firebase_admin import app_check, credentials

from app.core.variables import variables

logger = logging.getLogger(__name__)

APP_CHECK_HEADER = "X-Firebase-AppCheck"


def init_app_check() -> None:
    """Initializes the Firebase Admin SDK for verifying App Check tokens.

    Called once at application startup. Keyed off the dependency helpers below
    rather than a rule of its own: whatever closes a route is exactly what makes
    the SDK necessary, so the two cannot drift apart. When nothing closes a
    route, a developer needs no Firebase credentials at all; when something does,
    a missing `FIREBASE_CREDENTIALS_PATH` raises `RuntimeError` and startup
    aborts rather than leaving a route that answers everyone.
    """
    if not (app_check_dependencies() or mail_app_check_dependencies()):
        logger.warning(
            "App Check verification is off: LLM_MODE=%s, ENVIRONMENT=%s",
            variables.llm_mode.value,
            variables.environment,
        )
        return
    if firebase_admin._apps:
        logger.warning("Firebase Admin SDK is already initialized")
        return
    if not variables.firebase_credentials_path:
        raise RuntimeError("FIREBASE_CREDENTIALS_PATH is not set")
    credential = credentials.Certificate(str(variables.firebase_credentials_path))
    firebase_admin.initialize_app(credential)


def app_check_dependencies() -> list[params.Depends]:
    """The `/v1` router dependencies that enforce App Check, if the mode needs it.

    A function rather than an inline conditional so the rule has one testable
    home: `/v1` is closed in every mode that reaches a model, and open only in
    the mode that reaches nothing.
    """
    if not variables.llm_mode.verifies_app_check:
        return []
    return [Depends(verify_app_check)]


def mail_app_check_dependencies() -> list[params.Depends]:
    """Extra enforcement for the email route, on top of the router's own rule.

    Sending mail never reaches a model, so `LLM_MODE` says nothing useful about
    it — yet it is a real outward action performed with real SMTP credentials,
    and an open one is an open relay. In production it is closed whatever the
    mode; outside production it follows the router, so the flow stays testable
    without minting a token.

    Adding `Depends(verify_app_check)` twice is harmless: FastAPI caches a
    dependency per request, so it still runs once.
    """
    if not variables.is_production:
        return []
    return [Depends(verify_app_check)]


async def verify_app_check(
    x_firebase_app_check: str | None = Header(default=None, alias=APP_CHECK_HEADER),
) -> None:
    """Verifies the App Check token from the `X-Firebase-AppCheck` header.

    This is the edge of the system: requests arrive here from the internet, so
    rejecting them here keeps an unverified caller away from every path behind
    it — including the paid RunPod fallback, which is a third party and verifies
    nothing itself. The inference VM verifies the same token again, because it
    is reachable over the network on its own.

    Raises 401 when the token is missing or fails verification.
    """
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
