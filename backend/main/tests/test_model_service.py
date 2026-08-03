from __future__ import annotations

import json
from pathlib import Path

import httpx
import pytest

from app.core.variables import variables
from app.model.ultrasound.us_examination_neural_model import USExaminationNeuralModel
from app.service import create_model_service
from app.service.fallback import FallbackModelService
from app.service.inference import InferenceService

_MODEL = USExaminationNeuralModel(id="google/medgemma-4b-it", title="MedGemma 4B", description={"en": ""})


@pytest.fixture
def http_client() -> httpx.AsyncClient:
    return httpx.AsyncClient()


@pytest.fixture
def inference_endpoints(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    path = tmp_path / "inference_endpoints.json"
    path.write_text(json.dumps({_MODEL.id: "http://10.0.0.11:8100/v1/conclusion_generation"}), encoding="utf-8")
    monkeypatch.setattr(variables, "inference_endpoints_path", path)
    return path


@pytest.fixture
def runpod_endpoints(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    path = tmp_path / "runpod_endpoints.json"
    path.write_text(json.dumps({_MODEL.id: "https://api.runpod.ai/v2/x/runsync"}), encoding="utf-8")
    monkeypatch.setattr(variables, "runpod_api_key", "key")
    monkeypatch.setattr(variables, "runpod_endpoints_path", path)
    return path


@pytest.fixture
def no_runpod(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(variables, "runpod_api_key", None)
    monkeypatch.setattr(variables, "runpod_endpoints_path", None)


def test_our_vms_are_primary_with_runpod_behind_them(
    http_client: httpx.AsyncClient,
    inference_endpoints: Path,
    runpod_endpoints: Path,
) -> None:
    service = create_model_service(http_client)

    assert isinstance(service, FallbackModelService)
    assert isinstance(service._primary, InferenceService)


def test_our_vms_run_alone_when_runpod_is_not_configured(
    http_client: httpx.AsyncClient,
    inference_endpoints: Path,
    no_runpod: None,
) -> None:
    # Without a fallback a GPU VM failure has to surface, not be silently absorbed.
    assert isinstance(create_model_service(http_client), InferenceService)


def test_startup_fails_without_an_inference_map(
    http_client: httpx.AsyncClient,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    # The inference path is the one every request takes in every environment, so a
    # missing map aborts startup rather than quietly routing all traffic to the
    # paid fallback.
    monkeypatch.setattr(variables, "inference_endpoints_path", None)

    with pytest.raises(RuntimeError):
        create_model_service(http_client)


def test_the_same_composition_in_every_environment(
    http_client: httpx.AsyncClient,
    inference_endpoints: Path,
    runpod_endpoints: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    # ENVIRONMENT picks a config directory and nothing else: a conclusion is
    # produced by the same services in development as in production. That is what
    # makes testing against a development backend meaningful.
    built = []
    for environment in ("development", "production"):
        monkeypatch.setattr(variables, "environment", environment)
        built.append(type(create_model_service(http_client)))

    assert built[0] is built[1]
