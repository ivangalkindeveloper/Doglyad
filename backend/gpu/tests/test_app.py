from __future__ import annotations

import asyncio

import httpx
import pytest
from fastapi import HTTPException


def test_app_exposes_routes() -> None:
    from app.main import app

    paths = {getattr(route, "path", None) for route in app.routes}
    assert "/v1/conclusion_generation" in paths
    assert "/health" in paths


def test_health_is_not_behind_app_check() -> None:
    # Health must stay probe-able by infrastructure that holds no app credentials.
    from app.core.app_check import verify_app_check
    from app.main import app

    health = next(route for route in app.routes if getattr(route, "path", None) == "/health")
    dependencies = [call.call for call in health.dependant.dependencies]  # type: ignore[attr-defined]
    assert verify_app_check not in dependencies


def test_generate_rejects_another_model() -> None:
    # One VM per model: answering for a different id would hand the doctor a
    # conclusion from a model they did not choose.
    from app.model.conclusion_generation_request import ConclusionGenerationRequest
    from app.service.vllm import VLLMService

    async def run() -> None:
        async with httpx.AsyncClient() as client:
            service = VLLMService(client)
            request = ConclusionGenerationRequest(
                modelId="google/medgemma-27b-it",
                systemPrompt="system",
                prompt="prompt",
            )
            with pytest.raises(HTTPException) as error:
                await service.generate(request)
            assert error.value.status_code == 400

    asyncio.run(run())


def test_vllm_response_value() -> None:
    from app.model.vllm_response import VLLMChatCompletion

    parsed = VLLMChatCompletion.model_validate(
        {
            "choices": [{"message": {"role": "assistant", "content": "  Conclusion.  "}}],
            "usage": {"prompt_tokens": 10, "completion_tokens": 20},
        }
    )
    assert parsed.value() == "Conclusion."


def test_vllm_response_rejects_empty_content() -> None:
    from app.model.vllm_response import VLLMChatCompletion

    parsed = VLLMChatCompletion.model_validate({"choices": [{"message": {"content": ""}}]})
    with pytest.raises(ValueError):
        parsed.value()
