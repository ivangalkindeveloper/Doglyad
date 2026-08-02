from __future__ import annotations

import os

# `app.core.variables` instantiates `Variables()` at import time, which requires
# ENVIRONMENT and SERVED_MODEL_ID to be set (there are no defaults and no env_file
# is configured). Provide safe defaults so the app package can be imported under
# pytest without a real `backend/gpu/secrets/.env` present.
os.environ.setdefault("ENVIRONMENT", "development")
os.environ.setdefault("SERVED_MODEL_ID", "google/medgemma-4b-it")
os.environ.setdefault("APP_CHECK_ENABLED", "false")
