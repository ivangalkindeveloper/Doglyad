from __future__ import annotations

import logging

import httpx

from app.core.variables import variables
from app.service.base import ModelService
from app.service.fallback import FallbackModelService
from app.service.inference import InferenceService
from app.service.runpod import RunPodService

logger = logging.getLogger(__name__)


def create_model_service(http_client: httpx.AsyncClient) -> ModelService:
    """Builds the `ModelService` every request goes through: GPU VMs, RunPod behind.

    The same composition in every environment — `development` and `production`
    differ only in which config directory they read, never in how a conclusion is
    produced. Testing against a real backend is therefore testing the real path.

    Called eagerly at startup, so a broken configuration aborts the process
    instead of failing the first doctor's request. A missing inference map raises:
    it is the path every request takes. A missing RunPod configuration only warns
    — without it a GPU VM failure surfaces to the client instead of being absorbed.
    """
    primary = InferenceService(http_client)

    fallback = _create_fallback(http_client)
    if fallback is None:
        logger.warning("RunPod fallback is not configured: a GPU VM failure will fail the request")
        return primary

    return FallbackModelService(primary, fallback)


def _create_fallback(http_client: httpx.AsyncClient) -> ModelService | None:
    if not variables.runpod_api_key or not variables.runpod_endpoints_path:
        return None
    try:
        return RunPodService(http_client)
    except RuntimeError as error:
        logger.warning("RunPod fallback is unavailable: %s", error)
        return None
