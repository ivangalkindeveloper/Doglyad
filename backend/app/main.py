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
STUB_MODE = os.getenv("STUB_MODE", "false").lower() in ("0", "false", "no")

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
        f"STUB: Ultrasound conclusion for {examination.usExaminationTypeId} - no significant pathology detected."
        f"Clinical correlation is recommended."
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
