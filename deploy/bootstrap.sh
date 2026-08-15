#!/usr/bin/env bash
#
# Prepares a fresh VM to run one of the services. Installs Docker, the private
# network agent, the GPU stack where it is needed, and lays out /opt/doglyad.
#
# Run as root, straight from the repository:
#
#   curl -fsSL --retry 5 --retry-delay 3 -o /tmp/doglyad-bootstrap.sh \
#     https://raw.githubusercontent.com/ivangalkindeveloper/Doglyad/master/deploy/bootstrap.sh
#   sudo bash /tmp/doglyad-bootstrap.sh main
#   sudo bash /tmp/doglyad-bootstrap.sh inference
#
# The cloud-init files call exactly this, so a provider with user-data and one
# without end up with the same machine. Safe to re-run: every step checks first.
#
# Deliberately stops short of starting anything. Secrets arrive separately through
# deploy/sync-secrets.sh, and without them the service would not come up anyway.

set -euo pipefail

RAW="https://raw.githubusercontent.com/ivangalkindeveloper/Doglyad/master/deploy"
TARGET_DIR="/opt/doglyad"

usage() {
    awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' "$0" >&2
    exit 1
}

log() { echo "==> $*"; }

ROLE="${1:-}"
case "$ROLE" in
main | inference) ;;
*)
    [ -n "$ROLE" ] && echo "Unknown role: $ROLE (expected main or inference)" >&2 && echo >&2
    usage
    ;;
esac

if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root: pipe into 'sudo bash -s $ROLE'." >&2
    exit 1
fi

# --- apt ---------------------------------------------------------------------
# A freshly booted Ubuntu runs unattended-upgrades, which holds the dpkg lock for
# a few minutes. Waiting is the only correct answer: removing the lock file or
# killing the process leaves a half-configured package manager behind.
log "waiting for the dpkg lock"
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    sleep 5
done

log "installing base packages"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl gnupg

# --- Docker ------------------------------------------------------------------
# `docker` alone is not enough: every deployment command uses the Compose v2
# plugin. Some provider images ship the engine without it, so only skip the
# installation when the complete CLI we need is usable.
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    log "docker and the Compose plugin already present, skipping"
else
    if command -v docker >/dev/null 2>&1; then
        log "docker is present without the Compose plugin; completing the installation"
    else
        log "installing docker"
    fi
    curl -fsSL https://get.docker.com | sh
fi

if ! docker compose version >/dev/null 2>&1; then
    echo "Docker is installed, but the Compose v2 plugin is unavailable." >&2
    exit 1
fi

# --- GPU stack ---------------------------------------------------------------
if [ "$ROLE" = inference ]; then
    if nvidia-smi >/dev/null 2>&1; then
        log "NVIDIA driver already present, skipping"
    else
        log "installing the NVIDIA driver"
        DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-drivers-common
        ubuntu-drivers install --gpgpu
        NEEDS_REBOOT=yes
    fi

    # This is what lets a container see the card. Without it the
    # `capabilities: [gpu]` reservation in docker-compose fails and vLLM never
    # starts. If these commands drift, NVIDIA's installation guide is canonical;
    # the shape (add repo, install, `nvidia-ctk runtime configure`) has been stable.
    log "installing the NVIDIA Container Toolkit"
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey |
        gpg --dearmor --yes -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list |
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
            >/etc/apt/sources.list.d/nvidia-container-toolkit.list
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y nvidia-container-toolkit
    nvidia-ctk runtime configure --runtime=docker
    systemctl restart docker
fi

# --- Tailscale ---------------------------------------------------------------
# The private link between the machines: they live at different providers, so
# there is no shared subnet, and this link carries patient scans.
# Install only — `tailscale up` is run by hand so the auth key never lands in the
# metadata service.
if command -v tailscale >/dev/null 2>&1; then
    log "tailscale already present, skipping"
else
    log "installing tailscale"
    curl -fsSL https://tailscale.com/install.sh | sh
fi

# --- Stack files -------------------------------------------------------------
# Fetched from the repository rather than written here, so they cannot drift from
# deploy/ in git. The repository is the source of truth.
log "laying out $TARGET_DIR"
mkdir -p "$TARGET_DIR/logs"
curl -fsSL --retry 5 --retry-delay 3 -o "$TARGET_DIR/docker-compose.yml" "$RAW/docker-compose.$ROLE.yml"
if [ "$ROLE" = main ]; then
    curl -fsSL --retry 5 --retry-delay 3 -o "$TARGET_DIR/Caddyfile" "$RAW/Caddyfile"
fi

# --- Rights ------------------------------------------------------------------
# Given to every non-system user rather than to a named login, which keeps this
# script identical across machines and providers.
#
# UID 1000 is not a reliable stand-in for "the user I log in as" — measured on
# Yandex Cloud: their Ubuntu image already ships a built-in `ubuntu` at 1000, so
# the login from the creation form lands on 1001 and the rights went to the wrong
# account.
log "granting rights to the machine's users"
for u in $(awk -F: '$3>=1000 && $3<65534 {print $1}' /etc/passwd); do
    usermod -aG docker "$u"
done
chgrp -R docker "$TARGET_DIR"
chmod -R g+rwX "$TARGET_DIR"

echo
log "$ROLE: done"
echo
echo "  Reboot before going further — the docker group applies to new sessions only,"
if [ "${NEEDS_REBOOT:-no}" = yes ]; then
    echo "  and the NVIDIA kernel module wants a clean boot:"
else
    echo "  and it costs nothing here since nothing is running yet:"
fi
echo "      sudo reboot"
echo
if [ "$ROLE" = inference ]; then
    echo "  Then confirm the card is visible to the host and to Docker — the second"
    echo "  command is the one that catches a missing Container Toolkit:"
    echo "      nvidia-smi"
    echo "      docker run --rm --gpus all ubuntu nvidia-smi"
    echo
fi
echo "  Join the private network and note the address:"
echo "      sudo tailscale up && tailscale ip -4"
echo
echo "  Then write $TARGET_DIR/.env for this machine and, from your laptop:"
echo "      deploy/sync-secrets.sh $ROLE LOGIN@HOST"
