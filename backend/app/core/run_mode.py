from __future__ import annotations

import os
from enum import Enum


class RunMode(str, Enum):
    STUB = "stub"
    MODEL = "model"


RUN_MODE = RunMode(os.getenv("RUN_MODE", "stub").lower())
