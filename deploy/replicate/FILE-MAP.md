# File map — source device → target device

Paths assume user `nvidia` and repo at `~/NV-Disruptron-Gyana`. Adjust `$HOME` / username on target.

## In git (copy via clone or rsync)

| Role | Path in repo |
|------|----------------|
| Replication kit | `deploy/replicate/` |
| Bootstrap scripts | `scripts/disruptron` |
| Platform libs | `platform/scripts-lib/lib/*.sh` |
| Token budget | `platform/shared/token_budget.py` |
| NemoClaw policies (canonical) | `platform/nemoclaw/policies/*.yaml` |
| Agent workspace | `features/agent/workspace/` |
| MCP server | `platform/mcp/` |
| Docs | `docs/` |

## Replication kit mirrors (keep in sync)

| Canonical | Replica copy |
|-----------|----------------|
| `docs/OPERATIONS.md` | `deploy/replicate/docs/OPERATIONS.md` |
| `platform/nemoclaw/policies/google-calendar-mcp.yaml` | `deploy/replicate/nemoclaw/policies/google-calendar-mcp.yaml` |
| `.env.example` | `deploy/replicate/env/.env.template` |

## Host paths (not in git)

| Purpose | Source (device A) | Target (device B) |
|---------|-------------------|-------------------|
| Secrets | `~/NV-Disruptron-Gyana/.env` | Same relative path |
| OpenClaw config | `~/.openclaw/openclaw.json` | Re-run `configure` **or** copy + fix paths |
| OpenClaw sessions | `~/.openclaw/agents/disruptron/sessions/` | Optional copy |
| Calendar OAuth tokens | `~/.config/google-calendar-mcp/tokens.json` | Copy or re-auth |
| Calendar MCP repo | `~/google-calendar-mcp/` | Clone fresh + copy tokens |
| HF model weights | `~/.cache/huggingface/` | Optional rsync (large) |
| vLLM container | Docker volume / pull on start | `./scripts/disruptron vllm` |
| NemoClaw state | `~/.nemoclaw/` (if present) | Re-onboard preferred |
| cloudflared | `~/.local/bin/cloudflared` | Re-install from Cloudflare |
| Context SQLite | `~/NV-Disruptron-Gyana/data/disruptron_context.db` | Optional copy |
| Logs | `~/NV-Disruptron-Gyana/logs/` | Do not copy (regenerate) |

## rsync examples

```bash
# Repo only (no secrets)
rsync -av --exclude '.env' --exclude 'data/*.db' \
  nvidia@scan-09:~/NV-Disruptron-Gyana/ ~/NV-Disruptron-Gyana/

# Secrets (secure channel only)
scp nvidia@scan-09:~/NV-Disruptron-Gyana/.env ~/NV-Disruptron-Gyana/.env
scp nvidia@scan-09:~/.config/google-calendar-mcp/tokens.json \
  ~/.config/google-calendar-mcp/tokens.json

# Optional HF cache (hours, 100GB+)
rsync -av --progress nvidia@scan-09:~/.cache/huggingface/ ~/.cache/huggingface/
```

## Generated on target (do not copy from source)

| Artifact | Why regenerate |
|----------|----------------|
| `~/.openclaw/openclaw.json` | Hostname, tokens, MCP URLs may differ |
| Docker container `vllm-nemotron-omni` | GPU / driver binding |
| NemoClaw sandbox container | OpenShell rebuild per host |
| `deploy/replicate/state/*` | Device-specific snapshots |

## Port binding (must be free on target)

See `config/ports.env`. If a port is taken, override in `.env` and re-run `configure`.
