from __future__ import annotations

import os
from datetime import datetime, timezone

import httpx
from fastapi import FastAPI, Request

from app.model.research_data import ResearchData
from app.model.research_model_conclusion import ResearchModelConclusion

MODEL_ID = "google/medgemma-27b-it"
MODEL_NAME = os.getenv("MODEL_NAME", MODEL_ID)
VLLM_URL = os.getenv("VLLM_URL", "http://localhost:8000")
STUB_MODE = os.getenv("STUB_MODE", "false").lower() in ("0", "false", "no")

app = FastAPI()

@app.post("/conclusion", response_model=ResearchModelConclusion)
async def conclusion(research: ResearchData, request: Request) -> ResearchModelConclusion:
    accept_language = request.headers.get("accept-language", "en")
    locale = accept_language.split(",")[0].strip()

    if STUB_MODE:
        description = build_stub(research, locale)
    else:
        prompt = build_prompt(research, locale)
        description = await call_vllm(prompt)

    return ResearchModelConclusion(
        date=datetime.now(timezone.utc),
        model=MODEL_NAME,
        description=description,
    )

def build_stub(research: ResearchData, locale: str) -> str:
    return (
        f"Ultrasound {research.researchType}: no significant pathology detected. "
        f"Clinical correlation is recommended. Locale: {locale or 'en'}."
    )

def build_prompt(research: ResearchData, locale: str) -> str:
    locale = locale or "en"
    photos_count = len(research.photos)
    complaint = research.patientComplaint or ""
    additional = research.additionalData or ""
    return (
        "Generate a medical ultrasound conclusion.\n"
        f"Answer in locale: {locale}\n"
        f"Research type: {research.researchType}\n"
        f"Patient: {research.patientName}, gender: {research.patientGender}\n"
        f"Date of birth: {research.patientDateOfBirth.date().isoformat()}\n"
        f"Height: {research.patientHeight}, weight: {research.patientWeight}\n"
        f"Complaint: {complaint}\n"
        f"Research description: {research.researchDescription}\n"
        f"Additional data: {additional}\n"
        f"Photos count: {photos_count}\n"
        "Return a full clinical conclusion."
    )

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
