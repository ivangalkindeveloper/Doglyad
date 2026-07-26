#!/usr/bin/env python3
"""security-check — guard-hook Doglyad против попадания секретов и Xcode-шума в git.

Регистрируется как PreToolUse-hook на Bash в .claude/settings.json. Перехватывает
команды git add / git commit и блокирует их (exit 2), если в коммит попадут
запрещённые файлы (секреты бэкенда, Firebase-конфиг, веса модели, Xcode-состояние).

Логика:
- git commit  → проверяем уже проиндексированные файлы (git diff --cached).
- git add -A/./--all → проверяем все ожидающие изменения (git status --porcelain),
  которые команда собирается застейджить.
- git add <path> → проверяем пути, указанные в самой команде `git add`.

Удаления не блокируются: смысл хука — не дать секрету попасть в репозиторий, а
удаление, наоборот, убирает его оттуда. Поэтому пути, которых нет в рабочем
каталоге, пропускаются, а `git diff --cached` фильтруется через `--diff-filter=d`.

Exit 0 — пропустить. Exit 2 — заблокировать, причина уходит в stderr и Claude.
Любая внутренняя ошибка — тоже exit 0 (fail-open), чтобы не ломать обычную работу.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys

# Паттерны запрещённых путей (проверяются по всему пути файла в репозитории).
DENY_PATTERNS: list[tuple[str, str]] = [
    (r"(^|/)\.env(\.|$)", "секреты окружения бэкенда (.env)"),
    (r"(^|/)GoogleService-Info\.plist$", "конфигурация Firebase"),
    (r"(^|/)Config/[^/]*\.xcconfig$", "конфиг сборки (BASE_URL, ключи)"),
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


def repo_root() -> str:
    """Корень репозитория (пустая строка, если определить не удалось)."""
    lines = run_git(["rev-parse", "--show-toplevel"])
    return lines[0] if lines else ""


def exists_in_worktree(path: str, root: str) -> bool:
    """Есть ли файл в рабочем каталоге. Если нет — операция может быть только
    удалением, а удаление секрета из репозитория безопасно."""
    if not root:
        return True
    return os.path.exists(os.path.join(root, path))


def explicit_add_paths(command: str) -> list[str]:
    """Пути, перечисленные в самих вызовах `git add`. Токены из других команд
    (например `git restore --staged <путь>`) сюда не попадают."""
    paths: list[str] = []
    for match in re.finditer(r"\bgit\s+add\b([^&|;]*)", command):
        for token in re.findall(r"[\w./\-]+", match.group(1)):
            if token.startswith("-"):
                continue
            paths.append(token)
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

    root = repo_root()

    # Кандидаты на попадание в коммит: {путь: причина}.
    flagged: dict[str, str] = {}

    def flag(path: str) -> None:
        """Пометить путь, если он запрещён и при этом не является удалением."""
        reason = matches_deny(path)
        if reason and exists_in_worktree(path, root):
            flagged[path] = reason

    # 1. git commit — то, что уже в индексе (`d` исключает удаления).
    if has_git_commit(command):
        for path in run_git(["diff", "--cached", "--name-only", "--diff-filter=d"]):
            flag(path)

    # 2. broad add — всё, что будет застейджено скопом.
    if is_broad_add(command):
        for path in porcelain_paths():
            flag(path)

    # 3. Явно указанные пути (git add path/to/secret).
    for path in explicit_add_paths(command):
        flag(path)

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
