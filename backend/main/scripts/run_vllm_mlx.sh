#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:?Usage: $0 <development|production> [base_port]}"
BASE_PORT="${2:-8101}"

if [[ "$ENVIRONMENT" != "development" && "$ENVIRONMENT" != "production" ]]; then
    echo "Error: ENVIRONMENT must be 'development' or 'production', got '$ENVIRONMENT'"
    exit 1
fi

CONFIG_FILE="$(dirname "$0")/../config/${ENVIRONMENT}/ultrasound_examination_neural_models.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: config not found at $CONFIG_FILE"
    exit 1
fi

PIDS=()

cleanup() {
    echo "Stopping all vllm-mlx processes..."
    for pid in "${PIDS[@]}"; do
        kill "$pid" 2>/dev/null || true
    done
    wait
}
trap cleanup EXIT INT TERM

MODELS=$(python3 -c "
import json, sys
with open('$CONFIG_FILE') as f:
    for m in json.load(f):
        print(m['id'])
")

PORT="$BASE_PORT"
while read -r model_id; do
    [ -z "$model_id" ] && continue
    echo "Starting vllm-mlx: $model_id on port $PORT"
    vllm-mlx serve "$model_id" --port "$PORT" &
    PIDS+=($!)
    PORT=$((PORT + 1))
done <<< "$MODELS"

wait
