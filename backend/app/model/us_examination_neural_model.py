from pydantic import BaseModel


class USExaminationNeuralModel(BaseModel):
    id: str
    title: str
    port: int
    description: dict[str, str]

    def get_localized_description(self, language_code: str) -> str:
        return self.description.get(language_code) or next(iter(self.description.values()), "")
