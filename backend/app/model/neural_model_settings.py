from typing import Optional

from pydantic import BaseModel


class NeuralModelSettings(BaseModel):
    template: Optional[str] = None
    responseLength: Optional[int] = None
