#!/bin/sh
set -eu

: "${SSH_TARGET_USER:?Set SSH_TARGET_USER}"
: "${SSH_TARGET_HOST:?Set SSH_TARGET_HOST}"
: "${TUNNELS:?Set TUNNELS to one or more -R or -L mappings}"

SSH_TARGET_PORT="${SSH_TARGET_PORT:-22}"
AUTOSSH_MONITOR_PORT="${AUTOSSH_MONITOR_PORT:-0}"
SSH_STRICT_HOST_KEY_CHECKING="${SSH_STRICT_HOST_KEY_CHECKING:-no}"
SSH_KEY_PATH="${SSH_KEY_PATH:-/root/.ssh/id_ed25519}"
EXTRA_SSH_ARGS="${EXTRA_SSH_ARGS:-}"

if [ ! -f "$SSH_KEY_PATH" ]; then
  echo "SSH key not found at $SSH_KEY_PATH" >&2
  exit 1
fi

set -- \
  autossh \
  -M "$AUTOSSH_MONITOR_PORT" \
  -N \
  -o "ServerAliveInterval=30" \
  -o "ServerAliveCountMax=3" \
  -o "ExitOnForwardFailure=yes" \
  -o "StrictHostKeyChecking=$SSH_STRICT_HOST_KEY_CHECKING" \
  -p "$SSH_TARGET_PORT" \
  -i "$SSH_KEY_PATH"

# shellcheck disable=SC2086
set -- "$@" $EXTRA_SSH_ARGS $TUNNELS "${SSH_TARGET_USER}@${SSH_TARGET_HOST}"

exec "$@"
