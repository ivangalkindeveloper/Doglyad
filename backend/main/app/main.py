from __future__ import annotations

import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

import httpx
from fastapi import APIRouter, Depends, FastAPI
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from app.core.app_check import init_app_check, verify_app_check
from app.core.config import load_configs
from app.core.limiter import limiter
from app.core.logging import setup_logging
from app.core.variables import variables
from app.route.application_config import router as application_config_router
from app.route.ultrasound_conclusion import router as ultrasound_conclusion_router
from app.route.ultrasound_conclusion_send_email import router as ultrasound_conclusion_send_email_router
from app.service import create_model_service

setup_logging()
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(_app: FastAPI) -> AsyncIterator[None]:
    # Each inference service sets its own per-request timeout (the GPU VM and the
    # RunPod fallback have very different latency profiles); this is only the
    # default for callers that do not.
    http_client = httpx.AsyncClient(timeout=variables.inference_request_timeout_seconds)
    _app.state.http_client = http_client

    try:
        load_configs()
        init_app_check()
        _app.state.model_service = create_model_service(http_client)
    except RuntimeError as error:
        logger.critical("Application startup aborted: %s", error)
        await http_client.aclose()
        raise

    try:
        yield
    finally:
        await http_client.aclose()


# App Check is verified here, at the edge, and again on the GPU VM that holds the
# model. Two places rather than one because the fallback path bypasses the VM: a
# request that failed verification must not reach RunPod either. Unconditional and
# without exceptions — every environment reaches a real model, and the email route
# spends real SMTP credentials. See backend/inference.
router_v1 = APIRouter(prefix="/v1", dependencies=[Depends(verify_app_check)])
router_v1.include_router(ultrasound_conclusion_router)
router_v1.include_router(ultrasound_conclusion_send_email_router)

app = FastAPI(lifespan=lifespan)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.include_router(router_v1)
# Outside /v1 on purpose: the app reads these before it has anything to
# authenticate with, and their contents are public either way.
app.include_router(application_config_router)
