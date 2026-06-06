#!/usr/bin/env bash
# Bootstrap NV-Disruptron on a fresh device after git clone.
# Usage: ./deploy/replicate/scripts/bootstrap-device.sh [--skip-setup]
set -euo pipefail

REPLICATE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$REPLICATE_ROOT/../.." && pwd)"
SKIP_SETUP=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-setup) SKIP_SETUP=1; shift ;;
    -h|--help)
      echo "Usage: $0 [--skip-setup]"
      echo "  Prepare .env, directories, and MCP deps on a new machine."
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# shellcheck source=/dev/null
source "$REPLICATE_ROOT/config/ports.env"
# shellcheck source=/dev/null
source "$REPLICATE_ROOT/config/stack.env"

log() { printf '[bootstrap] %s\n' "$*"; }
warn() { printf '[bootstrap] WARN: %s\n' "$*" >&2; }
fail() { printf '[bootstrap] ERROR: %s\n' "$*" >&2; exit 1; }

cd "$REPO_ROOT"
log "Repo root: $REPO_ROOT"

# --- Prerequisites ---
check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    log "  ok  $1 ($(${2:-$1} 2>/dev/null || true))"
  else
    warn "  missing $1"
    return 1
  fi
}

log "Checking prerequisites..."
MISSING=0
check_cmd docker "docker --version" || MISSING=1
check_cmd curl "curl --version | head -1" || MISSING=1
check_cmd jq "jq --version" || MISSING=1
check_cmd node "node --version" || MISSING=1
check_cmd npm "npm --version" || MISSING=1
check_cmd git "git --version" || MISSING=1
check_cmd uv "uv --version" || warn "  uv not found — install: curl -LsSf https://astral.sh/uv/install.sh | sh"
command -v openclaw >/dev/null 2>&1 || warn "  openclaw not on PATH — npm i -g openclaw"
command -v nemoclaw >/dev/null 2>&1 || warn "  nemoclaw not on PATH — see deploy/replicate/external/README.md"

if [[ "$MISSING" -eq 1 ]]; then
  fail "Install missing prerequisites (see deploy/replicate/external/README.md)"
fi

if docker info >/dev/null 2>&1; then
  log "  ok  docker daemon reachable"
else
  warn "  docker daemon not reachable — add user to docker group or start docker"
fi

# --- .env ---
ENV_TEMPLATE="$REPLICATE_ROOT/env/.env.template"
if [[ ! -f "$REPO_ROOT/.env" ]]; then
  if [[ -f "$ENV_TEMPLATE" ]]; then
    cp "$ENV_TEMPLATE" "$REPO_ROOT/.env"
    log "Created .env from deploy/replicate/env/.env.template"
    warn "Edit .env and set ELEVENLABS_API_KEY, TELEGRAM_BOT_TOKEN, etc."
  elif [[ -f "$REPO_ROOT/.env.example" ]]; then
    cp "$REPO_ROOT/.env.example" "$REPO_ROOT/.env"
    log "Created .env from .env.example"
  else
    fail "No env template found"
  fi
else
  log ".env already exists — leaving unchanged"
fi

# --- Directories ---
mkdir -p "$REPO_ROOT/data" "$REPO_ROOT/logs" "$REPO_ROOT/features/agent/workspace/analysis"
log "Ensured data/, logs/, workspace/analysis/"

# --- Google Calendar MCP dir hint ---
CAL_DIR="${GOOGLE_CALENDAR_MCP_DIR:-$HOME/google-calendar-mcp}"
CAL_DIR="${CAL_DIR/#\~/$HOME}"
if [[ ! -d "$CAL_DIR" ]]; then
  warn "google-calendar-mcp not at $CAL_DIR — see deploy/replicate/external/README.md"
else
  log "  ok  google-calendar-mcp at $CAL_DIR"
fi

TOKENS="$HOME/.config/google-calendar-mcp/tokens.json"
if [[ -f "$TOKENS" ]]; then
  log "  ok  calendar OAuth tokens present"
else
  warn "  no calendar tokens at $TOKENS — run npm run auth in google-calendar-mcp"
fi

# --- MCP Python deps ---
if [[ "$SKIP_SETUP" -eq 0 ]]; then
  if [[ -x "$REPO_ROOT/scripts/disruptron" ]]; then
    log "Running ./scripts/disruptron setup ..."
    "$REPO_ROOT/scripts/disruptron" setup || warn "disruptron setup returned non-zero (may be ok if partial)"
  elif command -v uv >/dev/null 2>&1 && [[ -f "$REPO_ROOT/platform/mcp/pyproject.toml" ]]; then
    log "Running uv sync for platform/mcp ..."
    (cd "$REPO_ROOT/platform/mcp" && uv sync)
  fi
else
  log "Skipping disruptron setup (--skip-setup)"
fi

# --- Summary ---
log "Bootstrap complete."

cat <<EOF

Next steps on this device:
  1. Edit secrets:  \${EDITOR:-nano} $REPO_ROOT/.env
  2. Start vLLM:    ./scripts/disruptron vllm
  3. Configure:     ./scripts/disruptron configure --channels
  4. Restart GW:    openclaw gateway restart
  5. NemoClaw:      ./scripts/disruptron nemoclaw onboard
  6. Verify:        ./deploy/replicate/scripts/verify-device.sh

Full checklist: deploy/replicate/CHECKLIST.md
Operations ref: deploy/replicate/docs/OPERATIONS.md

EOF
