from pydantic import BaseModel


class ResearchScanPhoto(BaseModel):
    imageData: str
