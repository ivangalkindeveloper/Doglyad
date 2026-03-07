from __future__ import annotations

import os
from datetime import datetime, timezone

import httpx
from fastapi import FastAPI, Request

from app.model.neural_model_settings import NeuralModelSettings
from app.model.us_examination_data import USExaminationData
from app.model.us_examination_model_conclusion import USExaminationModelConclusion
from app.model.us_examination_request import USExaminationRequest

MODEL_ID = "google/medgemma-27b-it"
MODEL_NAME = os.getenv("MODEL_NAME", MODEL_ID)
VLLM_URL = os.getenv("VLLM_URL", "http://localhost:8000")
STUB_MODE = os.getenv("STUB_MODE", "false").lower() in ("1", "true", "yes")

app = FastAPI()

@app.post("/ultrasound_conclusion", response_model=USExaminationModelConclusion)
async def conclusion(body: USExaminationRequest, request: Request) -> USExaminationModelConclusion:
    accept_language = request.headers.get("accept-language", "en")
    locale = accept_language.split(",")[0].strip()

    settings = body.neuralModelSettings
    examination = body.examinationData

    if STUB_MODE:
        response_text = build_stub(examination)
    else:
        prompt = build_prompt(settings, examination, locale)
        response_text = await call_vllm(prompt)

    return USExaminationModelConclusion(
        date=datetime.now(timezone.utc),
        modelId=MODEL_NAME,
        response=response_text,
    )

def build_stub(examination: USExaminationData) -> str:
    return (
        f"Ultrasound Examination Report ({examination.usExaminationTypeId}).\n\n"
        f"Patient: {examination.patientName}. "
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

def build_prompt(
    settings: NeuralModelSettings,
    examination: USExaminationData,
    locale: str,
) -> str:
    photos_count = len(examination.photos)
    complaint = examination.patientComplaint or ""
    additional = examination.additionalData or ""

    base = (
        "Generate a medical ultrasound conclusion.\n"
        f"Answer in locale: {locale}\n"
        f"Examination type: {examination.usExaminationTypeId}\n"
        f"Patient: {examination.patientName}, gender: {examination.patientGender}\n"
        f"Date of birth: {examination.patientDateOfBirth.date().isoformat()}\n"
        f"Height: {examination.patientHeight}, weight: {examination.patientWeight}\n"
        f"Complaint: {complaint}\n"
        f"Examination description: {examination.examinationDescription}\n"
        f"Additional data: {additional}\n"
        f"Photos count: {photos_count}\n"
    )

    if settings.template:
        base += f"Response template: {settings.template}\n"
    if settings.responseLength is not None:
        base += f"Maximum response length (tokens): {settings.responseLength}\n"

    base += "Return a full clinical conclusion."
    return base

async def call_vllm(prompt: str) -> str:
    system_prompt = "You are a medical assistant."
    payload = {
        "model": MODEL_NAME,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt},
        ],
        "temperature": 0.2,
        "max_tokens": 512,
    }
    async with httpx.AsyncClient(timeout=60) as client:
        response = await client.post(f"{VLLM_URL}/v1/chat/completions", json=payload)
        response.raise_for_status()
        data = response.json()
        return data["choices"][0]["message"]["content"].strip()
