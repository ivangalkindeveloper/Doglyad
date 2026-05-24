from __future__ import annotations

from pydantic import BaseModel

from app.model.ultrasound.us_examination_data import USExaminationData
from app.model.ultrasound.us_examination_model_conclusion import USExaminationModelConclusion


class USExaminationEmail(BaseModel):
    recipientEmail: str
    examinationData: USExaminationData
    modelConclusion: USExaminationModelConclusion
