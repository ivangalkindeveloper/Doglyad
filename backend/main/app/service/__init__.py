from __future__ import annotations

from app.service.base import InferenceRequest, ModelService
from app.service.factory import create_model_service

__all__ = ["InferenceRequest", "ModelService", "create_model_service"]
