from __future__ import annotations

import json
from abc import ABC, abstractmethod
from pathlib import Path

from app.model.neural_model_settings import NeuralModelSettings
from app.model.ultrasound.us_examination_neural_model import USExaminationNeuralModel
from app.model.ultrasound.us_examination_scan_photo import USExaminationScanPhoto


class ModelService(ABC):
    @abstractmethod
    async def call(
        self,
        neural_model: USExaminationNeuralModel,
        settings: NeuralModelSettings,
        system_prompt: str,
        prompt: str,
        photos: list[USExaminationScanPhoto],
    ) -> str: ...

    @staticmethod
    def _load_urls(path: Path) -> dict[str, str]:
        # Written by scripts/runpod_sync.py: a JSON object of modelId -> endpoint URL.
        if not path.exists():
            raise RuntimeError(f"Model URLs file not found: {path}")
        try:
            with open(path, encoding="utf-8-sig") as file:
                data = json.load(file)
        except (OSError, json.JSONDecodeError) as error:
            raise RuntimeError(f"Failed to read model URLs from {path}: {error}") from error
        if not isinstance(data, dict):
            raise RuntimeError(f"Model URLs file {path} must contain a JSON object of modelId -> url")
        return {str(k): str(v) for k, v in data.items() if isinstance(v, str) and v.strip()}
