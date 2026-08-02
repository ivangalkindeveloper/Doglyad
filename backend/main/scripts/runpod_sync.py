#!/usr/bin/env python3
"""Синхронизация serverless-эндпоинтов RunPod с декларативным конфигом.

Источник правды по конфигурации — backend/main/config/runpod_endpoints.json.
Источник правды по факту — сам RunPod (никакого локального файла состояния нет).

АЛГОРИТМ (одинаковый для plan и apply):

    Шаг 1. Собрать ЖЕЛАЕМОЕ состояние — прочитать конфиг, подставить секреты,
           сверить список моделей с конфигом приложения.
    Шаг 2. Собрать ФАКТИЧЕСКОЕ состояние — один GET /endpoints?includeTemplate=true.
    Шаг 3. Сравнить. Поля разнесены по двум объектам RunPod:
             - шаблон   (imageName, containerDiskInGb, env)  -> PATCH /templates/{id}
             - эндпоинт (gpuTypeIds, скейлинг, таймауты)     -> PATCH /endpoints/{id}
           Оба PATCH независимы; если разошлось и там, и там — идут оба.
    Шаг 4. Применить (только в apply).
    Шаг 5. Напечатать карту modelId -> URL для backend/main/secrets/runpod_endpoint.json.

Команды:
    plan      шаги 1-3. Печатает дифф, ничего не меняет.
    apply     шаги 1-5. Приводит RunPod к конфигу. Идемпотентен.
    urls      шаги 2, 5. Достаёт текущие URL, ничего не трогая.
    destroy   удаляет эндпоинты doglyad-* (с подтверждением).

Запуск: make runpod-plan / make runpod-apply / make runpod-urls
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

import httpx

# --------------------------------------------------------------------------------------
# Пути и константы
# --------------------------------------------------------------------------------------

# backend/main/scripts/runpod_sync.py -> backend/main/
BACKEND_DIR = Path(__file__).resolve().parent.parent

DESIRED_CONFIG_PATH = BACKEND_DIR / "config" / "runpod_endpoints.json"
# Список моделей, которые видит приложение. Окружения содержат одинаковый список,
# а имена эндпоинтов не привязаны к окружению, поэтому сверяемся с production.
MODELS_CONFIG_PATH = BACKEND_DIR / "config" / "production" / "ultrasound_examination_neural_models.json"
SECRETS_ENV_PATH = BACKEND_DIR / "secrets" / ".env"
URLS_OUTPUT_PATH = BACKEND_DIR / "secrets" / "runpod_endpoint.json"

API_BASE = "https://rest.runpod.io/v1"
RUN_URL_TEMPLATE = "https://api.runpod.ai/v2/{endpoint_id}/runsync"

# Скрипт управляет только своими эндпоинтами — остальное в аккаунте не трогает.
NAME_PREFIX = "doglyad-"

# Ключ управления держится отдельно от RUNPOD_API_KEY, которым бэкенд вызывает инференс:
# у прода нет причин иметь права на удаление эндпоинтов. Fallback — на случай одного ключа.
ADMIN_KEY_VAR = "RUNPOD_ADMIN_API_KEY"
INFERENCE_KEY_VAR = "RUNPOD_API_KEY"

# Поля шаблона (PATCH /templates/{id}). env обрабатывается отдельно.
TEMPLATE_FIELDS: tuple[str, ...] = ("imageName", "containerDiskInGb")

# Поля эндпоинта, которые скрипт отправляет (POST /endpoints, PATCH /endpoints/{id}).
ENDPOINT_FIELDS: tuple[str, ...] = (
    "gpuTypeIds",
    "gpuCount",
    "workersMin",
    "workersMax",
    "scalerType",
    "scalerValue",
    "idleTimeout",
    "executionTimeoutMs",
    "flashboot",
    "dataCenterIds",
)

# flashboot принимается на запись, но не возвращается в GET /endpoints (см. схему Endpoint
# в https://rest.runpod.io/v1/openapi.json). Сравнивать его не с чем, поэтому он
# отправляется, но не участвует в диффе — иначе каждый apply видел бы ложное
# расхождение None -> true и дёргал лишний PATCH.
ENDPOINT_DIFF_FIELDS: tuple[str, ...] = tuple(f for f in ENDPOINT_FIELDS if f != "flashboot")

# Значения таких env-переменных никогда не печатаются в дифф.
SECRET_ENV_PATTERN = re.compile(r"TOKEN|KEY|SECRET|PASSWORD", re.IGNORECASE)

SECRET_REF_PATTERN = re.compile(r"\$\{([A-Z0-9_]+)\}")


def endpoint_name(model_id: str) -> str:
    """doglyad-{model_id}; слэш в id недопустим в имени, поэтому заменяется на дефис."""
    return NAME_PREFIX + model_id.replace("/", "-")


# --------------------------------------------------------------------------------------
# Шаг 1. Желаемое состояние
# --------------------------------------------------------------------------------------


def read_env_file(path: Path) -> dict[str, str]:
    """Минимальный парсер .env (python-dotenv в зависимостях нет)."""
    values: dict[str, str] = {}
    if not path.exists():
        return values
    for line in path.read_text(encoding="utf-8-sig").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, raw = line.partition("=")
        values[key.strip()] = raw.strip().strip("'\"")
    return values


def resolve_secrets(value: str, secrets: dict[str, str], model_id: str) -> str:
    """Подставляет ${VAR} из secrets/.env. Отсутствие переменной — ошибка, а не пустая строка."""

    def replace(match: re.Match[str]) -> str:
        name = match.group(1)
        resolved = secrets.get(name)
        if not resolved:
            raise SystemExit(
                f"[{model_id}] в конфиге есть ${{{name}}}, но переменной {name} нет в {SECRETS_ENV_PATH}"
            )
        return resolved

    return SECRET_REF_PATTERN.sub(replace, value)


def load_desired() -> dict[str, dict[str, Any]]:
    """Читает конфиг, накладывает defaults, подставляет секреты и валидирует список моделей."""
    if not DESIRED_CONFIG_PATH.exists():
        raise SystemExit(f"Конфиг не найден: {DESIRED_CONFIG_PATH}")

    raw = json.loads(DESIRED_CONFIG_PATH.read_text(encoding="utf-8-sig"))
    defaults: dict[str, Any] = raw.get("defaults", {})
    endpoints: dict[str, Any] = raw.get("endpoints", {})
    secrets = read_env_file(SECRETS_ENV_PATH)

    desired: dict[str, dict[str, Any]] = {}
    for model_id, override in endpoints.items():
        # defaults + override: env объединяется по ключам, остальные поля перекрываются целиком.
        spec: dict[str, Any] = {**defaults, **override}
        spec["env"] = {**defaults.get("env", {}), **override.get("env", {})}
        spec["env"] = {
            key: resolve_secrets(str(value), secrets, model_id) for key, value in spec["env"].items()
        }
        desired[model_id] = spec

    # Защита от рассинхрона: модель показывается в приложении, но эндпоинта под неё нет.
    # Без этой проверки ошибка всплыла бы только как 502 у пользователя.
    if MODELS_CONFIG_PATH.exists():
        app_models = {item["id"] for item in json.loads(MODELS_CONFIG_PATH.read_text(encoding="utf-8-sig"))}
        missing = app_models - desired.keys()
        if missing:
            raise SystemExit(
                f"В {MODELS_CONFIG_PATH.name} есть модели без блока в runpod_endpoints.json: "
                + ", ".join(sorted(missing))
            )

    return desired


# --------------------------------------------------------------------------------------
# Шаг 2. Фактическое состояние
# --------------------------------------------------------------------------------------


def api(client: httpx.Client, method: str, path: str, **kwargs: Any) -> Any:
    """Вызов REST API с внятной ошибкой вместо голого HTTPStatusError."""
    response = client.request(method, f"{API_BASE}{path}", **kwargs)
    if response.status_code == 401:
        raise SystemExit(
            f"RunPod API {method} {path} -> 401.\n"
            f"Ключ из {SECRETS_ENV_PATH} не имеет прав на управление эндпоинтами.\n"
            "Ключ, которым бэкенд вызывает инференс, для этого не годится: нужен ключ\n"
            "с правами на чтение/запись (RunPod console -> Settings -> API Keys).\n"
            f"Положите его в {SECRETS_ENV_PATH} как {ADMIN_KEY_VAR}."
        )
    if response.status_code >= 400:
        raise SystemExit(f"RunPod API {method} {path} -> {response.status_code}: {response.text}")
    if response.status_code == 204 or not response.content:
        return None
    return response.json()


def fetch_actual(client: httpx.Client) -> dict[str, dict[str, Any]]:
    """Один запрос за всем текущим состоянием. Возвращает {имя эндпоинта: объект}."""
    items = api(client, "GET", "/endpoints", params={"includeTemplate": "true"}) or []
    return {item["name"]: item for item in items if str(item.get("name", "")).startswith(NAME_PREFIX)}


# --------------------------------------------------------------------------------------
# Шаг 3. Сравнение
# --------------------------------------------------------------------------------------


def diff_fields(desired: dict[str, Any], actual: dict[str, Any], fields: tuple[str, ...]) -> dict[str, Any]:
    """Сравнивает только те поля, что объявлены в конфиге.

    Незаявленные поля не трогаются: RunPod применит к ним свои дефолты, а ручные
    правки в UI не будут затираться на каждом apply.
    """
    changes: dict[str, Any] = {}
    for field in fields:
        if field not in desired:
            continue
        if actual.get(field) != desired[field]:
            changes[field] = (actual.get(field), desired[field])
    return changes


def diff_env(desired_env: dict[str, str], actual_env: dict[str, str]) -> dict[str, Any]:
    """Сравнение env по подмножеству ключей.

    Строгое сравнение словарей не годится: RunPod и сам образ подмешивают в env свои
    переменные (RUNPOD_*, PATH и т.п.), и дифф был бы непустым всегда — каждый apply
    дёргал бы бесполезный rolling release.
    """
    changes: dict[str, Any] = {}
    for key, value in desired_env.items():
        if str(actual_env.get(key)) != str(value):
            changes[key] = (actual_env.get(key), value)
    return changes


def plan_model(spec: dict[str, Any], actual: dict[str, Any] | None) -> dict[str, Any]:
    """Считает, что нужно сделать с одной моделью."""
    if actual is None:
        return {"action": "create"}

    template = actual.get("template") or {}
    return {
        "action": "update",
        "endpointId": actual["id"],
        "templateId": actual.get("templateId") or template.get("id"),
        # Шаблон: скалярные поля + env.
        "template": diff_fields(spec, template, TEMPLATE_FIELDS),
        "env": diff_env(spec.get("env", {}), template.get("env") or {}),
        # Эндпоинт: GPU и скейлинг.
        "endpoint": diff_fields(spec, actual, ENDPOINT_DIFF_FIELDS),
    }


def mask(key: str, value: Any) -> str:
    return "***" if value is not None and SECRET_ENV_PATTERN.search(key) else repr(value)


def print_plan(model_id: str, spec: dict[str, Any], change: dict[str, Any]) -> bool:
    """Печатает дифф по одной модели. Возвращает True, если есть что применять."""
    name = endpoint_name(model_id)

    if change["action"] == "create":
        print(f"\n  {model_id}  ({name})")
        print("    CREATE  шаблон + эндпоинт")
        print(f"      imageName  {spec.get('imageName')}")
        print(f"      gpuTypeIds {spec.get('gpuTypeIds')} x{spec.get('gpuCount', 1)}")
        for key, value in sorted(spec.get("env", {}).items()):
            print(f"      env.{key} = {mask(key, value)}")
        return True

    template_changes = change["template"]
    env_changes = change["env"]
    endpoint_changes = change["endpoint"]
    if not template_changes and not env_changes and not endpoint_changes:
        print(f"\n  {model_id}  ({name})\n    noop")
        return False

    print(f"\n  {model_id}  ({name})")
    if template_changes or env_changes:
        print(f"    PATCH шаблон  {change['templateId']}   (rolling release)")
        for key, (was, now) in sorted(template_changes.items()):
            print(f"      {key}: {was!r} -> {now!r}")
        for key, (was, now) in sorted(env_changes.items()):
            print(f"      env.{key}: {mask(key, was)} -> {mask(key, now)}")
    if endpoint_changes:
        print(f"    PATCH эндпоинт {change['endpointId']}")
        for key, (was, now) in sorted(endpoint_changes.items()):
            print(f"      {key}: {was!r} -> {now!r}")
    return True


# --------------------------------------------------------------------------------------
# Шаг 4. Применение
# --------------------------------------------------------------------------------------


def create_endpoint(client: httpx.Client, model_id: str, spec: dict[str, Any]) -> str:
    """Создание с нуля: сначала шаблон (в нём образ и env), затем эндпоинт со ссылкой на него."""
    name = endpoint_name(model_id)

    # Если предыдущий apply упал между двумя POST, шаблон уже мог остаться — переиспользуем его.
    existing = next(
        (item for item in (api(client, "GET", "/templates") or []) if item.get("name") == name),
        None,
    )
    if existing:
        template_id = existing["id"]
        api(
            client,
            "PATCH",
            f"/templates/{template_id}",
            json={
                "imageName": spec["imageName"],
                "containerDiskInGb": spec.get("containerDiskInGb", 30),
                "env": spec.get("env", {}),
            },
        )
    else:
        template = api(
            client,
            "POST",
            "/templates",
            json={
                "name": name,
                "imageName": spec["imageName"],
                "isServerless": True,
                "containerDiskInGb": spec.get("containerDiskInGb", 30),
                "env": spec.get("env", {}),
            },
        )
        template_id = template["id"]

    payload: dict[str, Any] = {"name": name, "templateId": template_id, "computeType": "GPU"}
    payload.update({field: spec[field] for field in ENDPOINT_FIELDS if field in spec})
    endpoint = api(client, "POST", "/endpoints", json=payload)
    return str(endpoint["id"])


def apply_model(client: httpx.Client, model_id: str, spec: dict[str, Any], change: dict[str, Any]) -> str:
    """Применяет одну модель и возвращает id её эндпоинта."""
    if change["action"] == "create":
        endpoint_id = create_endpoint(client, model_id, spec)
        print(f"  {model_id}: создан эндпоинт {endpoint_id}")
        return endpoint_id

    endpoint_id = str(change["endpointId"])

    # PATCH шаблона. env отправляется как merge поверх текущего, а не заменой:
    # так переменные, которых нет в нашем конфиге, гарантированно переживут apply
    # независимо от того, заменяет RunPod объект целиком или мержит сам.
    if change["template"] or change["env"]:
        template_id = change["templateId"]
        if not template_id:
            raise SystemExit(f"[{model_id}] у эндпоинта {endpoint_id} нет шаблона — поправьте вручную в UI")
        actual_env = (api(client, "GET", f"/templates/{template_id}") or {}).get("env") or {}
        body: dict[str, Any] = {field: spec[field] for field in TEMPLATE_FIELDS if field in spec}
        body["env"] = {**actual_env, **spec.get("env", {})}
        api(client, "PATCH", f"/templates/{template_id}", json=body)
        print(f"  {model_id}: обновлён шаблон {template_id} (rolling release)")

    # PATCH эндпоинта — только заявленные в конфиге поля.
    if change["endpoint"]:
        body = {field: spec[field] for field in ENDPOINT_FIELDS if field in spec}
        api(client, "PATCH", f"/endpoints/{endpoint_id}", json=body)
        print(f"  {model_id}: обновлён эндпоинт {endpoint_id}")

    return endpoint_id


def destroy_endpoints(client: httpx.Client, actual: dict[str, dict[str, Any]], assume_yes: bool) -> None:
    """Удаление. Воркеры сначала гасятся в ноль, затем DELETE."""
    if not actual:
        print("Эндпоинтов doglyad-* не найдено.")
        return

    print("Будут удалены:")
    for name, item in actual.items():
        print(f"  {name}  ({item['id']})")
    if not assume_yes and input("Введите 'yes' для подтверждения: ").strip() != "yes":
        print("Отменено.")
        return

    for name, item in actual.items():
        api(client, "PATCH", f"/endpoints/{item['id']}", json={"workersMin": 0, "workersMax": 0})
        api(client, "DELETE", f"/endpoints/{item['id']}")
        print(f"  удалён {name}")


# --------------------------------------------------------------------------------------
# Шаг 5. Карта URL для бэкенда
# --------------------------------------------------------------------------------------


def print_urls(urls: dict[str, str], write: bool) -> None:
    """Печатает JSON в формате backend/main/secrets/runpod_endpoint.json."""
    payload = json.dumps(urls, indent=2, ensure_ascii=False)
    print(f"\n{URLS_OUTPUT_PATH}:\n")
    print(payload)
    if write:
        URLS_OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
        URLS_OUTPUT_PATH.write_text(payload + "\n", encoding="utf-8")
        print(f"\nЗаписано в {URLS_OUTPUT_PATH}")
    else:
        print("\nСверьте глазами и скопируйте в файл (или запустите с --write).")


# --------------------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------------------


def main() -> int:
    parser = argparse.ArgumentParser(description="Синхронизация serverless-эндпоинтов RunPod с конфигом.")
    parser.add_argument("command", choices=("plan", "apply", "urls", "destroy"))
    parser.add_argument("--write", action="store_true", help="записать secrets/runpod_endpoint.json")
    parser.add_argument("--yes", action="store_true", help="не спрашивать подтверждение (destroy)")
    args = parser.parse_args()

    env = read_env_file(SECRETS_ENV_PATH)
    api_key = env.get(ADMIN_KEY_VAR) or env.get(INFERENCE_KEY_VAR)
    if not api_key:
        raise SystemExit(f"Ни {ADMIN_KEY_VAR}, ни {INFERENCE_KEY_VAR} не найдены в {SECRETS_ENV_PATH}")

    with httpx.Client(headers={"Authorization": f"Bearer {api_key}"}, timeout=60.0) as client:
        # Шаг 2 нужен всем командам.
        actual = fetch_actual(client)

        if args.command == "destroy":
            destroy_endpoints(client, actual, args.yes)
            return 0

        if args.command == "urls":
            # Имя эндпоинта не даёт восстановить model_id (слэш заменён дефисом),
            # поэтому идём от конфига: для каждой модели ищем её эндпоинт по имени.
            desired = load_desired()
            urls = {
                model_id: RUN_URL_TEMPLATE.format(endpoint_id=actual[endpoint_name(model_id)]["id"])
                for model_id in desired
                if endpoint_name(model_id) in actual
            }
            print_urls(urls, args.write)
            return 0

        # Шаги 1 и 3.
        desired = load_desired()
        plan = {
            model_id: plan_model(spec, actual.get(endpoint_name(model_id)))
            for model_id, spec in desired.items()
        }

        print(f"План ({len(desired)} модели):")
        has_changes = False
        for model_id, spec in desired.items():
            if print_plan(model_id, spec, plan[model_id]):
                has_changes = True

        if args.command == "plan":
            print("\nИзменений нет." if not has_changes else "\nЗапустите apply, чтобы применить.")
            return 0

        # Шаг 4.
        print("\nПрименение:")
        urls = {}
        for model_id, spec in desired.items():
            urls[model_id] = RUN_URL_TEMPLATE.format(
                endpoint_id=apply_model(client, model_id, spec, plan[model_id])
            )

        # Шаг 5.
        print_urls(urls, args.write)
        return 0


if __name__ == "__main__":
    sys.exit(main())
