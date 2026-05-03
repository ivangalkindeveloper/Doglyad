from __future__ import annotations

import json
import logging
import os

import httpx
from fastapi import HTTPException
from pydantic import ValidationError

from app.model.neural_model_settings import NeuralModelSettings
from app.model.runpod_response import RunPodResponse
from app.model.ultrasound.us_examination_neural_model import USExaminationNeuralModel
from app.model.ultrasound.us_examination_scan_photo import USExaminationScanPhoto
from app.service.base import ModelService

logger = logging.getLogger(__name__)


class RunPodService(ModelService):

    def __init__(self, http_client: httpx.AsyncClient) -> None:
        self._http_client = http_client
        self._api_key = os.getenv("RUNPOD_API_KEY")
        self._urls = self._load_urls("RUNPOD_URLS")

    async def call(
        self,
        neural_model: USExaminationNeuralModel,
        settings: NeuralModelSettings,
        system_prompt: str,
        prompt: str,
        photos: list[USExaminationScanPhoto],
    ) -> str:
        url = self._urls.get(neural_model.id)
        if not self._api_key or not url:
            logger.error(
                "Inference service is not configured for model %s: api_key_present=%s, url_present=%s",
                neural_model.id, bool(self._api_key), bool(url),
            )
            raise HTTPException(status_code=500, detail="Service is not configured")

        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self._api_key}",
        }
        user_content: list[dict] = [
            {
                "type": "text",
                "text": prompt,
            }
        ]
        for photo in photos:
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
                        "content": [
                            {
                                "type": "text",
                                "text": system_prompt
                            }
                        ],
                    },
                    {
                        "role": "user",
                        "content": user_content,
                    },
                ],
                "sampling_params": {
                    "temperature": settings.temperature,
                    "max_tokens": settings.responseLength
                }
            }
        }
        payload_json = json.dumps(payload, ensure_ascii=False)
        logger.info(
            "Inference request: model=%s url=%s payload=%s",
            neural_model.id,
            url,
            payload_json,
        )

        try:
            response = await self._http_client.post(url, headers=headers, json=payload)
        except httpx.HTTPError as error:
            logger.exception("Inference request failed: %s", error)
            raise HTTPException(status_code=502, detail="Upstream model service is unavailable") from error

        logger.info("Inference response: status=%d", response.status_code)
        if response.status_code >= 400:
            logger.error("Inference upstream returned error status %d: %.500s", response.status_code, response.text)
            raise HTTPException(status_code=502, detail="Upstream model service returned an error")

        try:
            parsed = RunPodResponse.model_validate(response.json())
            value = parsed.value()
            logger.info("Inference value: model=%s", value)
            return value    
        except (ValueError, ValidationError) as error:
            logger.exception("Failed to parse inference response: %s", error)
            raise HTTPException(status_code=502, detail="Invalid response from upstream model service") from error