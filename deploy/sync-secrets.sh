#!/usr/bin/env bash
#
# Ships a service's secrets to its VM and applies them.
#
# Secrets are in neither git nor the image: they live on this machine and reach a
# VM only through this script.
#
#   deploy/sync-secrets.sh main USER@HOST
#   deploy/sync-secrets.sh inference USER@HOST
#
# No host defaults on purpose: sending secrets to a guessed machine is not a
# mistake worth making convenient, and this file carries no addresses of its own.
#
# The ssh key comes from the agent or ~/.ssh/config. To point at a file:
#   DOGLYAD_SSH_KEY=~/.ssh/<key> deploy/sync-secrets.sh main USER@HOST

set -euo pipefail

usage() {
    # Prints the header block above, so the two cannot drift apart.
    awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' "${BASH_SOURCE[0]}" >&2
    exit 1
}

ROLE="${1:-}"
TARGET="${2:-}"
[ -n "$ROLE" ] && [ -n "$TARGET" ] || usage

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REMOTE_DIR="/opt/doglyad"

# Everything that differs between the two deployments. The service names are
# symmetrical on purpose, so only the checks really diverge.
case "$ROLE" in
main)
    # The one container to recreate. Caddy holds the certificates and has no
    # reason to be disturbed.
    SERVICE="backend_main"
    # Reachable over HTTPS, so the result can be checked end to end.
    HAS_PUBLIC_ENDPOINT=yes
    ;;
inference)
    # Deliberately not `vllm`: recreating it reloads the model, which costs
    # minutes even with the weights already on disk.
    SERVICE="backend_inference"
    # No Caddy, no domain, port reachable only over the private network — there
    # is nothing to check from here.
    HAS_PUBLIC_ENDPOINT=no
    ;;
*)
    echo "Unknown role: $ROLE (expected main or inference)" >&2
    echo >&2
    usage
    ;;
esac

LOCAL_SECRETS="$REPO_ROOT/backend/$ROLE/secrets"
if [ ! -d "$LOCAL_SECRETS" ]; then
    echo "No secrets directory at $LOCAL_SECRETS" >&2
    exit 1
fi

SSH_OPTS=()
if [ -n "${DOGLYAD_SSH_KEY:-}" ]; then
    SSH_OPTS=(-i "$DOGLYAD_SSH_KEY")
fi

echo "==> $ROLE: $LOCAL_SECRETS  ->  $TARGET:$REMOTE_DIR/secrets"
ls -A "$LOCAL_SECRETS" | sed 's/^/      /'

# tar over ssh rather than `scp -r`: scp switched to the SFTP protocol in OpenSSH 9
# and now nests the directory when the target already exists, so repeat runs would
# quietly produce /opt/doglyad/secrets/secrets. tar also carries dotfiles, which is
# most of what is being copied here.
tar -C "$(dirname "$LOCAL_SECRETS")" -czf - "$(basename "$LOCAL_SECRETS")" |
    ssh "${SSH_OPTS[@]}" "$TARGET" "mkdir -p '$REMOTE_DIR' && tar -C '$REMOTE_DIR' -xzf -"

echo "==> applying on the VM"
ssh "${SSH_OPTS[@]}" "$TARGET" "
    set -e
    chmod -R go-rwx '$REMOTE_DIR/secrets'
    cd '$REMOTE_DIR'

    # Brings up whatever is not running — this is also the first start on a fresh
    # machine.
    docker compose up -d

    # env_file is read when a container is created, not on restart, so new secrets
    # need a recreate.
    docker compose up -d --force-recreate '$SERVICE'

    docker compose ps
"

if [ "$HAS_PUBLIC_ENDPOINT" = yes ]; then
    echo "==> checking"
    HOST="${TARGET#*@}"
    printf '      GET /application_config -> '
    curl -s -o /dev/null -w '%{http_code}\n' --max-time 20 "https://$HOST/application_config" || echo "unreachable"
    printf '      POST /v1 without a token -> '
    curl -s -o /dev/null -w '%{http_code}\n' --max-time 20 \
        -X POST "https://$HOST/v1/ultrasound_conclusion" -d '{}' || echo "unreachable"
    echo "      (200 and 401 mean the chain is healthy)"
else
    echo "==> $ROLE has no public endpoint; check the logs:"
    echo "      ssh $TARGET 'cd $REMOTE_DIR && docker compose logs --tail=40'"
fi
