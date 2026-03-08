from __future__ import annotations

import json
import os
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from enum import Enum
from pathlib import Path

import httpx

from fastapi import FastAPI, HTTPException, Request

from app.model.neural_model_settings import NeuralModelSettings
from app.model.us_examination_data import USExaminationData
from app.model.us_examination_model_conclusion import USExaminationModelConclusion
from app.model.us_examination_neural_model import USExaminationNeuralModel
from app.model.us_examination_request import USExaminationRequest
from app.model.us_examination_scan_photo import USExaminationScanPhoto
from app.model.us_examination_type import USExaminationType

class RunMode(str, Enum):
    STUB = "stub"
    MODEL = "model"

RUN_MODE = RunMode(os.getenv("RUN_MODE", "stub").lower())
VLLM_HOST = os.getenv("VLLM_HOST", "http://host.docker.internal")
CONFIG_DIR = Path(__file__).resolve().parent.parent / "config"

neural_models: dict[str, USExaminationNeuralModel] = {}
examination_types: dict[str, USExaminationType] = {}

@asynccontextmanager
async def lifespan(_app: FastAPI) -> AsyncIterator[None]:
    load_configs()
    yield

app = FastAPI(lifespan=lifespan)

def load_configs() -> None:
    models_path = CONFIG_DIR / "ultrasound_examination_neural_models.json"
    with open(models_path, encoding="utf-8") as file:
        for item in json.load(file):
            model = USExaminationNeuralModel(**item)
            neural_models[model.id] = model

    types_path = CONFIG_DIR / "ultrasound_examination_types.json"
    with open(types_path, encoding="utf-8") as file:
        for item in json.load(file):
            examination_type = USExaminationType(**item)
            examination_types[examination_type.id] = examination_type

def resolve_neural_model(selected_id: str | None) -> USExaminationNeuralModel:
    if not selected_id:
        return next(iter(neural_models.values()))
    model = neural_models.get(selected_id)
    if not model:
        raise HTTPException(
            status_code=400,
            detail=f"Unknown neural model id: {selected_id}",
        )
    return model


def resolve_examination_title(type_id: str, locale: str) -> str:
    examination_type = examination_types.get(type_id)
    if not examination_type:
        raise HTTPException(
            status_code=400,
            detail=f"Unknown examination type id: {type_id}",
        )
    return examination_type.get_localized_title(locale)


@app.post("/ultrasound_conclusion", response_model=USExaminationModelConclusion)
async def ultrasound_conclusion(
    body: USExaminationRequest,
    request: Request
) -> USExaminationModelConclusion:
    accept_language = request.headers.get("accept-language", "en")
    locale = accept_language.split(",")[0].strip()

    settings = body.neuralModelSettings
    examination = body.examinationData

    neural_model = resolve_neural_model(settings.selectedNeuralModelId)
    examination_title = resolve_examination_title(
        examination.usExaminationTypeId,
        locale,
    )

    match RUN_MODE:
        case RunMode.STUB:
            response_text = build_stub(
                examination,
                examination_title,
            )
        case RunMode.MODEL:
            response_text = await call_vllm(
                neural_model,
                build_system_prompt(),
                build_prompt(
                    settings,
                    examination,
                    examination_title,
                    locale,
                ),
                examination.photos,
            )

    return USExaminationModelConclusion(
        date=datetime.now(timezone.utc),
        modelId=neural_model.id,
        response=response_text,
    )


