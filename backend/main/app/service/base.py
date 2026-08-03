from __future__ import annotations

import json
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from pathlib import Path

from app.model.neural_model_settings import NeuralModelSettings
from app.model.ultrasound.us_examination_neural_model import USExaminationNeuralModel
from app.model.ultrasound.us_examination_scan_photo import USExaminationScanPhoto


@dataclass(frozen=True)
class InferenceRequest:
    """Everything a `ModelService` needs to produce one conclusion.

    Grouped into an object rather than passed as positional arguments: the
    implementations need different subsets of it — RunPod ignores the App Check
    token, our own VMs need it — and a shared shape keeps the route from having
    to know which.
    """

    neural_model: USExaminationNeuralModel
    settings: NeuralModelSettings
    # Resolved from the Accept-Language header. The services get it baked into the
    # prompts already; kept here so a failure can be reported in the right language.
    language_code: str
    system_prompt: str
    prompt: str
    photos: list[USExaminationScanPhoto] = field(default_factory=list)
    # The caller's App Check token, already verified at the edge and relayed
    # unchanged to the GPU VM, which verifies it again. Services that call a
    # third party ignore it.
    app_check_token: str | None = None


class ModelService(ABC):
    @abstractmethod
    async def call(self, request: InferenceRequest) -> str:
        """Runs one generation and returns the conclusion text."""
        ...

    @staticmethod
    def _load_urls(path: Path) -> dict[str, str]:
        # A JSON object of modelId -> URL. For RunPod it is written by
        # scripts/runpod_sync.py; for the GPU VMs it is maintained by hand, one
        # entry per machine.
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
