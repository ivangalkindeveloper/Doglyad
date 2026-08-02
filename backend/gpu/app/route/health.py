from __future__ import annotations

from fastapi import APIRouter
from fastapi.responses import JSONResponse

from app.service import resolve_vllm_service

router = APIRouter()


@router.get("/health")
async def health() -> JSONResponse:
    """Reports whether the local engine has finished loading the model.

    Deliberately outside the App Check-protected router so the VM can be probed
    by infrastructure that holds no app credentials. It exposes nothing beyond
    the model id, which is already public in the app's model list.
    """
    service = resolve_vllm_service()
    is_ready = await service.health()
    return JSONResponse(
        status_code=200 if is_ready else 503,
        content={
            "status": "ok" if is_ready else "unavailable",
            "modelId": service.model_id,
        },
    )
