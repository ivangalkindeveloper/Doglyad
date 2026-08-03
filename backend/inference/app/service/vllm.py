from __future__ import annotations

import logging
from typing import Any

import httpx
from fastapi import HTTPException
from pydantic import ValidationError

from app.core.variables import variables
from app.model.conclusion_generation_request import ConclusionGenerationRequest
from app.model.vllm_response import VLLMChatCompletion

logger = logging.getLogger(__name__)


class VLLMService:
    """Talks to the vLLM OpenAI-compatible server running next to this service.

    The server lives in the same Docker network on the same GPU VM, so the call is
    local: no public network hop, no per-request billing, no cold start beyond the
    one the VM pays once at boot.
    """

    def __init__(self, http_client: httpx.AsyncClient) -> None:
        self._http_client = http_client
        self._base_url = variables.vllm_base_url.rstrip("/")
        self._model_id = variables.served_model_id
        self._timeout = variables.vllm_request_timeout_seconds

    @property
    def model_id(self) -> str:
        return self._model_id

    async def generate(self, request: ConclusionGenerationRequest) -> str:
        # One VM per model: answering for a different id would silently return a
        # conclusion from a model the doctor did not choose.
        if request.modelId != self._model_id:
            logger.error(
                "Model mismatch: requested=%s, served=%s",
                request.modelId,
                self._model_id,
            )
            raise HTTPException(
                status_code=400,
                detail=f"This service serves {self._model_id}, not {request.modelId}",
            )

        user_content: list[dict[str, Any]] = [{"type": "text", "text": request.prompt}]
        for photo in request.photos:
            user_content.append(
                {
                    "type": "image_url",
                    "image_url": {"url": f"data:image/jpeg;base64,{photo.data}"},
                }
            )
        payload: dict[str, Any] = {
            "model": self._model_id,
            "messages": [
                {
                    "role": "system",
                    "content": [{"type": "text", "text": request.systemPrompt}],
                },
                {
                    "role": "user",
                    "content": user_content,
                },
            ],
        }
        # Omit rather than send nulls: unset means "use the engine default".
        if request.temperature is not None:
            payload["temperature"] = request.temperature
        if request.maxTokens is not None:
            payload["max_tokens"] = request.maxTokens

        headers = {"Content-Type": "application/json"}
        if variables.vllm_api_key:
            headers["Authorization"] = f"Bearer {variables.vllm_api_key}"

        # Never log the payload contents: it holds patient data and scan images.
        logger.info(
            "vLLM request: model=%s, photos=%d, prompt_chars=%d",
            self._model_id,
            len(request.photos),
            len(request.prompt),
        )

        try:
            response = await self._http_client.post(
                f"{self._base_url}/v1/chat/completions",
                headers=headers,
                json=payload,
                timeout=self._timeout,
            )
        except httpx.HTTPError as error:
            logger.exception("vLLM request failed: %s", error)
            raise HTTPException(status_code=502, detail="Local model engine is unavailable") from error

        logger.info("vLLM response: status=%d", response.status_code)
        if response.status_code >= 400:
            # The response body may echo the request — log the status only.
            logger.error("vLLM returned error status %d", response.status_code)
            raise HTTPException(status_code=502, detail="Local model engine returned an error")

        try:
            parsed = VLLMChatCompletion.model_validate(response.json())
            value = parsed.value()
        except (ValueError, ValidationError) as error:
            logger.exception("Failed to parse vLLM response: %s", error)
            raise HTTPException(status_code=502, detail="Invalid response from local model engine") from error

        usage = parsed.usage
        logger.info(
            "vLLM value: model=%s, chars=%d, prompt_tokens=%d, completion_tokens=%d",
            self._model_id,
            len(value),
            usage.prompt_tokens if usage else 0,
            usage.completion_tokens if usage else 0,
        )
        return value
