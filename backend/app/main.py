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
from app.route.ultrasound_conclusion import router as ultrasound_conclusion_router
from app.service import init_services

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(_app: FastAPI) -> AsyncIterator[None]:
    try:
        load_configs()
    except RuntimeError as error:
        logger.critical("Application startup aborted: %s", error)
        raise

    http_client = httpx.AsyncClient(timeout=120)
    _app.state.http_client = http_client
    init_services(http_client)
    try:
        yield
    finally:
        await http_client.aclose()


router_v1 = APIRouter(prefix="/v1")
router_v1.include_router(ultrasound_conclusion_router)

app = FastAPI(lifespan=lifespan)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.include_router(router_v1)
