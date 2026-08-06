from __future__ import annotations

import json
import logging
from pathlib import Path

from fastapi import HTTPException

from app.core.variables import variables
from app.model.ultrasound.us_examination_neural_model import USExaminationNeuralModel
from app.model.ultrasound.us_examination_type import USExaminationType

logger = logging.getLogger(__name__)

_CONFIG_BASE = variables.config_dir or (Path(__file__).resolve().parent.parent.parent / "config")
_CONFIG_DIR = _CONFIG_BASE / variables.environment

neural_models: dict[str, USExaminationNeuralModel] = {}
examination_types: dict[str, USExaminationType] = {}

# The documents the app reads at startup, served verbatim from the image. Keeping
# the app and this backend on one source removes the window in which the app
# offers a model the backend has not been redeployed to know about.
SERVED_DOCUMENTS = (
    "application.json",
    "ultrasound_examination_types.json",
    "ultrasound_examination_neural_models.json",
    "ultrasound_examination_contextual_strings.json",
)

_served_documents: dict[str, str] = {}


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


def _read_document(path: Path) -> str:
    if not path.exists():
        raise RuntimeError(f"Config file not found: {path}")
    text = path.read_text(encoding="utf-8")
    # Parsed once here only to fail at startup rather than in the app's face; what
    # is served is the original text, so nothing is lost in a re-serialization.
    try:
        json.loads(text)
    except json.JSONDecodeError as error:
        raise RuntimeError(f"Invalid JSON in config file {path}: {error}") from error
    return text


def load_configs() -> None:
    try:
        for item in _load_json_array(_CONFIG_DIR / "ultrasound_examination_neural_models.json"):
            model = USExaminationNeuralModel(**item)
            neural_models[model.id] = model

        for item in _load_json_array(_CONFIG_DIR / "ultrasound_examination_types.json"):
            examination_type = USExaminationType(**item)
            examination_types[examination_type.id] = examination_type

        for name in SERVED_DOCUMENTS:
            _served_documents[name] = _read_document(_CONFIG_DIR / name)
    except Exception as error:
        logger.exception("Failed to load application configs from %s", _CONFIG_DIR)
        raise RuntimeError(f"Failed to load configs from {_CONFIG_DIR}: {error}") from error


def resolve_config_document(name: str) -> str:
    """The raw text of a config document, for serving to the app.

    Read once at startup: these files ship inside the image and cannot change
    under a running process.

    Each route asks for a fixed name, so a miss here is a programming error and
    not something a caller can provoke — hence `KeyError` rather than a 404.
    """
    return _served_documents[name]


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
