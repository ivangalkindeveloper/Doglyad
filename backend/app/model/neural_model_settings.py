from typing import Optional

from pydantic import BaseModel


class NeuralModelSettings(BaseModel):
    selectedNeuralModelId: Optional[str] = None
    temperature: Optional[float] = None
    responseLength: Optional[int] = None
