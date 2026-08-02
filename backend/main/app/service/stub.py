from __future__ import annotations

import logging

from app.prompt import resolve_prompt_factory
from app.service.base import InferenceRequest, ModelService

logger = logging.getLogger(__name__)


class StubModelService(ModelService):
    """Returns a canned conclusion instead of running a model.

    Backs `LLM_MODE=stub`, so the app can be developed against the real endpoint —
    same route, same response shape, same latency-free path — without a GPU VM or
    a RunPod bill.
    """

    async def call(self, request: InferenceRequest) -> str:
        logger.info("Stub conclusion: model=%s, lang=%s", request.neural_model.id, request.language_code)
        return resolve_prompt_factory(request.language_code).stub
