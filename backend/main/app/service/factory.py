from __future__ import annotations

import logging
from typing import assert_never

import httpx

from app.core.llm_mode import LLMMode
from app.core.variables import variables
from app.service.base import ModelService
from app.service.fallback import FallbackModelService
from app.service.inference import InferenceService
from app.service.runpod import RunPodService
from app.service.stub import StubModelService

logger = logging.getLogger(__name__)


class ServiceFactory:
    """Builds and hands out the `ModelService` for the configured LLM mode.

    The single place that branches on `LLMMode`. Routes ask for a service and
    call it — they no longer decide what a mode means, so adding a mode cannot
    leave a route silently unaware of it.

    Construction is eager: a broken configuration aborts startup instead of
    failing the first doctor's request.
    """

    def __init__(self, http_client: httpx.AsyncClient, mode: LLMMode) -> None:
        self._services: dict[LLMMode, ModelService] = {mode: self._create(http_client, mode)}

    def resolve(self, mode: LLMMode) -> ModelService:
        service = self._services.get(mode)
        if service is None:
            raise ValueError(f"No model service registered for mode: {mode}")
        return service

    @staticmethod
    def _create(http_client: httpx.AsyncClient, mode: LLMMode) -> ModelService:
        match mode:
            case LLMMode.STUB:
                return StubModelService()
            case LLMMode.INFERENCE:
                return ServiceFactory._create_inference(http_client)
        assert_never(mode)

    @staticmethod
    def _create_inference(http_client: httpx.AsyncClient) -> ModelService:
        """Our GPU VMs first, RunPod behind them.

        A missing inference configuration raises — it is the path every request takes.
        A missing RunPod configuration only warns: without it a GPU failure
        surfaces to the client instead of being absorbed.
        """
        primary = InferenceService(http_client)

        fallback = ServiceFactory._create_fallback(http_client)
        if fallback is None:
            logger.warning("RunPod fallback is not configured: a GPU VM failure will fail the request")
            return primary

        return FallbackModelService(primary, fallback)

    @staticmethod
    def _create_fallback(http_client: httpx.AsyncClient) -> ModelService | None:
        if not variables.runpod_api_key or not variables.runpod_endpoints_path:
            return None
        try:
            return RunPodService(http_client)
        except RuntimeError as error:
            logger.warning("RunPod fallback is unavailable: %s", error)
            return None
