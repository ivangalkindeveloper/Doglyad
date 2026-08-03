from __future__ import annotations

import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

import httpx
from fastapi import APIRouter, Depends, FastAPI

from app.core.app_check import init_app_check, verify_app_check
from app.core.logging import setup_logging
from app.core.variables import variables
from app.route.conclusion_generation import router as conclusion_generation_router
from app.service import init_services

setup_logging()
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(_app: FastAPI) -> AsyncIterator[None]:
    http_client = httpx.AsyncClient(timeout=variables.vllm_request_timeout_seconds)
    _app.state.http_client = http_client

    try:
        init_app_check()
        init_services(http_client)
    except RuntimeError as error:
        logger.critical("Application startup aborted: %s", error)
        await http_client.aclose()
        raise

    logger.info(
        "Inference service started: model=%s, vllm=%s",
        variables.served_model_id,
        variables.vllm_base_url,
    )

    try:
        yield
    finally:
        await http_client.aclose()


router_v1 = APIRouter(prefix="/v1", dependencies=[Depends(verify_app_check)])
router_v1.include_router(conclusion_generation_router)

app = FastAPI(lifespan=lifespan)
app.include_router(router_v1)
