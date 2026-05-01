from __future__ import annotations

import os
from enum import Enum


class RunMode(str, Enum):
    STUB = "stub"
    RUNPOD = "runpod"


LLM_MODE = RunMode(os.getenv("LLM_MODE", "stub").lower())
