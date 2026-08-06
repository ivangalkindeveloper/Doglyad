from __future__ import annotations

import logging

from fastapi import APIRouter, Request, Response

from app.core.config import resolve_config_document
from app.core.limiter import limiter

logger = logging.getLogger(__name__)

router = APIRouter()


def _document(name: str) -> Response:
    """Serves a config document verbatim.

    Returned as the original text rather than through a `response_model`: the app
    decodes these itself, and mirroring the whole config tree in Pydantic would
    double the schema and give it a second place to drift from. What ships in the
    image is what the app receives, down to key order.
    """
    logger.info("Config document served: %s", name)
    return Response(content=resolve_config_document(name), media_type="application/json")


# All four sit outside `/v1`, and so outside App Check. These documents are public
# by nature — the app read them straight from the public repository until now — so
# a token would protect nothing while making the app's startup depend on App Check
# working.
#
# They are served from here rather than from the repository so the app and this
# backend cannot disagree: pushing a new model to `master` used to make the app
# offer it immediately, while the backend only learned about it on the next
# deploy, and a doctor picking it got a 400.


@router.get("/application_config")
@limiter.limit("60/minute")
async def application_config(request: Request) -> Response:
    del request  # only the rate limiter needs it
    return _document("application.json")


@router.get("/ultrasound_examination_types")
@limiter.limit("60/minute")
async def ultrasound_examination_types(request: Request) -> Response:
    del request
    return _document("ultrasound_examination_types.json")


@router.get("/ultrasound_examination_neural_models")
@limiter.limit("60/minute")
async def ultrasound_examination_neural_models(request: Request) -> Response:
    del request
    return _document("ultrasound_examination_neural_models.json")


@router.get("/ultrasound_examination_contextual_strings")
@limiter.limit("60/minute")
async def ultrasound_examination_contextual_strings(request: Request) -> Response:
    del request
    return _document("ultrasound_examination_contextual_strings.json")
