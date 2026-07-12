---
name: github
description: Справочник по работе с git/GitHub в проекте Doglyad — какие команды доступны, конвенции веток/сообщений, удалённый репозиторий и связанные skill'ы. Используй, когда нужно понять «какие git-команды тут можно», посмотреть статус/историю/диффы или сориентироваться перед коммитом и пушем ("что по гиту", "покажи git-команды", "как тут коммитить").
---

# github — справочник по git в проекте Doglyad

Единая точка входа по работе с системой контроля версий. Декларирует, какие git-команды доступны и разрешены, каковы конвенции проекта и куда идти дальше. Сам по себе ничего не коммитит и не пушит — для отправки изменений используется skill [git-push](../git-push/SKILL.md).

## Базовые факты о репозитории

- **Основная ветка**: `master`. Разработка ведётся напрямую в неё (соло-проект) — фича-ветки не создаются без явной просьбы.
- **Удалённый репозиторий**: `origin` — GitHub `ivangalkindeveloper/Doglyad`.
- **Инструменты GitHub**: для операций на стороне GitHub (PR, issues, релизы) — CLI `gh`.

## Доступные команды (разрешены без запроса)

Инспекция состояния и истории — безопасны, разрешены в `.claude/settings.json`:

```bash
git status              # состояние рабочего каталога и индекса
git diff                # неиндексированные изменения
git diff --staged       # что уже в индексе (уйдёт в коммит)
git log --oneline -20   # последние коммиты
git show <hash>         # содержимое конкретного коммита
git branch              # список веток
git rev-parse <ref>     # резолв ссылки в хеш
git ls-files            # отслеживаемые файлы
```

Изменяющие индекс/историю — тоже разрешены, но применяй осознанно:

```bash
git add <path>          # добавить конкретные файлы в индекс
git add -A              # добавить все изменения (следит security-check hook)
git commit -m "..."     # коммит с сообщением по конвенции (см. ниже)
```

Пуш (`git push origin master`) выполняется в рамках skill [git-push](../git-push/SKILL.md), а не отдельно.

## Конвенции

- **Сообщения коммитов**: короткие, на английском, в повелительном наклонении, с заглавной буквы, без точки в конце. Примеры из истории: `Add version`, `Fix settings buttons`, `Adding skills`. Тело для мелких правок не нужно.
- **Трейлер Claude Code**: если коммит делает Claude Code, в конец сообщения добавляется
  `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
- **Форматирование перед коммитом**: Swift — `make format` (swiftformat), Python — стиль бэкенда (`make format-backend`). Коммить уже отформатированный код.
- **Никогда не `--force` без явного разрешения.** При отклонённом push (не fast-forward) — `git pull --rebase origin master`, разреши конфликты, повтори push.

## Что не коммитить (секреты и шум)

Эти пути защищены guard-hook'ом `security-check` (`.claude/hooks/security-check.py`) — попытка застейджить/закоммитить их блокируется:

- `backend/.env` — переменные окружения бэкенда (RunPod, SMTP-ключи).
- `ios/Config/Config.xcconfig` — генерируется из `Config.Development.xcconfig` / `Config.Production.xcconfig`.
- `ios/GoogleService-Info.plist` — конфигурация Firebase.
- `ios/DoglyadNeuralModel/Resources/` — веса MLX-модели.
- Xcode-шум: `*.xcuserstate`, `xcschememanagement.plist`.
- Общие секреты: `*.pem`, `*.p8`, `*.p12`, `*.keystore`, `id_rsa`, `secrets.*`, `credentials.*`.

Если такой файл попал в индекс — исключи его: `git restore --staged <путь>`.

## Куда идти дальше

- **Закоммитить и запушить** → skill [git-push](../git-push/SKILL.md).
- **Проверить сборку/тесты перед коммитом** → skill [build-verify](../build-verify/SKILL.md).
- **Операции на GitHub** (PR, issues) → CLI `gh`.
