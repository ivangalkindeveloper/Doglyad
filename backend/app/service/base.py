from __future__ import annotations

import json
import logging
import os
from abc import ABC, abstractmethod

from app.model.neural_model_settings import NeuralModelSettings
from app.model.ultrasound.us_examination_neural_model import USExaminationNeuralModel
from app.model.ultrasound.us_examination_scan_photo import USExaminationScanPhoto

logger = logging.getLogger(__name__)


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
    def _load_urls(env_var: str) -> dict[str, str]:
        raw = os.getenv(env_var)
        if raw is None or not raw.strip():
            return {}
        text = raw.strip().removeprefix("\ufeff")
        try:
            data = json.loads(text)
        except json.JSONDecodeError as error:
            logger.error("Failed to parse %s as JSON: %s", env_var, error)
            return {}
        if not isinstance(data, dict):
            logger.error("%s must be a JSON object of modelId -> url", env_var)
            return {}
        return {
            str(k): str(v)
            for k, v in data.items()
            if isinstance(v, str) and v.strip()
        }
