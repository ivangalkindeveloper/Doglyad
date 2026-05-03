from __future__ import annotations

from abc import ABC, abstractmethod

from app.model.neural_model_settings import NeuralModelSettings
from app.model.ultrasound.us_examination_data import USExaminationData


class PromptFactory(ABC):

    stub: str

    @abstractmethod
    def system_prompt(
        self,
        settings: NeuralModelSettings
    ) -> str: ...

    @abstractmethod
    def build_prompt(
        self,
        settings: NeuralModelSettings,
        examination: USExaminationData,
        examination_title: str,
        template: str | None = None,
    ) -> str: ...
