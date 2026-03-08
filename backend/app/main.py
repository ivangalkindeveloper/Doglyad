from __future__ import annotations

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.core.config import load_configs
from app.route.ultrasound_conclusion import router as ultrasound_conclusion_router


@asynccontextmanager
async def lifespan(_app: FastAPI) -> AsyncIterator[None]:
    load_configs()
    yield


app = FastAPI(lifespan=lifespan)
app.include_router(ultrasound_conclusion_router)
