from __future__ import annotations

from pydantic import BaseModel


class RunPodMessageContent(BaseModel):
    type: str
    text: str | None = None


class RunPodMessage(BaseModel):
    role: str
    content: list[RunPodMessageContent]


class RunPodOutputItem(BaseModel):
    generated_text: list[RunPodMessage]


class RunPodResponse(BaseModel):
    output: list[RunPodOutputItem]

    def first_text(self) -> str:
        if not self.output:
            raise ValueError("RunPod response has empty output")
        messages = self.output[0].generated_text
        if not messages:
            raise ValueError("RunPod response has empty generated_text")
        last_message = messages[-1]
        if not last_message.content:
            raise ValueError("RunPod response has empty content")
        text = last_message.content[-1].text
        if text is None:
            raise ValueError("RunPod response content has no text field")
        return text.strip()
