# Развёртывание виртуальных машин

`deploy/` подготавливает чистую Ubuntu `amd64` VM для одного из двух сервисов:

- `main` — главный бэкенд без GPU;
- `inference` — inference-бэкенд, локальный vLLM и NVIDIA GPU.

Bootstrap устанавливает системные зависимости, но намеренно не запускает сервис:
машинная конфигурация и секреты передаются отдельно и не попадают ни в cloud-init,
ни в metadata провайдера.

## Новая VM одной командой с Mac

Нужны публичный адрес VM, SSH-доступ и `root` либо passwordless `sudo`:

```bash
make init-vm-inference TARGET=root@203.0.113.10
make init-vm-main TARGET=ubuntu@203.0.113.20
```

Команда:

1. передаёт локальный `deploy/bootstrap.sh` по SSH без интерактивного входа;
2. устанавливает Docker, Compose, Tailscale и нужный стек сервиса;
3. для inference устанавливает драйвер, NVIDIA Container Toolkit и CDI;
4. перезагружает VM и ждёт её возвращения;
5. проверяет Docker, Tailscale и, для inference, доступ GPU из контейнера;
6. запускает интерактивную авторизацию Tailscale и печатает приватный IP.

Для отдельного SSH-ключа:

```bash
DOGLYAD_SSH_KEY=~/.ssh/gpu_vm \
  make init-vm-inference TARGET=root@203.0.113.10
```

Повторный запуск безопасен: исправные компоненты проверяются и пропускаются. Журнал
каждого запуска остаётся на VM в `/var/log/doglyad-bootstrap.log`.

## Машинная конфигурация inference

После инициализации создать `/opt/doglyad/.env` на GPU VM. `TAG` — SHA успешно
собранного образа, `INFERENCE_BACKEND_BIND` — адрес из `tailscale ip -4`:

```dotenv
TAG=<git sha>
SERVED_MODEL_ID=google/medgemma-4b-it
VLLM_IMAGE=vllm/vllm-openai:v0.27.1@sha256:c2f3b1b964e47809b722b5e75b61b1e7b39a50f70388cf2bf2418f16a9f31da2
VLLM_MAX_MODEL_LEN=16384
VLLM_LIMIT_MM_PER_PROMPT=6
VLLM_MAX_NUM_SEQS=16
VLLM_GPU_MEMORY_UTILIZATION=0.90
VLLM_TENSOR_PARALLEL_SIZE=1
VLLM_REQUEST_TIMEOUT_SECONDS=120
INFERENCE_BACKEND_BIND=<tailscale ip>
INFERENCE_BACKEND_PORT=8100
```

Затем с Mac, из корня репозитория:

```bash
deploy/sync-secrets.sh inference USER@GPU_HOST
```

Скрипт отправит `backend/inference/secrets/`, запустит vLLM и inference. Первый
запуск скачивает образ и веса модели, поэтому занимает минуты.

## Связать main с GPU VM

Сначала с main VM проверить приватный маршрут; `401` означает, что сеть и сервис
работают, а App Check правильно отклонил запрос без токена:

```bash
curl --noproxy '*' -sS -o /dev/null -w '%{http_code}\n' \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{}' \
  http://<gpu tailscale ip>:8100/v1/conclusion_generation
```

Только после этой проверки обновить локальный
`backend/main/secrets/inference_endpoints.json`:

```json
{
  "google/medgemma-4b-it": "http://<gpu tailscale ip>:8100/v1/conclusion_generation"
}
```

И применить на development VM:

```bash
deploy/sync-secrets.sh main USER@MAIN_DEVELOPMENT_HOST
```

Карта endpoint читается при старте main, поэтому `sync-secrets.sh` пересоздаёт
`backend_main`. Ответы `200` от `/application_config` и `401` от `/v1` без токена
означают, что публичная часть после обновления здорова.

## Если cloud-init доступен

При создании VM можно передать один из файлов:

- `deploy/cloud-init/main.yaml`;
- `deploy/cloud-init/inference.yaml`.

Они вызывают тот же `bootstrap.sh`. Если провайдер не предоставляет user-data,
используется локальная команда `make init-vm-*`; результат одинаковый.
