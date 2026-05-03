from __future__ import annotations

import httpx

from app.core.llm_mode import LLM_MODE, LLMMode
from app.service.base import ModelService
from app.service.runpod import RunPodService

_SERVICES: dict[LLMMode, ModelService] = {}


def init_services(http_client: httpx.AsyncClient) -> None:
    _SERVICES.clear()
    if LLM_MODE is LLMMode.RUNPOD:
        _SERVICES[LLMMode.RUNPOD] = RunPodService(http_client)


def resolve_model_service(mode: LLMMode) -> ModelService:
    service = _SERVICES.get(mode)
    if not service:
        raise ValueError(f"No model service registered for mode: {mode}")
    return service
