from __future__ import annotations

import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import APIRouter, FastAPI
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from app.core.config import load_configs
from app.core.limiter import limiter

logging.basicConfig(level=logging.INFO)
from app.route.ultrasound_conclusion import router as ultrasound_conclusion_router


@asynccontextmanager
async def lifespan(_app: FastAPI) -> AsyncIterator[None]:
    load_configs()
    yield


router_v1 = APIRouter(prefix="/v1")
router_v1.include_router(ultrasound_conclusion_router)

app = FastAPI(lifespan=lifespan)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.include_router(router_v1)
