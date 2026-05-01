from __future__ import annotations

from pydantic import BaseModel


class USExaminationNeuralModel(BaseModel):
    id: str
    title: str
    description: dict[str, str]

    def get_localized_description(self, language_code: str) -> str:
        return self.description.get(language_code) or next(iter(self.description.values()), "")
