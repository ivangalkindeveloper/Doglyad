from __future__ import annotations

import asyncio
import json
from pathlib import Path

import httpx
import pytest

from app.core.llm_mode import LLMMode
from app.core.variables import variables
from app.model.neural_model_settings import NeuralModelSettings
from app.model.ultrasound.us_examination_neural_model import USExaminationNeuralModel
from app.prompt import resolve_prompt_factory
from app.service import InferenceRequest, ServiceFactory
from app.service.fallback import FallbackModelService
from app.service.gpu import GpuService
from app.service.stub import StubModelService

_MODEL = USExaminationNeuralModel(id="google/medgemma-4b-it", title="MedGemma 4B", description={"en": ""})


@pytest.fixture
def http_client() -> httpx.AsyncClient:
    return httpx.AsyncClient()


@pytest.fixture
def gpu_endpoints(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    path = tmp_path / "gpu_endpoint.json"
    path.write_text(json.dumps({_MODEL.id: "http://10.0.0.11:8100/v1/conclusion_generation"}), encoding="utf-8")
    monkeypatch.setattr(variables, "gpu_endpoints_path", path)
    return path


@pytest.fixture
def runpod_endpoints(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    path = tmp_path / "runpod_endpoint.json"
    path.write_text(json.dumps({_MODEL.id: "https://api.runpod.ai/v2/x/runsync"}), encoding="utf-8")
    monkeypatch.setattr(variables, "runpod_api_key", "key")
    monkeypatch.setattr(variables, "runpod_endpoints_path", path)
    return path


@pytest.fixture
def no_runpod(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(variables, "runpod_api_key", None)
    monkeypatch.setattr(variables, "runpod_endpoints_path", None)


def test_stub_mode_resolves_the_stub_service(http_client: httpx.AsyncClient) -> None:
    factory = ServiceFactory(http_client, LLMMode.STUB)

    assert isinstance(factory.resolve(LLMMode.STUB), StubModelService)


def test_stub_mode_needs_no_inference_configuration(
    http_client: httpx.AsyncClient,
    monkeypatch: pytest.MonkeyPatch,
    no_runpod: None,
) -> None:
    # Nothing about the GPU VMs is touched in stub mode, so a developer can run
    # the backend without any inference credentials at all.
    monkeypatch.setattr(variables, "gpu_endpoints_path", None)

    ServiceFactory(http_client, LLMMode.STUB)


@pytest.mark.parametrize("language_code", ["ru", "en"])
def test_stub_service_answers_in_the_request_language(language_code: str) -> None:
    request = InferenceRequest(
        neural_model=_MODEL,
        settings=NeuralModelSettings(),
        language_code=language_code,
        system_prompt="system",
        prompt="prompt",
    )

    assert asyncio.run(StubModelService().call(request)) == resolve_prompt_factory(language_code).stub


def test_gpu_is_primary_with_runpod_behind_it(
    http_client: httpx.AsyncClient,
    gpu_endpoints: Path,
    runpod_endpoints: Path,
) -> None:
    service = ServiceFactory(http_client, LLMMode.INFERENCE).resolve(LLMMode.INFERENCE)

    assert isinstance(service, FallbackModelService)
    assert isinstance(service._primary, GpuService)


def test_gpu_runs_alone_when_runpod_is_not_configured(
    http_client: httpx.AsyncClient,
    gpu_endpoints: Path,
    no_runpod: None,
) -> None:
    # Without a fallback a GPU failure has to surface, not be silently absorbed.
    service = ServiceFactory(http_client, LLMMode.INFERENCE).resolve(LLMMode.INFERENCE)

    assert isinstance(service, GpuService)


def test_startup_fails_without_gpu_configuration(
    http_client: httpx.AsyncClient,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    # The GPU path is the one every request takes, so a missing map aborts startup
    # rather than quietly routing all traffic to the paid fallback.
    monkeypatch.setattr(variables, "gpu_endpoints_path", None)

    with pytest.raises(RuntimeError):
        ServiceFactory(http_client, LLMMode.INFERENCE)


def test_resolving_an_unconfigured_mode_fails(http_client: httpx.AsyncClient) -> None:
    factory = ServiceFactory(http_client, LLMMode.STUB)

    with pytest.raises(ValueError):
        factory.resolve(LLMMode.INFERENCE)
