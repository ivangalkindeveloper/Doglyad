from __future__ import annotations

from pydantic import BaseModel


class ConclusionGenerationResponse(BaseModel):
    modelId: str
    response: str
