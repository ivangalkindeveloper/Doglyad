from __future__ import annotations

import asyncio
import logging
import os
import smtplib
from email.mime.text import MIMEText

from fastapi import APIRouter, HTTPException, Request, status

from app.core.limiter import limiter
from app.model.ultrasound.us_examination_email import USExaminationEmail

EMAIL_SENDER = "doglyadapp@gmail.com"
EMAIL_SMTP_HOST = "smtp.gmail.com"
EMAIL_SMTP_PORT = 587

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post(
    "/ultrasound_conclusion_send_email",
    status_code=status.HTTP_204_NO_CONTENT,
)
@limiter.limit("30/minute")
async def ultrasound_conclusion_send_email(
    body: USExaminationEmail,
    request: Request,
) -> None:
    del request

    logger.info(
        "Send email: recipient=%s, patient=%s",
        body.recipientEmail,
        body.examinationData.patientName,
    )

    try:
        await asyncio.to_thread(_send_examination_email, body)
    except HTTPException:
        raise
    except Exception as error:
        logger.exception("Failed to send examination email")
        raise HTTPException(
            status_code=500,
            detail=f"{error}\nCheck your login or password please!",
        ) from error


def _send_examination_email(body: USExaminationEmail) -> None:
    password = os.getenv("EMAIL_PASSWORD")
    if not password:
        raise HTTPException(
            status_code=500,
            detail="Email sender password is not configured",
        )

    examination = body.examinationData
    subject = f"Doglyad — заключение: {examination.patientName}"
    message = MIMEText(body.modelConclusion.response)
    message["Subject"] = subject
    message["From"] = EMAIL_SENDER
    message["To"] = body.recipientEmail

    server = smtplib.SMTP(EMAIL_SMTP_HOST, EMAIL_SMTP_PORT)
    try:
        server.starttls()
        server.login(EMAIL_SENDER, password)
        server.sendmail(
            EMAIL_SENDER,
            body.recipientEmail,
            message.as_string(),
        )
    finally:
        server.quit()