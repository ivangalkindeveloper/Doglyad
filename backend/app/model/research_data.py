from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel

from app.model.research_scan_photo import ResearchScanPhoto


class ResearchData(BaseModel):
    timestamp: datetime
    researchType: str
    photos: List[ResearchScanPhoto]
    patientName: str
    patientGender: str
    patientDateOfBirth: datetime
    patientHeight: float
    patientWeight: float
    patientComplaint: Optional[str] = None
    researchDescription: str
    additionalData: Optional[str] = None
