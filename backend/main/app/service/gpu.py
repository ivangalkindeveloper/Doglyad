from __future__ import annotations

import logging
from typing import Any

import httpx
from fastapi import HTTPException
from pydantic import ValidationError

from app.core.variables import variables
from app.model.gpu_response import GpuConclusionResponse
from app.service.base import APP_CHECK_HEADER, InferenceRequest, ModelService

logger = logging.getLogger(__name__)


class GpuService(ModelService):
    """Primary inference path: our own GPU VMs, one per model.

    Each VM runs the `backend/gpu` service next to a local vLLM instance holding
    that model.
    This backend stays on a non-GPU machine and only routes: it builds the prompts
    and picks the VM by model id.
    """

    def __init__(self, http_client: httpx.AsyncClient) -> None:
        self._http_client = http_client
        if not variables.gpu_endpoints_path:
            raise RuntimeError("GPU_ENDPOINTS_PATH is not set")
        self._urls = self._load_urls(variables.gpu_endpoints_path)
        self._timeout = variables.gpu_request_timeout_seconds
        logger.info("GPU inference configured for models: %s", ", ".join(sorted(self._urls)) or "none")

    async def call(self, request: InferenceRequest) -> str:
        model_id = request.neural_model.id
        url = self._urls.get(model_id)
        if not url:
            logger.error("No GPU VM is configured for model %s", model_id)
            raise HTTPException(status_code=500, detail="Service is not configured")

        headers = {"Content-Type": "application/json"}
        if request.app_check_token:
            # The GPU VM is the only place App Check is verified: it is exposed on
            # the network and must not serve anyone who merely knows its address.
            headers[APP_CHECK_HEADER] = request.app_check_token

        payload: dict[str, Any] = {
            "modelId": model_id,
            "systemPrompt": request.system_prompt,
            "prompt": request.prompt,
            "photos": [{"data": photo.data} for photo in request.photos],
            "temperature": request.settings.temperature,
            "maxTokens": request.settings.maxTokens,
        }
        # Never log the payload contents: it holds patient data and scan images.
        logger.info(
            "GPU inference request: model=%s, photos=%d, prompt_chars=%d",
            model_id,
            len(request.photos),
            len(request.prompt),
        )

        try:
            response = await self._http_client.post(url, headers=headers, json=payload, timeout=self._timeout)
        except httpx.HTTPError as error:
            logger.exception("GPU inference request failed: %s", error)
            raise HTTPException(status_code=502, detail="GPU model service is unavailable") from error

        logger.info("GPU inference response: status=%d", response.status_code)
        if response.status_code >= 400:
            # The response body may echo the request — log the status only.
            logger.error("GPU inference returned error status %d", response.status_code)
            # 401/403 mean the App Check token did not pass on the GPU VM. Keep the
            # status so the caller is told to re-authenticate instead of being
            # quietly served by the fallback.
            if response.status_code in (401, 403):
                raise HTTPException(status_code=response.status_code, detail="App Check verification failed")
            raise HTTPException(status_code=502, detail="GPU model service returned an error")

        try:
            parsed = GpuConclusionResponse.model_validate(response.json())
            value = parsed.value()
            logger.info("GPU inference value: model=%s, chars=%d", model_id, len(value))
            return value
        except (ValueError, ValidationError) as error:
            logger.exception("Failed to parse GPU inference response: %s", error)
            raise HTTPException(status_code=502, detail="Invalid response from GPU model service") from error
