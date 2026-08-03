from __future__ import annotations

import asyncio
import importlib
from collections.abc import Iterator
from contextlib import contextmanager
from typing import Any

import pytest
from fastapi import FastAPI, HTTPException

from app.core.app_check import (
    APP_CHECK_HEADER,
    app_check_dependencies,
    mail_app_check_dependencies,
    verify_app_check,
)
from app.core.llm_mode import LLMMode
from app.core.variables import variables

_MAIL_PATH = "/v1/ultrasound_conclusion_send_email"


def _route_dependencies(app: FastAPI, path_prefix: str) -> dict[str, list[Any]]:
    routes = [route for route in app.routes if str(getattr(route, "path", "")).startswith(path_prefix)]
    assert routes, f"no routes under {path_prefix}"
    return {
        str(route.path): [call.call for call in route.dependant.dependencies]  # type: ignore[attr-defined]
        for route in routes
    }


@contextmanager
def _app_built_with(llm_mode: LLMMode, environment: str) -> Iterator[FastAPI]:
    """The application as `app.main` assembles it for a given configuration.

    The `/v1` router is built at import time, so the configuration has to be in
    place before the module is (re)imported. Restored afterwards to keep the
    default stub/development application for the other tests.
    """
    from app import main as main_module

    original = (variables.llm_mode, variables.environment)
    variables.llm_mode = llm_mode
    variables.environment = environment
    try:
        yield importlib.reload(main_module).app
    finally:
        variables.llm_mode, variables.environment = original
        importlib.reload(main_module)


@pytest.fixture
def app_in_inference_mode() -> Iterator[FastAPI]:
    with _app_built_with(LLMMode.INFERENCE, "development") as app:
        yield app


def test_inference_mode_closes_v1(monkeypatch: pytest.MonkeyPatch) -> None:
    # The mode that reaches a model is the mode that verifies the caller — there is
    # no separate flag that could be left switched off by accident.
    monkeypatch.setattr(variables, "llm_mode", LLMMode.INFERENCE)

    assert [dependency.dependency for dependency in app_check_dependencies()] == [verify_app_check]


def test_stub_mode_leaves_v1_open(monkeypatch: pytest.MonkeyPatch) -> None:
    # Stub reaches nothing, so the backend runs without Firebase credentials and
    # without an app instance to mint tokens.
    monkeypatch.setattr(variables, "llm_mode", LLMMode.STUB)

    assert app_check_dependencies() == []


def test_every_v1_route_is_behind_app_check(app_in_inference_mode: FastAPI) -> None:
    # Guards the wiring, not just the rule: dropping `dependencies=` from the
    # router in app/main.py would otherwise leave every other test green.
    for path, dependencies in _route_dependencies(app_in_inference_mode, "/v1/").items():
        assert verify_app_check in dependencies, f"{path} is not behind App Check"


def test_stub_mode_app_is_reachable_without_a_token() -> None:
    # The default test configuration is stub mode; the routes must stay open there.
    from app.main import app

    for dependencies in _route_dependencies(app, "/v1/").values():
        assert verify_app_check not in dependencies


def test_production_closes_the_mail_route_even_in_stub_mode(monkeypatch: pytest.MonkeyPatch) -> None:
    # Sending mail never touches a model, so LLM_MODE says nothing about it. What
    # it does touch is real SMTP credentials — an open route here is an open relay.
    monkeypatch.setattr(variables, "environment", "production")

    assert [dependency.dependency for dependency in mail_app_check_dependencies()] == [verify_app_check]


def test_outside_production_the_mail_route_follows_the_router(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(variables, "environment", "development")

    assert mail_app_check_dependencies() == []


def test_production_stub_leaves_only_the_mail_route_closed() -> None:
    # The two rules are independent, and this is the configuration where they
    # disagree: conclusions are stubbed and open, mail still goes out for real.
    with _app_built_with(LLMMode.STUB, "production") as app:
        dependencies = _route_dependencies(app, "/v1/")

    assert verify_app_check in dependencies[_MAIL_PATH]
    assert verify_app_check not in dependencies["/v1/ultrasound_conclusion"]


def test_production_inference_closes_everything() -> None:
    with _app_built_with(LLMMode.INFERENCE, "production") as app:
        for path, dependencies in _route_dependencies(app, "/v1/").items():
            assert verify_app_check in dependencies, f"{path} is not behind App Check"


def test_missing_token_is_rejected() -> None:
    # Rejected at the edge, before any service is resolved: the RunPod fallback
    # bypasses the GPU VM, so verification cannot be left to the VM alone.
    with pytest.raises(HTTPException) as error:
        asyncio.run(verify_app_check(None))

    assert error.value.status_code == 401


def test_header_name_matches_the_one_the_inference_service_reads() -> None:
    # Relayed verbatim to the GPU VM, which looks the token up under this name.
    assert APP_CHECK_HEADER == "X-Firebase-AppCheck"
