#!/usr/bin/env python3
"""Актуальный список GPU RunPod и проверка gpuTypeIds в runpod_endpoints.json.

Список тянется из публичного GraphQL RunPod — ключ не нужен:

    POST https://api.runpod.io/graphql   { gpuTypes { id displayName memoryInGb } }

Это единственный полный источник. В REST API ручки по GPU нет вовсе, а enum'ы
внутри openapi.json неполные: в GPUTypeId нет Blackwell и H200, в
EndpointCreateInput.gpuTypeIds — нет MIG-вариантов.

    check   проверить gpuTypeIds в конфиге (по умолчанию)
    list    показать доступные карты

Код возврата check: 0 — всё чисто, 1 — есть проблемы.
"""

from __future__ import annotations

import argparse
import json
import re
import ssl
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any

GRAPHQL_URL = "https://api.runpod.io/graphql"
GRAPHQL_QUERY = "query { gpuTypes { id displayName memoryInGb } }"

REPO_ROOT = Path(__file__).resolve().parents[4]
DEFAULT_CONFIG = REPO_ROOT / "backend" / "config" / "runpod_endpoints.json"

# Compute capability по поколениям — API её не отдаёт.
# Важно только одно: образ должен знать архитектуру карты, иначе воркер падает с
# "no kernel image is available for execution on the device" на первой CUDA-операции.
ARCH: dict[str, tuple[str, str]] = {
    "NVIDIA A100 80GB PCIe": ("Ampere", "sm_80"),
    "NVIDIA A100-SXM4-40GB": ("Ampere", "sm_80"),
    "NVIDIA A100-SXM4-80GB": ("Ampere", "sm_80"),
    "NVIDIA A30": ("Ampere", "sm_80"),
    "NVIDIA A40": ("Ampere", "sm_86"),
    "NVIDIA RTX A2000": ("Ampere", "sm_86"),
    "NVIDIA RTX A4000": ("Ampere", "sm_86"),
    "NVIDIA RTX A4500": ("Ampere", "sm_86"),
    "NVIDIA RTX A5000": ("Ampere", "sm_86"),
    "NVIDIA RTX A6000": ("Ampere", "sm_86"),
    "NVIDIA GeForce RTX 3070": ("Ampere", "sm_86"),
    "NVIDIA GeForce RTX 3080": ("Ampere", "sm_86"),
    "NVIDIA GeForce RTX 3080 Ti": ("Ampere", "sm_86"),
    "NVIDIA GeForce RTX 3090": ("Ampere", "sm_86"),
    "NVIDIA GeForce RTX 3090 Ti": ("Ampere", "sm_86"),
    "NVIDIA L4": ("Ada", "sm_89"),
    "NVIDIA L40": ("Ada", "sm_89"),
    "NVIDIA L40S": ("Ada", "sm_89"),
    "NVIDIA RTX 2000 Ada Generation": ("Ada", "sm_89"),
    "NVIDIA RTX 4000 Ada Generation": ("Ada", "sm_89"),
    "NVIDIA RTX 4000 SFF Ada Generation": ("Ada", "sm_89"),
    "NVIDIA RTX 5000 Ada Generation": ("Ada", "sm_89"),
    "NVIDIA RTX 6000 Ada Generation": ("Ada", "sm_89"),
    "NVIDIA GeForce RTX 4070 Ti": ("Ada", "sm_89"),
    "NVIDIA GeForce RTX 4080": ("Ada", "sm_89"),
    "NVIDIA GeForce RTX 4080 SUPER": ("Ada", "sm_89"),
    "NVIDIA GeForce RTX 4090": ("Ada", "sm_89"),
    "NVIDIA H100 80GB HBM3": ("Hopper", "sm_90"),
    "NVIDIA H100 NVL": ("Hopper", "sm_90"),
    "NVIDIA H100 PCIe": ("Hopper", "sm_90"),
    "NVIDIA H200": ("Hopper", "sm_90"),
    "NVIDIA H200 NVL": ("Hopper", "sm_90"),
}

# Всё, что новее Hopper: старые образы под эти карты ядра не содержат.
RISKY_PATTERNS = ("Blackwell", "NVIDIA B200", "NVIDIA B300", "RTX 5080", "RTX 5090")

# Байт на параметр в зависимости от QUANTIZATION.
BYTES_PER_PARAM = {None: 2.0, "fp8": 1.0, "awq": 0.5, "gptq": 0.5, "int4": 0.5}

# Запас сверх весов: активации профилировки + минимальный KV-кэш.
MIN_HEADROOM_GB = 6.0
TIGHT_HEADROOM_GB = 3.0


