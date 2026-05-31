from __future__ import annotations

from pathlib import Path

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

from app.core.llm_mode import LLMMode


class Variables(BaseSettings):
    model_config = SettingsConfigDict(extra="ignore")

    environment: str

    config_dir: Path | None = None

    llm_mode: LLMMode = LLMMode.STUB

    email_sender: str | None = None
    email_password: str | None = None
    email_smtp_host: str | None = None
    email_smtp_port: int | None = None

    runpod_api_key: str | None = None
    runpod_urls: str | None = None

    @field_validator("llm_mode", mode="before")
    @classmethod
    def _normalize_llm_mode(cls, value: object) -> object:
        if isinstance(value, str):
            return value.lower()
        return value


variables = Variables()
