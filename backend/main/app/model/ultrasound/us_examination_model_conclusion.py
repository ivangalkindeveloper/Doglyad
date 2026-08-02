from datetime import datetime

from pydantic import BaseModel


class USExaminationModelConclusion(BaseModel):
    date: datetime
    modelId: str
    response: str
