from __future__ import annotations

import httpx

from app.service.vllm import VLLMService

_service: VLLMService | None = None


def init_services(http_client: httpx.AsyncClient) -> None:
    global _service
    _service = VLLMService(http_client)


def resolve_vllm_service() -> VLLMService:
    if _service is None:
        raise RuntimeError("vLLM service is not initialized")
    return _service
