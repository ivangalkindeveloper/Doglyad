from __future__ import annotations

import httpx

from app.service.base import ModelService
from app.service.inference import InferenceService


def create_model_service(http_client: httpx.AsyncClient) -> ModelService:
    """Builds the `ModelService` every request goes through.

    The same composition in every environment — `development` and `production`
    differ only in which config directory they read, never in how a conclusion is
    produced. Testing against a real backend is therefore testing the real path.

    Called eagerly at startup, so a broken configuration aborts the process
    instead of failing the first doctor's request. Every configured model is served
    by a dedicated GPU VM selected through the inference endpoint map.
    """
    return InferenceService(http_client)
