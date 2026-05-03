from __future__ import annotations

import os
from enum import Enum


class LLMMode(str, Enum):
    STUB = "stub"
    RUNPOD = "runpod"


LLM_MODE = LLMMode(os.getenv("LLM_MODE", "stub").lower())
