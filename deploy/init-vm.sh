#!/usr/bin/env bash
#
# Initializes a VM from the local repository without opening an interactive SSH
# shell. Uploads the current bootstrap over stdin, reboots the VM, waits for it to
# return, verifies the installed stack, and starts the interactive Tailscale login.
#
#   deploy/init-vm.sh main USER@HOST
#   deploy/init-vm.sh inference USER@HOST
#
# The SSH key comes from the agent or ~/.ssh/config. To point at a file:
#   DOGLYAD_SSH_KEY=~/.ssh/<key> deploy/init-vm.sh inference USER@HOST

set -euo pipefail

usage() {
    awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' "${BASH_SOURCE[0]}" >&2
    exit 1
}

log() { echo "==> $*"; }

ROLE="${1:-}"
TARGET="${2:-}"
case "$ROLE" in
main | inference) ;;
*) usage ;;
esac
[ -n "$TARGET" ] || usage
case "$TARGET" in
-* | *[[:space:]]*)
    echo "Invalid SSH target: expected USER@HOST or an SSH config host alias" >&2
    exit 1
    ;;
esac

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP="$REPO_ROOT/deploy/bootstrap.sh"
[ -r "$BOOTSTRAP" ] || { echo "No bootstrap at $BOOTSTRAP" >&2; exit 1; }

SSH_COMMAND=(ssh)
if [ -n "${DOGLYAD_SSH_KEY:-}" ]; then
    SSH_COMMAND+=(-i "$DOGLYAD_SSH_KEY")
fi

run_bootstrap() {
    # ROLE is restricted by the exhaustive case above before it is inserted into
    # the remote command. The script body itself travels over stdin.
    # shellcheck disable=SC2029
    "${SSH_COMMAND[@]}" "$TARGET" \
        "if [ \"\$(id -u)\" -eq 0 ]; then bash -s -- '$ROLE'; else sudo bash -s -- '$ROLE'; fi" \
        <"$BOOTSTRAP"
}

log "$ROLE: checking SSH access to $TARGET"
BOOT_ID="$("${SSH_COMMAND[@]}" "$TARGET" 'cat /proc/sys/kernel/random/boot_id')"

log "$ROLE: running bootstrap"
run_bootstrap

log "$ROLE: rebooting"
"${SSH_COMMAND[@]}" "$TARGET" \
    'if [ "$(id -u)" -eq 0 ]; then reboot; else sudo reboot; fi' \
    >/dev/null 2>&1 || true

log "$ROLE: waiting for the VM to return"
sleep 5
VM_READY=no
for attempt in $(seq 1 60); do
    NEW_BOOT_ID="$("${SSH_COMMAND[@]}" \
        -o ConnectTimeout=5 \
        -o ConnectionAttempts=1 \
        "$TARGET" \
        'cat /proc/sys/kernel/random/boot_id' 2>/dev/null || true)"
    if [ -n "$NEW_BOOT_ID" ] && [ "$NEW_BOOT_ID" != "$BOOT_ID" ]; then
        VM_READY=yes
        break
    fi
    if [ $((attempt % 6)) -eq 0 ]; then
        log "$ROLE: still waiting for reboot ($((attempt * 5)) seconds)"
    fi
    sleep 5
done
if [ "$VM_READY" != yes ]; then
    echo "The VM did not return after five minutes." >&2
    exit 1
fi

log "$ROLE: verifying Docker and Tailscale"
"${SSH_COMMAND[@]}" "$TARGET" \
    'docker compose version && tailscale version && systemctl is-active tailscaled'

if [ "$ROLE" = inference ]; then
    log "$ROLE: verifying the host GPU and Docker GPU access"
    if ! "${SSH_COMMAND[@]}" "$TARGET" \
        'nvidia-smi && docker run --rm --gpus all ubuntu:24.04 nvidia-smi'; then
        log "$ROLE: verification needs the post-reboot bootstrap pass"
        run_bootstrap
        "${SSH_COMMAND[@]}" "$TARGET" \
            'nvidia-smi && docker run --rm --gpus all ubuntu:24.04 nvidia-smi'
    fi
fi

TAILSCALE_IP="$("${SSH_COMMAND[@]}" "$TARGET" 'tailscale ip -4 2>/dev/null || true')"
if [ -z "$TAILSCALE_IP" ]; then
    log "$ROLE: authenticate this VM in Tailscale using the URL below"
    "${SSH_COMMAND[@]}" -t "$TARGET" \
        'if [ "$(id -u)" -eq 0 ]; then tailscale up; else sudo tailscale up; fi'
    TAILSCALE_IP="$("${SSH_COMMAND[@]}" "$TARGET" 'tailscale ip -4')"
fi

echo
log "$ROLE: VM initialized"
echo "  Tailscale IP: $TAILSCALE_IP"
echo "  Next: write /opt/doglyad/.env, then run:"
echo "      deploy/sync-secrets.sh $ROLE $TARGET"
