# Token budgeting — OpenClaw compaction + context limits (see docs/CONTEXT.md).

_disruptron_token_budget_json() {
  PYTHONPATH="$DISRUPTRON_ROOT/platform/shared${PYTHONPATH:+:$PYTHONPATH}" \
    python3 -m token_budget 2>/dev/null
}

_disruptron_token_budget_field() {
  local field="$1"
  _disruptron_token_budget_json | python3 -c "import json,sys; print(json.load(sys.stdin)['$field'])"
}

disruptron_cmd_token_budget() {
  local sub="${1:-status}"
  shift || true
  case "$sub" in
    status|show)
      echo "==> NV-Disruptron token budget (OpenClaw compaction model)"
      PYTHONPATH="$DISRUPTRON_ROOT/platform/shared${PYTHONPATH:+:$PYTHONPATH}" \
        python3 -m token_budget --pretty
      echo ""
      echo "OpenClaw inspect: /status  /context list  /context detail"
      echo "Apply: ./scripts/disruptron configure && openclaw gateway restart"
      ;;
    export)
      # Shell-export computed defaults (for debugging)
      local json
      json="$(_disruptron_token_budget_json)" || return 1
      python3 - <<'PY' "$json"
import json, sys
b = json.loads(sys.argv[1])
for k, v in b.items():
    env_key = "DISRUPTRON_BUDGET_" + k.upper()
    print(f'export {env_key}="{v}"')
PY
      ;;
    -h|help|*)
      cat <<EOF
Usage: disruptron token-budget [status|export]

  Computes reserveTokens, keepRecentTokens, tool/recall char caps from
  DISRUPTRON_CONTEXT_WINDOW (default 262144). Wired by: disruptron configure

Docs: docs/CONTEXT.md · OpenClaw: docs.openclaw.ai/concepts/context
EOF
      ;;
  esac
}
