from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class VLLMMessage(BaseModel):
    model_config = ConfigDict(extra="ignore")

    content: str | None = None


class VLLMChoice(BaseModel):
    model_config = ConfigDict(extra="ignore")

    message: VLLMMessage
    finish_reason: str | None = None


class VLLMUsage(BaseModel):
    model_config = ConfigDict(extra="ignore")

    prompt_tokens: int = 0
    completion_tokens: int = 0


class VLLMChatCompletion(BaseModel):
    """The `/v1/chat/completions` payload of the local vLLM OpenAI-compatible server."""

    model_config = ConfigDict(extra="ignore")

    choices: list[VLLMChoice]
    usage: VLLMUsage | None = None

    def value(self) -> str:
        if not self.choices:
            raise ValueError("vLLM response has empty choices")
        content = self.choices[0].message.content
        if not content:
            raise ValueError("vLLM response has empty message content")
        text = content.strip()
        if not text:
            raise ValueError("vLLM response content contains no text")
        return text
