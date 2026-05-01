from __future__ import annotations

import json
import logging
import os
from pathlib import Path

from fastapi import HTTPException

from app.model.ultrasound.us_examination_neural_model import USExaminationNeuralModel
from app.model.ultrasound.us_examination_type import USExaminationType

logger = logging.getLogger(__name__)

ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
CONFIG_DIR = Path(os.getenv("CONFIG_DIR", str(Path(__file__).resolve().parent.parent.parent / "config"))) / ENVIRONMENT

neural_models: dict[str, USExaminationNeuralModel] = {}
examination_types: dict[str, USExaminationType] = {}


def _load_json_array(path: Path) -> list[dict]:
    if not path.exists():
        raise RuntimeError(f"Config file not found: {path}")
    try:
        with open(path, encoding="utf-8") as file:
            data = json.load(file)
    except json.JSONDecodeError as error:
        raise RuntimeError(f"Invalid JSON in config file {path}: {error}") from error
    if not isinstance(data, list):
        raise RuntimeError(f"Config file {path} must contain a JSON array")
    return data


def load_configs() -> None:
    try:
        for item in _load_json_array(CONFIG_DIR / "ultrasound_examination_neural_models.json"):
            model = USExaminationNeuralModel(**item)
            neural_models[model.id] = model

        for item in _load_json_array(CONFIG_DIR / "ultrasound_examination_types.json"):
            examination_type = USExaminationType(**item)
            examination_types[examination_type.id] = examination_type
    except Exception as error:
        logger.exception("Failed to load application configs from %s", CONFIG_DIR)
        raise RuntimeError(f"Failed to load configs from {CONFIG_DIR}: {error}") from error


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
