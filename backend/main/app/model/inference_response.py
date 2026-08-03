from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class InferenceConclusionResponse(BaseModel):
    """The response of `POST /v1/conclusion_generation` on a GPU VM.

    Mirrors `ConclusionGenerationResponse` in backend/inference.
    """

    model_config = ConfigDict(extra="ignore")

    modelId: str
    response: str

    def value(self) -> str:
        text = self.response.strip()
        if not text:
            raise ValueError("Inference service response contains no text")
        return text
