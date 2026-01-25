from datetime import datetime

from pydantic import BaseModel


class ResearchModelConclusion(BaseModel):
    date: datetime
    model: str
    description: str
