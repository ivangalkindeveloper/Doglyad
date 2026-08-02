from __future__ import annotations

from pydantic import BaseModel


class USExaminationEmail(BaseModel):
    recipientEmail: str
    subject: str
    body: str
