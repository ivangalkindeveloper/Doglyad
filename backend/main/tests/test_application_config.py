from __future__ import annotations

import json

import pytest
from fastapi.testclient import TestClient

from app.core.config import _CONFIG_DIR, load_configs

# Endpoint -> the document in the image it must serve, byte for byte.
_ENDPOINTS = {
    "/application_config": "application.json",
    "/ultrasound_examination_types": "ultrasound_examination_types.json",
    "/ultrasound_examination_neural_models": "ultrasound_examination_neural_models.json",
    "/ultrasound_examination_contextual_strings": "ultrasound_examination_contextual_strings.json",
}


@pytest.fixture(scope="module")
def client() -> TestClient:
    # The documents are read once at startup, so they have to be loaded before the
    # routes are exercised. TestClient runs without the lifespan on purpose: the
    # lifespan also initializes App Check, which needs Firebase credentials.
    load_configs()
    from app.main import app

    return TestClient(app)


@pytest.mark.parametrize("path", _ENDPOINTS)
def test_document_is_served_as_json(client: TestClient, path: str) -> None:
    response = client.get(path)

    assert response.status_code == 200
    assert response.headers["content-type"].startswith("application/json")
    json.loads(response.text)


@pytest.mark.parametrize(("path", "document"), _ENDPOINTS.items())
def test_served_bytes_match_the_file_in_the_image(client: TestClient, path: str, document: str) -> None:
    # Served verbatim rather than parsed and re-serialized: the app must receive
    # exactly what shipped, down to key order and formatting.
    assert client.get(path).text == (_CONFIG_DIR / document).read_text(encoding="utf-8")


@pytest.mark.parametrize("path", _ENDPOINTS)
def test_config_is_reachable_without_app_check(client: TestClient, path: str) -> None:
    # The app reads these before it has a token to send, and their contents are
    # public anyway. A regression that moves them under /v1 would lock the app out
    # of starting.
    from app.core.app_check import verify_app_check

    route = next(r for r in client.app.routes if getattr(r, "path", None) == path)
    dependencies = [call.call for call in route.dependant.dependencies]  # type: ignore[attr-defined]
    assert verify_app_check not in dependencies


def test_only_the_app_facing_documents_are_exposed(client: TestClient) -> None:
    served = {str(getattr(r, "path", "")) for r in client.app.routes}
    assert set(_ENDPOINTS) <= served


@pytest.mark.parametrize("environment", ("development", "production"))
def test_service_availability_is_the_first_field_and_disabled_by_default(environment: str) -> None:
    path = _CONFIG_DIR.parent / environment / "application.json"
    application_config = json.loads(path.read_text(encoding="utf-8"))

    assert next(iter(application_config)) == "isServiceAvailable"
    assert application_config["isServiceAvailable"] is False
