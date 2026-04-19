from __future__ import annotations

from abc import ABC, abstractmethod

from app.model.neural_model_settings import NeuralModelSettings
from app.model.us_examination_data import USExaminationData


class PromptFactory(ABC):

    @abstractmethod
    def build_stub(self) -> str: ...

    @abstractmethod
    def build_system_prompt(self) -> str: ...

    @abstractmethod
    def build_prompt(
        self,
        settings: NeuralModelSettings,
        examination: USExaminationData,
        examination_title: str,
        template: str | None = None,
    ) -> str: ...
