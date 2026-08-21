from __future__ import annotations

from pydantic import BaseModel

from app.model.ultrasound.us_examination_neural_model_accessibility import (
    USExaminationNeuralModelAccessibility,
)


class USExaminationNeuralModel(BaseModel):
    id: str
    title: str
    accessibility: USExaminationNeuralModelAccessibility
    description: dict[str, str]

    def get_localized_description(self, language_code: str) -> str:
        return self.description.get(language_code) or next(iter(self.description.values()), "")
