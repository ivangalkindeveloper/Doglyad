from __future__ import annotations

from pydantic import BaseModel, Field


class ConclusionGenerationPhoto(BaseModel):
    data: str


class ConclusionGenerationRequest(BaseModel):
    """What the backend sends to generate one conclusion.

    Prompt building, localization and templating stay in the backend: this service
    receives a ready pair of prompts and only runs the model. That keeps the GPU
    side model-agnostic and lets the RunPod fallback receive exactly the same
    inputs when this service is unreachable.
    """

    modelId: str
    systemPrompt: str
    prompt: str
    photos: list[ConclusionGenerationPhoto] = Field(default_factory=list)
    # Bounds mirror the backend's NeuralModelSettings so an out-of-range value is
    # rejected here too rather than being passed on to the engine.
    temperature: float | None = Field(default=None, ge=0.0, le=2.0)
    maxTokens: int | None = Field(default=None, gt=0, le=4096)