def _post_urllib(body: str) -> str:
    request = urllib.request.Request(
        GRAPHQL_URL,
        data=body.encode(),
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return str(response.read().decode())


def _post_curl(body: str) -> str:
    # Фолбэк: у сборок Python с python.org часто нет CA-сертификатов, и urllib
    # падает с CERTIFICATE_VERIFY_FAILED. curl берёт системное хранилище.
    result = subprocess.run(
        [
            "curl", "-sS", "--max-time", "30",
            "-X", "POST", GRAPHQL_URL,
            "-H", "Content-Type: application/json",
            "-d", body,
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise SystemExit(f"Не удалось получить список GPU: {result.stderr.strip()}")
    return result.stdout


def fetch_gpu_types() -> list[dict[str, Any]]:
    body = json.dumps({"query": GRAPHQL_QUERY})
    try:
        raw = _post_urllib(body)
    except (urllib.error.URLError, ssl.SSLError):
        raw = _post_curl(body)

    payload = json.loads(raw)
    if "errors" in payload:
        raise SystemExit(f"GraphQL вернул ошибку: {payload['errors']}")
    return list(payload["data"]["gpuTypes"])


def architecture(gpu_id: str) -> tuple[str, str]:
    if gpu_id in ARCH:
        return ARCH[gpu_id]
    if any(pattern in gpu_id for pattern in RISKY_PATTERNS):
        return ("Blackwell", "sm_120")
    return ("?", "?")


def estimate_weights_gb(model_id: str, quantization: str | None) -> float | None:
    """Оценка размера весов по числу параметров в имени модели.

    google/medgemma-27b-it -> 27B -> 54 ГБ в bf16.
    Возвращает None, если распознать не удалось — тогда проверка VRAM пропускается.
    """
    matches = re.findall(r"(\d+(?:\.\d+)?)b(?:[-_]|$)", model_id.lower())
    if not matches:
        return None
    billions = float(matches[-1])
    per_param = BYTES_PER_PARAM.get((quantization or "").lower() or None, 2.0)
    return billions * per_param


def command_list(gpus: list[dict[str, Any]], min_vram: int) -> int:
    selected = sorted(
        (g for g in gpus if g["memoryInGb"] >= min_vram),
        key=lambda g: (g["memoryInGb"], g["id"]),
    )
    print(f"Доступно типов: {len(gpus)}; с VRAM >= {min_vram} ГБ: {len(selected)}\n")
    for gpu in selected:
        arch, sm = architecture(gpu["id"])
        risky = "  ⚠ новая архитектура" if sm == "sm_120" else ""
        print(f"  {gpu['memoryInGb']:>3} ГБ  {gpu['id']:<58} {arch:<8} {sm}{risky}")
    return 0


def command_check(gpus: list[dict[str, Any]], config_path: Path) -> int:
    by_id = {g["id"]: g for g in gpus}
    config = json.loads(config_path.read_text(encoding="utf-8-sig"))
    defaults = config.get("defaults", {})
    problems = 0

    print(f"Конфиг: {config_path}")
    print(f"Список RunPod: {len(gpus)} типов\n")

    for model_id, spec in config.get("endpoints", {}).items():
        merged_env = {**defaults.get("env", {}), **spec.get("env", {})}
        utilization = float(merged_env.get("GPU_MEMORY_UTILIZATION", 0.9))
        weights = estimate_weights_gb(model_id, merged_env.get("QUANTIZATION"))

        gpu_ids = spec.get("gpuTypeIds", defaults.get("gpuTypeIds"))
        weights_note = f"веса ~{weights:.0f} ГБ" if weights else "размер весов не распознан"
        print(f"{model_id}   ({weights_note}, utilization {utilization})")

        if not gpu_ids:
            print("   ✗ gpuTypeIds не задан — RunPod выдаст произвольную карту\n")
            problems += 1
            continue

        for gpu_id in gpu_ids:
            gpu = by_id.get(gpu_id)
            if gpu is None:
                print(f"   ✗ {gpu_id:<50} НЕТ ТАКОГО ID в RunPod")
                problems += 1
                continue

            vram = gpu["memoryInGb"]
            arch, sm = architecture(gpu_id)
            notes = []

            if weights is not None:
                headroom = vram * utilization - weights
                if headroom < TIGHT_HEADROOM_GB:
                    verdict, extra = "✗", "НЕ ВЛЕЗЕТ"
                    problems += 1
                elif headroom < MIN_HEADROOM_GB:
                    verdict, extra = "!", "впритык"
                else:
                    verdict, extra = "ok", ""
                notes.append(f"{vram} ГБ, свободно {headroom:.1f} ГБ {extra}".rstrip())
            else:
                verdict = "ok"
                notes.append(f"{vram} ГБ")

            if sm == "sm_120":
                verdict = "!"
                notes.append("⚠ Blackwell: нужен свежий образ, иначе no kernel image")
            elif sm == "?":
                notes.append("архитектура неизвестна — проверь вручную")

            print(f"   {verdict:<3}{gpu_id:<50} {' | '.join(notes)}")
        print()

    if problems:
        print(f"Проблем найдено: {problems}")
    else:
        print("Все gpuTypeIds корректны.")
    return 1 if problems else 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("command", nargs="?", default="check", choices=("check", "list"))
    parser.add_argument("--config", type=Path, default=DEFAULT_CONFIG)
    parser.add_argument("--min-vram", type=int, default=0, help="фильтр для list, ГБ")
    args = parser.parse_args()

    gpus = fetch_gpu_types()
    if args.command == "list":
        return command_list(gpus, args.min_vram)
    if not args.config.exists():
        raise SystemExit(f"Конфиг не найден: {args.config}")
    return command_check(gpus, args.config)


if __name__ == "__main__":
    sys.exit(main())
