from pydantic import BaseModel


class USExaminationType(BaseModel):
    id: str
    title: dict[str, str]

    def get_localized_title(self, locale: str) -> str:
        lang = locale.split("-")[0]
        return self.title.get(lang) or next(iter(self.title.values()), "")