def build_stub(examination: USExaminationData, examination_title: str) -> str:
    return (
        f"STUB Ultrasound Examination Report: {examination_title}.\n"
        f"Patient: {examination.patientName}.\n"
        f"The examination was performed using an expert-class ultrasound system "
        f"equipped with a multifrequency convex transducer (3.5–7.5 MHz) "
        f"and a linear transducer (7.5–12 MHz). "
        f"Scanning was carried out in standard longitudinal, transverse, and oblique planes "
        f"utilizing B-mode grayscale imaging, color Doppler flow mapping (CDFM), "
        f"and pulsed-wave Doppler.\n\n"
        f"Findings: the visualized structures are located in their typical anatomical positions "
        f"with preserved topographic relationships. "
        f"Organ contours are smooth and well-defined; the capsule is clearly delineated throughout. "
        f"Parenchymal echogenicity is within normal limits and comparable to that of surrounding tissues. "
        f"The echostructure is homogeneous and finely granular with no focal abnormalities identified. "
        f"Color Doppler flow mapping demonstrates a normal vascular pattern "
        f"with symmetric blood flow and no hemodynamically significant disturbances. "
        f"Peak systolic velocities and resistive indices are within reference ranges. "
        f"The ductal system shows no signs of dilation; no calculi are detected. "
        f"The perivisceral fat appears unremarkable with no infiltrative changes. "
        f"Regional lymph nodes are not enlarged, displaying a normal oval morphology "
        f"with preserved corticomedullary differentiation.\n\n"
        f"Conclusion: the ultrasound examination reveals no evidence of focal "
        f"or diffuse pathology in the examined region. "
        f"The sonographic findings are consistent with age-appropriate normal anatomy. "
        f"No pathological free gas or fluid is identified within the scanning field. "
        f"Clinical and laboratory correlation of the obtained results is recommended. "
        f"If clinically indicated, a follow-up ultrasound examination "
        f"in 6 to 12 months is advisable."
    )

def build_system_prompt() -> str:
    return (
        "You are an AI assistant specialized in generating medical ultrasound examination reports. "
        "Your task is to produce clinical conclusions that physicians rely on "
        "for diagnosis and treatment planning. "
        "Write only the medical conclusion based strictly on the provided examination data and images. "
        "Do not infer, assume, or fabricate any findings that are not supported by the input. "
        "Use precise medical terminology appropriate for a formal radiology report. "
        "If the provided data is insufficient to assess a specific structure, "
        "state that it was not adequately visualized rather than speculating. "
        "Structure the report with findings followed by a conclusion."
    )

def build_prompt(
    settings: NeuralModelSettings,
    examination: USExaminationData,
    examination_title: str,
    locale: str,
) -> str:
    base = (
        f"Generate a medical ultrasound conclusion for data:\n"
        f"Ultrasound examination type: {examination_title}\n"
        f"Patient name: {examination.patientName}\n"
        f"Patient gender: {examination.patientGender}\n"
        f"Patient date of birth: {examination.patientDateOfBirth.date().isoformat()}\n"
        f"Patient height: {examination.patientHeight}\n"
        f"Patient weight: {examination.patientWeight}\n"
        f"Ultrasound examination description: {examination.examinationDescription}\n"
    )

    if examination.patientComplaint:
        base += f"Patient complaint: {examination.patientComplaint}\n"
    if examination.additionalData:
        base += f"Additional data: {examination.additionalData}\n"

    if settings.template:
        base += f"Response template: {settings.template}\n"
    if settings.responseLength:
        base += f"Maximum response length (tokens): {settings.responseLength}\n"
        
    base += "Answer in locale: {locale}\n"
    base += "Return a full clinical conclusion."
    return base


async def call_vllm(
    neural_model: USExaminationNeuralModel,
    system_prompt: str,
    prompt: str,
    photos: list[USExaminationScanPhoto],
) -> str:
    user_content: list[dict] = [{"type": "text", "text": prompt}]
    for photo in photos:
        user_content.append({
            "type": "image_url",
            "image_url": {"url": f"data:image/jpeg;base64,{photo.imageData}"},
        })

    payload = {
        "model": neural_model.id,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_content},
        ],
        "temperature": 0.2,
        "max_tokens": 512,
    }
    url = f"{VLLM_HOST}:{neural_model.port}/v1/chat/completions"
    async with httpx.AsyncClient(timeout=120) as client:
        response = await client.post(url, json=payload)
        response.raise_for_status()
        data = response.json()
        return data["choices"][0]["message"]["content"].strip()
