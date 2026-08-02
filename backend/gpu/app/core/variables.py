from __future__ import annotations

from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Variables(BaseSettings):
    model_config = SettingsConfigDict(extra="ignore")

    environment: str

    log_dir: Path | None = None
    log_retention_days: int = 365

    # App Check is verified here, on the GPU service itself: it is the component that
    # actually holds the model, and it must not trust callers just because they can
    # reach it over the network.
    app_check_enabled: bool = True
    firebase_credentials_path: Path | None = None

    # The single model this GPU VM serves. One VM per model, so this is a scalar and
    # not a map: a request for any other model id is rejected rather than silently
    # answered by the wrong model.
    served_model_id: str

    # Local vLLM OpenAI-compatible server, reachable only from inside the VM's
    # Docker network — it is never exposed publicly.
    vllm_base_url: str = "http://vllm:8000"
    vllm_api_key: str | None = None
    vllm_request_timeout_seconds: int = 300


variables = Variables()
