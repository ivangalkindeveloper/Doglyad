from __future__ import annotations

import logging

from fastapi import HTTPException

from app.service.base import InferenceRequest, ModelService

logger = logging.getLogger(__name__)

# Statuses that mean the caller was rejected, not that the service broke. Retrying
# elsewhere would hand a conclusion to a request that failed App Check, so these
# propagate untouched.
_NON_RETRYABLE_STATUSES = frozenset({401, 403})


class FallbackModelService(ModelService):
    """Runs `primary`, and on failure repeats the same call against `fallback`.

    Used to keep RunPod as a safety net behind our own GPU VMs: a VM that is
    rebooting, out of memory or still loading weights costs a slower conclusion
    rather than a failed one.
    """

    def __init__(self, primary: ModelService, fallback: ModelService) -> None:
        self._primary = primary
        self._fallback = fallback

    async def call(self, request: InferenceRequest) -> str:
        try:
            return await self._primary.call(request)
        except HTTPException as error:
            if error.status_code in _NON_RETRYABLE_STATUSES:
                raise
            logger.warning(
                "Primary inference failed for model %s with status %d, falling back",
                request.neural_model.id,
                error.status_code,
            )
        except Exception:
            # Deliberately broad: whatever went wrong upstream, a working fallback
            # is better than a failed conclusion. The traceback is kept in the log.
            logger.exception("Primary inference raised for model %s, falling back", request.neural_model.id)

        return await self._fallback.call(request)
