#!/usr/bin/env python3
"""security-check — guard-hook Doglyad против попадания секретов и Xcode-шума в git.

Регистрируется как PreToolUse-hook на Bash в .claude/settings.json. Перехватывает
команды git add / git commit и блокирует их (exit 2), если в коммит попадут
запрещённые файлы (секреты бэкенда, Firebase-конфиг, веса модели, Xcode-состояние).

Логика:
- git commit  → проверяем уже проиндексированные файлы (git diff --cached).
- git add -A/./--all → проверяем все ожидающие изменения (git status --porcelain),
  которые команда собирается застейджить.
- git add <path> → проверяем явно указанные в команде пути.

Exit 0 — пропустить. Exit 2 — заблокировать, причина уходит в stderr и Claude.
Любая внутренняя ошибка — тоже exit 0 (fail-open), чтобы не ломать обычную работу.
"""

from __future__ import annotations

import json
import re
import subprocess
import sys

# Паттерны запрещённых путей (проверяются по всему пути файла в репозитории).
DENY_PATTERNS: list[tuple[str, str]] = [
    (r"(^|/)\.env(\.|$)", "секреты окружения бэкенда (.env)"),
    (r"(^|/)GoogleService-Info\.plist$", "конфигурация Firebase"),
    (r"(^|/)Config\.xcconfig$", "сгенерированный конфиг сборки"),
    (r"\.xcuserstate$", "Xcode user state (шум)"),
    (r"(^|/)xcschememanagement\.plist$", "Xcode scheme management (шум)"),
    (r"DoglyadNeuralModel/Resources/", "веса MLX-модели"),
    (r"\.(pem|p8|p12|keystore|jks)$", "приватный ключ/сертификат"),
    (r"(^|/)id_rsa(\.|$)", "приватный SSH-ключ"),
    (r"(^|/)(secrets?|credentials?)\.(json|ya?ml|txt)$", "файл с секретами"),
]


def matches_deny(path: str) -> str | None:
    """Возвращает причину блокировки, если путь запрещён, иначе None."""
    for pattern, reason in DENY_PATTERNS:
        if re.search(pattern, path):
            return reason
    return None


def run_git(args: list[str]) -> list[str]:
    """Выполнить git-команду, вернуть непустые строки stdout (или [] при ошибке)."""
    try:
        out = subprocess.run(
            ["git", *args],
            capture_output=True,
            text=True,
            timeout=10,
        )
    except Exception:
        return []
    if out.returncode != 0:
        return []
    return [line for line in out.stdout.splitlines() if line.strip()]


def porcelain_paths() -> list[str]:
    """Пути с ожидающими изменениями (модифицированные + untracked), которые
    захватит `git add -A`."""
    paths: list[str] = []
    for line in run_git(["status", "--porcelain"]):
        # Формат: XY <path> либо XY <old> -> <new> для переименований.
        rest = line[3:] if len(line) > 3 else line
        if " -> " in rest:
            rest = rest.split(" -> ", 1)[1]
        paths.append(rest.strip().strip('"'))
    return paths


def is_broad_add(command: str) -> bool:
    """Команда стейджит всё скопом (git add -A / . / --all / -u)?"""
    return bool(
        re.search(r"\bgit\s+add\b[^&|;]*(\s-A\b|\s--all\b|\s-u\b|\s\.(\s|$))", command)
    )


def has_git_add(command: str) -> bool:
    return bool(re.search(r"\bgit\s+add\b", command))


def has_git_commit(command: str) -> bool:
    return bool(re.search(r"\bgit\s+commit\b", command))


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    if payload.get("tool_name") != "Bash":
        return 0

    command = payload.get("tool_input", {}).get("command", "") or ""
    if not (has_git_add(command) or has_git_commit(command)):
        return 0

    # Кандидаты на попадание в коммит: {путь: причина}.
    flagged: dict[str, str] = {}

    # 1. git commit — то, что уже в индексе.
    if has_git_commit(command):
        for path in run_git(["diff", "--cached", "--name-only"]):
            reason = matches_deny(path)
            if reason:
                flagged[path] = reason

    # 2. broad add — всё, что будет застейджено скопом.
    if is_broad_add(command):
        for path in porcelain_paths():
            reason = matches_deny(path)
            if reason:
                flagged[path] = reason

    # 3. Явно указанные в команде пути (git add path/to/secret).
    for token in re.findall(r"[\w./\-]+", command):
        reason = matches_deny(token)
        if reason:
            flagged[token] = reason

    if not flagged:
        return 0

    lines = [
        "🛑 security-check: команда заблокирована — в коммит попадают защищённые файлы:",
        "",
    ]
    for path, reason in sorted(flagged.items()):
        lines.append(f"  • {path} — {reason}")
    lines += [
        "",
        "Исключи их из индекса перед коммитом:",
        "  git restore --staged <путь>",
        "и застейджи изменения точечно вместо `git add -A`.",
        "Если файл нужно добавить сознательно — сделай это вручную вне этого агента.",
    ]
    print("\n".join(lines), file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main())
