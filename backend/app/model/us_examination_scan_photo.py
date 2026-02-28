from pydantic import BaseModel


class USExaminationScanPhoto(BaseModel):
    imageData: str
