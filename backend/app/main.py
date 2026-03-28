from __future__ import annotations

import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import APIRouter, FastAPI

from app.core.config import load_configs

logging.basicConfig(level=logging.INFO)
from app.route.ultrasound_conclusion import router as ultrasound_conclusion_router


@asynccontextmanager
async def lifespan(_app: FastAPI) -> AsyncIterator[None]:
    load_configs()
    yield


router_v1 = APIRouter(prefix="/v1")
router_v1.include_router(ultrasound_conclusion_router)

app = FastAPI(lifespan=lifespan)
app.include_router(router_v1)
