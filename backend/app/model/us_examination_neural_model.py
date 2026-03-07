from pydantic import BaseModel


class USExaminationNeuralModel(BaseModel):
    id: str
    title: str
    description: dict[str, str]

    def get_localized_description(self, locale: str) -> str:
        lang = locale.split("-")[0]
        return self.description.get(lang) or next(iter(self.description.values()), "")
