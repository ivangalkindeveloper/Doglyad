from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel

from app.model.ultrasound.us_examination_scan_photo import USExaminationScanPhoto


class USExaminationData(BaseModel):
    usExaminationTypeId: str
    photos: List[USExaminationScanPhoto]
    patientName: str
    patientGender: str
    patientDateOfBirth: datetime
    patientHeight: float
    patientWeight: float
    patientComplaint: Optional[str] = None
    examinationDescription: str
    additionalData: Optional[str] = None
