from __future__ import annotations

from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Variables(BaseSettings):
    model_config = SettingsConfigDict(extra="ignore")

    # Picks the config directory under `backend/main/config/` and nothing else.
    # `development` and `production` run the same code down the same path — they
    # differ in which models, examination types and application settings they read.
    environment: str

    config_dir: Path | None = None

    log_dir: Path | None = None
    log_retention_days: int = 365

    # Firebase service account used to verify App Check tokens. Verification is
    # unconditional — every environment reaches a real model — so startup aborts
    # without this rather than serving unverified callers.
    firebase_credentials_path: Path | None = None

    # Inference path: one GPU VM per model, each running backend/inference
    # next to its own vLLM instance. Path to a modelId -> URL map; required in every
    # environment, because every environment takes this path. See InferenceService.
    inference_endpoints_path: Path | None = None
    # Timeouts nest outside-in, with each layer wider than the one it wraps:
    #
    #   iOS client                    300  application.json -> network.timeoutIntervalForRequest
    #   INFERENCE_REQUEST_TIMEOUT     130  this backend waiting on the GPU VM
    #   VLLM_REQUEST_TIMEOUT          120  the VM waiting on its local engine
    #
    # The inner timeout must stay below the outer one so the caller does not close
    # a connection while the wrapped generation is still running.
    inference_request_timeout_seconds: int = 130

    email_sender: str | None = None
    email_password: str | None = None
    email_smtp_host: str | None = None
    email_smtp_port: int | None = None


variables = Variables()
