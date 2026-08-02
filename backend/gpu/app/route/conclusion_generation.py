from __future__ import annotations

import logging

from fastapi import APIRouter

from app.model.conclusion_generation_request import ConclusionGenerationRequest
from app.model.conclusion_generation_response import ConclusionGenerationResponse
from app.service import resolve_vllm_service

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/conclusion_generation", response_model=ConclusionGenerationResponse)
async def conclusion_generation(body: ConclusionGenerationRequest) -> ConclusionGenerationResponse:
    """Generates one conclusion with the model deployed on this VM.

    No rate limiting here: the only caller is the backend, which already limits
    per client address. Keying a limiter on the caller's address would put every
    doctor behind the backend's single IP into one bucket.
    """
    service = resolve_vllm_service()
    value = await service.generate(body)
    return ConclusionGenerationResponse(modelId=service.model_id, response=value)
