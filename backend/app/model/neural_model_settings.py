from typing import Optional

from pydantic import BaseModel


class NeuralModelSettings(BaseModel):
    selectedNeuralModelId: Optional[str] = None
    template: Optional[str] = None
    responseLength: Optional[int] = None
