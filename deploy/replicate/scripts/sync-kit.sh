#!/usr/bin/env bash
# Sync replication kit mirrors from canonical repo files.
# Run after updating OPERATIONS.md, policies, or .env.example.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
KIT="$REPO_ROOT/deploy/replicate"

cp "$REPO_ROOT/docs/OPERATIONS.md" "$KIT/docs/OPERATIONS.md"
cp "$REPO_ROOT/platform/nemoclaw/policies/"*.yaml "$KIT/nemoclaw/policies/" 2>/dev/null || true

if [[ -f "$REPO_ROOT/.env.example" ]]; then
  {
    echo "# NV-Disruptron — replication .env template (synced from .env.example + stack defaults)"
    echo "# Copy to repo root:  cp deploy/replicate/env/.env.template .env"
    echo
    cat "$REPO_ROOT/.env.example" | grep -v '^cp .env.example'
    echo
    echo "# Replication defaults (override above comments if unset)"
    echo "VLLM_SERVED_MODEL=nemotron-3-nano-omni"
    echo "NEMOCLAW_REASONING=1"
  } > "$KIT/env/.env.template"
fi

echo "Synced deploy/replicate from repo canonical files."
