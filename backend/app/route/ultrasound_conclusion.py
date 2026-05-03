from __future__ import annotations

import logging
from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException, Request

from app.core.config import (
    resolve_examination_title,
    resolve_neural_model,
)
from app.core.limiter import limiter
from app.core.llm_mode import LLM_MODE, RunMode
from app.model.ultrasound.us_examination_model_conclusion import USExaminationModelConclusion
from app.model.ultrasound.us_examination_request import USExaminationRequest
from app.prompt import resolve_prompt_factory
from app.service import resolve_model_service

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/ultrasound_conclusion", response_model=USExaminationModelConclusion)
@limiter.limit("30/minute")
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
            response_text = prompt_factory.stub
        case RunMode.RUNPOD:
            prompt = prompt_factory.build_prompt(
                examination,
                examination_title,
                body.template,
            )
            model_service = resolve_model_service(LLM_MODE)
            response_text = await model_service.call(
                neural_model,
                settings,
                prompt_factory.system_prompt,
                prompt,
                examination.photos,
            )
        case _:
            logger.error("Unsupported LLM_MODE: %s", LLM_MODE)
            raise HTTPException(status_code=500, detail="Unsupported LLM mode")

    return USExaminationModelConclusion(
        date=datetime.now(timezone.utc),
        modelId=neural_model.id,
        response=response_text,
    )
