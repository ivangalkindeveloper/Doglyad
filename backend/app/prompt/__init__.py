from __future__ import annotations

from app.prompt.base import PromptFactory
from app.prompt.en import PromptFactoryEn
from app.prompt.ru import PromptFactoryRu

_FACTORIES: dict[str, PromptFactory] = {
    "en": PromptFactoryEn(),
    "ru": PromptFactoryRu(),
}

def resolve_prompt_factory(language_code: str) -> PromptFactory:
    return _FACTORIES.get(language_code, PromptFactoryEn())
