#!/usr/bin/env bash
# Verify NV-Disruptron stack health on current device.
# Usage: ./deploy/replicate/scripts/verify-device.sh
set -euo pipefail

REPLICATE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$REPLICATE_ROOT/../.." && pwd)"

# shellcheck source=/dev/null
source "$REPLICATE_ROOT/config/ports.env"

PASS=0
FAIL=0
WARN=0

ok()   { printf '  \033[32mPASS\033[0m  %s\n' "$*"; PASS=$((PASS + 1)); }
bad()  { printf '  \033[31mFAIL\033[0m  %s\n' "$*"; FAIL=$((FAIL + 1)); }
note() { printf '  \033[33mWARN\033[0m  %s\n' "$*"; WARN=$((WARN + 1)); }

check_http() {
  local name="$1" url="$2" optional="${3:-0}"
  local code
  code="$(curl -s -o /dev/null -w '%{http_code}' --connect-timeout 3 "$url" 2>/dev/null || echo "000")"
  if [[ "$code" =~ ^2 ]]; then
    ok "$name ($url → HTTP $code)"
  elif [[ "$optional" -eq 1 ]]; then
    note "$name ($url → HTTP $code, optional)"
  else
    bad "$name ($url → HTTP $code)"
  fi
}

check_cmd() {
  local name="$1"
  if command -v "$2" >/dev/null 2>&1; then
    ok "$name on PATH"
  else
    bad "$name not found ($2)"
  fi
}

echo "NV-Disruptron device verification"
echo "Repo: $REPO_ROOT"
echo

echo "== Tools =="
check_cmd "docker" docker
check_cmd "openclaw" openclaw
check_cmd "node" node
check_cmd "uv" uv
command -v nemoclaw >/dev/null 2>&1 && ok "nemoclaw on PATH" || note "nemoclaw not on PATH (needed for sandbox)"
echo

echo "== Config =="
[[ -f "$REPO_ROOT/.env" ]] && ok ".env exists" || bad ".env missing — run bootstrap-device.sh"
[[ -x "$REPO_ROOT/scripts/disruptron" ]] && ok "disruptron CLI" || bad "scripts/disruptron not executable"
echo

echo "== Endpoints =="
check_http "vLLM models" "http://127.0.0.1:${VLLM_PORT}/v1/models"
check_http "OpenClaw gateway" "http://127.0.0.1:${OPENCLAW_GATEWAY_PORT}/"
check_http "NemoClaw dashboard" "http://127.0.0.1:${NEMOCLAW_DASHBOARD_PORT}/" 1
check_http "Calendar MCP" "http://127.0.0.1:${GOOGLE_CALENDAR_MCP_PORT}/health" 1
check_http "Context API" "http://127.0.0.1:${DISRUPTRON_CONTEXT_API_PORT}/v1/context/health" 1
echo

echo "== vLLM model id =="
if command -v jq >/dev/null 2>&1; then
  MODEL_ID="$(curl -sf "http://127.0.0.1:${VLLM_PORT}/v1/models" 2>/dev/null | jq -r '.data[0].id // empty' || true)"
  if [[ "$MODEL_ID" == "nemotron-3-nano-omni" ]]; then
    ok "served model id: $MODEL_ID"
  elif [[ -n "$MODEL_ID" ]]; then
    note "served model id: $MODEL_ID (expected nemotron-3-nano-omni)"
  else
    bad "could not read vLLM model id"
  fi
else
  note "jq not installed — skipping model id check"
fi
echo

echo "== Docker =="
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q 'vllm-nemotron-omni'; then
  ok "vllm-nemotron-omni container running"
else
  note "vllm-nemotron-omni container not running — ./scripts/disruptron vllm"
fi
echo

echo "== Calendar tokens =="
[[ -f "$HOME/.config/google-calendar-mcp/tokens.json" ]] && ok "calendar OAuth tokens" || note "no calendar tokens (optional)"
echo

echo "== Summary =="
printf '  %d passed, %d failed, %d warnings\n' "$PASS" "$FAIL" "$WARN"

if [[ "$FAIL" -gt 0 ]]; then
  echo
  echo "Fix failures then re-run. See deploy/replicate/CHECKLIST.md"
  exit 1
fi
exit 0
