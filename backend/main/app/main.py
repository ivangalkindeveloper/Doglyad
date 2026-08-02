from __future__ import annotations

import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

import httpx
from fastapi import APIRouter, FastAPI
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from app.core.config import load_configs
from app.core.limiter import limiter
from app.core.logging import setup_logging
from app.core.variables import variables
from app.route.ultrasound_conclusion import router as ultrasound_conclusion_router
from app.route.ultrasound_conclusion_send_email import router as ultrasound_conclusion_send_email_router
from app.service import ServiceFactory

setup_logging()
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(_app: FastAPI) -> AsyncIterator[None]:
    # Each inference service sets its own per-request timeout (the GPU VM and the
    # RunPod fallback have very different latency profiles); this is only the
    # default for callers that do not.
    http_client = httpx.AsyncClient(timeout=variables.gpu_request_timeout_seconds)
    _app.state.http_client = http_client

    try:
        load_configs()
        _app.state.service_factory = ServiceFactory(http_client, variables.llm_mode)
    except RuntimeError as error:
        logger.critical("Application startup aborted: %s", error)
        await http_client.aclose()
        raise

    try:
        yield
    finally:
        await http_client.aclose()


# App Check is verified on the GPU VM, which is the machine that actually holds
# the model; this backend only relays the token. See backend/gpu.
router_v1 = APIRouter(prefix="/v1")
router_v1.include_router(ultrasound_conclusion_router)
router_v1.include_router(ultrasound_conclusion_send_email_router)

app = FastAPI(lifespan=lifespan)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.include_router(router_v1)
