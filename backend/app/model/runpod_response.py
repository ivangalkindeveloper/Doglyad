from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class RunPodChoice(BaseModel):
    model_config = ConfigDict(extra="ignore")

    tokens: list[str]


class RunPodUsage(BaseModel):
    model_config = ConfigDict(populate_by_name=True, extra="ignore")

    input_tokens: int = Field(alias="input")
    output_tokens: int = Field(alias="output")


class RunPodOutputItem(BaseModel):
    model_config = ConfigDict(extra="ignore")

    choices: list[RunPodChoice]
    usage: RunPodUsage | None = None


class RunPodResponse(BaseModel):
    model_config = ConfigDict(populate_by_name=True, extra="ignore")

    delay_time: int = Field(alias="delayTime")
    execution_time: int = Field(alias="executionTime")
    sync_id: str = Field(alias="id")
    output: list[RunPodOutputItem]
    status: str
    worker_id: str = Field(alias="workerId")

    def value(self) -> str:
        if not self.output:
            raise ValueError("RunPod response has empty output")
        choices = self.output[0].choices
        if not choices:
            raise ValueError("RunPod response has empty choices")
        tokens = choices[0].tokens
        if not tokens:
            raise ValueError("RunPod response has empty tokens")
        text = "".join(tokens).strip()
        if not text:
            raise ValueError("RunPod response tokens contain no text")
        return text
