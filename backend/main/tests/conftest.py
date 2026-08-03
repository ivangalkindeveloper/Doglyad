from __future__ import annotations

import os

# `app.core.variables` instantiates `Variables()` at import time, which requires
# ENVIRONMENT to be set (there is no default and no env_file is configured).
# Provide it so the app package can be imported under pytest without a real
# `backend/main/secrets/.env` present.
os.environ.setdefault("ENVIRONMENT", "development")
