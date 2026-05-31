from __future__ import annotations

from enum import Enum


class LLMMode(str, Enum):
    STUB = "stub"
    RUNPOD = "runpod"
