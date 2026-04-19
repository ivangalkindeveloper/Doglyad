from __future__ import annotations

import logging
from datetime import datetime, timezone

import httpx
from fastapi import APIRouter, Request

logger = logging.getLogger(__name__)

from app.core.config import (
    VLLM_HOST,
    resolve_examination_title,
    resolve_neural_model,
)
from app.model.neural_model_settings import NeuralModelSettings
from app.model.us_examination_model_conclusion import USExaminationModelConclusion
from app.model.us_examination_neural_model import USExaminationNeuralModel
from app.model.us_examination_request import USExaminationRequest
from app.model.us_examination_scan_photo import USExaminationScanPhoto
from app.core.llm_mode import LLM_MODE, RunMode
from app.prompt import resolve_prompt_factory

router = APIRouter()


@router.post("/ultrasound_conclusion", response_model=USExaminationModelConclusion)
async def ultrasound_conclusion(
    body: USExaminationRequest,
    request: Request,
) -> USExaminationModelConclusion:
    accept_language = request.headers.get("accept-language", "en")
    language_code = accept_language.split("_")[0].strip()
    prompt_factory = resolve_prompt_factory(language_code)

    settings = body.neuralModelSettings
    examination = body.examinationData

    neural_model = resolve_neural_model(
        settings.selectedNeuralModelId
    )
    examination_title = resolve_examination_title(
        examination.usExaminationTypeId,
        language_code,
    )

    logger.info(
        "Request: model=%s, lang=%s, exam=%s, photos=%d, mode=%s",
        neural_model.id, language_code, examination_title,
        len(examination.photos), LLM_MODE,
    )

    match LLM_MODE:
        case RunMode.STUB:
            response_text = prompt_factory.build_stub()
        case RunMode.INFERENCE:
            system_prompt = prompt_factory.build_system_prompt()
            prompt = prompt_factory.build_prompt(
                settings,
                examination,
                examination_title,
                body.template,
            )
            response_text = await _call_vllm(
                neural_model,
                settings,
                system_prompt,
                prompt,
                examination.photos,
            )

    logger.info("Response (first 200 chars): %.200s", response_text)

    return USExaminationModelConclusion(
        date=datetime.now(timezone.utc),
        modelId=neural_model.id,
        response=response_text,
    )


async def _call_vllm(
    neural_model: USExaminationNeuralModel,
    settings: NeuralModelSettings,
    system_prompt: str,
    prompt: str,
    photos: list[USExaminationScanPhoto],
) -> str:
    user_content: list[dict] = [{"type": "text", "text": prompt}]
    for photo in photos:
        user_content.append({
            "type": "image_url",
            "image_url": {"url": f"data:image/jpeg;base64,{photo.data}"},
        })

    payload = {
        "model": neural_model.id,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_content},
        ],
        "temperature": settings.temperature,
        "max_tokens": settings.responseLength,
    }
    url = f"{VLLM_HOST}:{neural_model.port}/v1/chat/completions"
    logger.info("vLLM request: url=%s, model=%s", url, neural_model.id)
    async with httpx.AsyncClient(timeout=120) as client:
        response = await client.post(url, json=payload)
        logger.info("vLLM response: status=%d", response.status_code)
        response.raise_for_status()
        data = response.json()
        return data["choices"][0]["message"]["content"].strip()
