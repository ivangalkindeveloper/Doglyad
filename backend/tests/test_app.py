from __future__ import annotations


def test_app_exposes_v1_routes() -> None:
    from app.main import app

    paths = {getattr(route, "path", None) for route in app.routes}
    assert "/v1/ultrasound_conclusion" in paths
    assert "/v1/ultrasound_conclusion_send_email" in paths
