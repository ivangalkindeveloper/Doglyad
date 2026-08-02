#!/usr/bin/env bash
set -euo pipefail

MODEL="${1:?Usage: $0 <model_name> [port]}"
PORT="${2:-8101}"

CONTAINER_NAME="vllm-$(echo "$MODEL" | tr '/' '-')"

docker run -d \
  --name "$CONTAINER_NAME" \
  --gpus all \
  -p "${PORT}:8000" \
  ${HF_TOKEN:+-e HF_TOKEN="$HF_TOKEN"} \
  vllm/vllm-openai:latest \
  --model "$MODEL"
