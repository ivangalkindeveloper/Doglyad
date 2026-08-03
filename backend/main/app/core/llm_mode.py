from __future__ import annotations

from enum import Enum


class LLMMode(str, Enum):
    STUB = "stub"
    INFERENCE = "inference"

    @property
    def verifies_app_check(self) -> bool:
        """Whether requests in this mode must carry a verified App Check token.

        Derived from the mode rather than configured separately: a standalone
        flag is one more thing that can be left switched off on a machine that
        needed it. `inference` means real requests reach a real model — on our
        own VM and, on failure, on a paid third party — so the caller has to be
        a genuine app instance. `stub` reaches nothing and needs no Firebase
        credentials, which is what keeps local development possible without
        minting real tokens.
        """
        return self is LLMMode.INFERENCE
