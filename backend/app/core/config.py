from __future__ import annotations

import json
import os
from pathlib import Path

from fastapi import HTTPException

from app.model.us_examination_neural_model import USExaminationNeuralModel
from app.model.us_examination_type import USExaminationType

VLLM_HOST = os.getenv("VLLM_HOST", "http://host.docker.internal")
CONFIG_DIR = Path(os.getenv("CONFIG_DIR", Path(__file__).resolve().parent.parent.parent / "config"))

neural_models: dict[str, USExaminationNeuralModel] = {}
examination_types: dict[str, USExaminationType] = {}


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


def resolve_examination_title(type_id: str, language_code: str) -> str:
    examination_type = examination_types.get(type_id)
    if not examination_type:
        raise HTTPException(
            status_code=400,
            detail=f"Unknown examination type id: {type_id}",
        )
    return examination_type.get_localized_title(language_code)
