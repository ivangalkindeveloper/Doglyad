from __future__ import annotations

import asyncio

import pytest
from fastapi import HTTPException

from app.model.neural_model_settings import NeuralModelSettings
from app.model.ultrasound.us_examination_neural_model import USExaminationNeuralModel
from app.service.base import InferenceRequest, ModelService
from app.service.fallback import FallbackModelService

_MODEL = USExaminationNeuralModel(id="google/medgemma-4b-it", title="MedGemma 4B", description={"en": ""})


def _request(token: str | None = "token") -> InferenceRequest:
    return InferenceRequest(
        neural_model=_MODEL,
        settings=NeuralModelSettings(),
        language_code="ru",
        system_prompt="system",
        prompt="prompt",
        app_check_token=token,
    )


class _StubService(ModelService):
    def __init__(self, result: str | None = None, error: Exception | None = None) -> None:
        self._result = result
        self._error = error
        self.calls = 0
        self.received: InferenceRequest | None = None

    async def call(self, request: InferenceRequest) -> str:
        self.calls += 1
        self.received = request
        if self._error:
            raise self._error
        assert self._result is not None
        return self._result


def _run(service: ModelService, token: str | None = "token") -> str:
    return asyncio.run(service.call(_request(token)))


def test_fallback_is_not_used_when_primary_succeeds() -> None:
    primary = _StubService(result="from gpu")
    fallback = _StubService(result="from runpod")

    assert _run(FallbackModelService(primary, fallback)) == "from gpu"
    assert fallback.calls == 0


def test_fallback_is_used_when_primary_returns_error_status() -> None:
    primary = _StubService(error=HTTPException(status_code=502, detail="down"))
    fallback = _StubService(result="from runpod")

    assert _run(FallbackModelService(primary, fallback)) == "from runpod"
    assert fallback.calls == 1


def test_fallback_is_used_when_primary_raises_unexpectedly() -> None:
    # "Failed for any reason" includes failures that are not HTTPException.
    primary = _StubService(error=RuntimeError("boom"))
    fallback = _StubService(result="from runpod")

    assert _run(FallbackModelService(primary, fallback)) == "from runpod"
    assert fallback.calls == 1


@pytest.mark.parametrize("status_code", [401, 403])
def test_auth_failures_are_not_retried_on_the_fallback(status_code: int) -> None:
    # Falling back here would serve a request that failed App Check on the GPU VM.
    primary = _StubService(error=HTTPException(status_code=status_code, detail="no"))
    fallback = _StubService(result="from runpod")

    with pytest.raises(HTTPException) as error:
        _run(FallbackModelService(primary, fallback))

    assert error.value.status_code == status_code
    assert fallback.calls == 0


def test_the_fallback_receives_the_same_request() -> None:
    primary = _StubService(error=HTTPException(status_code=502, detail="down"))
    fallback = _StubService(result="from runpod")

    _run(FallbackModelService(primary, fallback), token="app-check-token")

    assert fallback.received == primary.received
    assert primary.received is not None
    assert primary.received.app_check_token == "app-check-token"


def test_fallback_errors_propagate_when_both_fail() -> None:
    primary = _StubService(error=HTTPException(status_code=502, detail="gpu down"))
    fallback = _StubService(error=HTTPException(status_code=502, detail="runpod down"))

    with pytest.raises(HTTPException) as error:
        _run(FallbackModelService(primary, fallback))

    assert error.value.detail == "runpod down"
