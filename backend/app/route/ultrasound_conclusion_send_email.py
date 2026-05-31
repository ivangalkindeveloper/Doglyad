from __future__ import annotations

import asyncio
import logging
import smtplib
from email.mime.text import MIMEText

from fastapi import APIRouter, HTTPException, Request, status

from app.core.limiter import limiter
from app.core.variables import variables
from app.model.ultrasound.us_examination_email import USExaminationEmail

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
    examination = body.examinationData
    subject = f"Doglyad — заключение: {examination.patientName}"
    message = MIMEText(body.modelConclusion.response)
    message["Subject"] = subject
    message["From"] = variables.email_sender
    message["To"] = body.recipientEmail

    server = smtplib.SMTP(variables.email_smtp_host, variables.email_smtp_port)
    try:
        server.starttls()
        server.login(variables.email_sender, variables.email_password)
        server.sendmail(
            variables.email_sender,
            body.recipientEmail,
            message.as_string(),
        )
    finally:
        server.quit()