from __future__ import annotations

import logging
from typing import Any

import httpx
from fastapi import HTTPException
from pydantic import ValidationError

from app.core.variables import variables
from app.model.runpod_response import RunPodResponse
from app.service.base import InferenceRequest, ModelService

logger = logging.getLogger(__name__)


class RunPodService(ModelService):
    """Fallback inference path: RunPod serverless endpoints.

    No longer the primary route — inference runs on our own GPU VMs (`InferenceService`)
    and only falls through to here when the VM for the model is unavailable.

    RunPod is a third party: it receives no App Check token and verifies nothing.
    Reaching this service therefore relies entirely on the caller having been
    verified at the edge, since this path deliberately bypasses the GPU VM that
    would otherwise verify them again.
    """

    def __init__(self, http_client: httpx.AsyncClient) -> None:
        self._http_client = http_client
        self._api_key = variables.runpod_api_key
        if not variables.runpod_endpoints_path:
            raise RuntimeError("RUNPOD_ENDPOINTS_PATH is not set")
        self._urls = self._load_urls(variables.runpod_endpoints_path)
        self._timeout = variables.runpod_request_timeout_seconds

    async def call(self, request: InferenceRequest) -> str:
        model_id = request.neural_model.id
        url = self._urls.get(model_id)
        if not self._api_key or not url:
            logger.error(
                "RunPod fallback is not configured for model %s: api_key_present=%s, url_present=%s",
                model_id,
                bool(self._api_key),
                bool(url),
            )
            raise HTTPException(status_code=500, detail="Service is not configured")

        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self._api_key}",
        }
        user_content: list[dict[str, Any]] = [
            {
                "type": "text",
                "text": request.prompt,
            }
        ]
        for photo in request.photos:
            user_content.append(
                {
                    "type": "image",
                    "image": f"data:image/jpeg;base64,{photo.data}",
                }
            )
        payload = {
            "input": {
                "messages": [
                    {
                        "role": "system",
                        "content": [{"type": "text", "text": request.system_prompt}],
                    },
                    {
                        "role": "user",
                        "content": user_content,
                    },
                ],
                "sampling_params": {
                    "temperature": request.settings.temperature,
                    "max_tokens": request.settings.maxTokens,
                },
            }
        }
        # Never log the payload contents: it holds patient data and scan images.
        logger.info(
            "RunPod fallback request: model=%s, photos=%d, prompt_chars=%d",
            model_id,
            len(request.photos),
            len(request.prompt),
        )

        try:
            response = await self._http_client.post(url, headers=headers, json=payload, timeout=self._timeout)
        except httpx.HTTPError as error:
            logger.exception("RunPod fallback request failed: %s", error)
            raise HTTPException(status_code=502, detail="Upstream model service is unavailable") from error

        logger.info("RunPod fallback response: status=%d", response.status_code)
        if response.status_code >= 400:
            # The response body may echo the request — log the status only.
            logger.error("RunPod fallback returned error status %d", response.status_code)
            raise HTTPException(status_code=502, detail="Upstream model service returned an error")

        try:
            parsed = RunPodResponse.model_validate(response.json())
            value = parsed.value()
            logger.info("RunPod fallback value: model=%s, chars=%d", model_id, len(value))
            return value
        except (ValueError, ValidationError) as error:
            logger.exception("Failed to parse RunPod fallback response: %s", error)
            raise HTTPException(status_code=502, detail="Invalid response from upstream model service") from error
