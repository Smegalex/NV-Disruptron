# Replication checklist

Use this when moving NV-Disruptron from device A → device B.

## Phase 0 — Target machine prerequisites

- [ ] Ubuntu 24.04 (or compatible) with NVIDIA driver + CUDA 13.x
- [ ] Docker installed; user in `docker` group
- [ ] `git`, `curl`, `jq`, `node` (≥20), `npm`
- [ ] `uv` on PATH (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
- [ ] OpenClaw CLI installed (`npm i -g openclaw` or project docs)
- [ ] NemoClaw CLI installed (see [external/README.md](external/README.md))
- [ ] Optional: `cloudflared` in `~/.local/bin/` for Telegram tunnel egress

## Phase 1 — Get the code

- [ ] Clone repo to target (e.g. `~/NV-Disruptron-Gyana`)
- [ ] Or rsync from source: `rsync -av --exclude .git/cache source/ target:~/NV-Disruptron-Gyana/`

## Phase 2 — Secrets & external data

- [ ] Create `.env` from `deploy/replicate/env/.env.template`
- [ ] Set `ELEVENLABS_API_KEY`
- [ ] Set `TELEGRAM_BOT_TOKEN` (BotFather) if using Telegram
- [ ] Copy `~/.config/google-calendar-mcp/tokens.json` if calendar already authorized
- [ ] Or run fresh OAuth in `~/google-calendar-mcp` (`npm run auth`)

## Phase 3 — External services

- [ ] Clone & build [google-calendar-mcp](external/README.md) at `~/google-calendar-mcp`
- [ ] Optional: copy HF model cache to skip re-download (`~/.cache/huggingface/`)

## Phase 4 — Bootstrap

```bash
cd ~/NV-Disruptron-Gyana
./deploy/replicate/scripts/bootstrap-device.sh
```

- [ ] MCP Python deps installed (`uv sync`)
- [ ] Context DB directory exists (`data/`)

## Phase 5 — Inference

```bash
./scripts/disruptron vllm
curl -s http://127.0.0.1:8000/v1/models | jq '.data[0].id'
```

- [ ] Model id is `nemotron-3-nano-omni` (hyphenated)
- [ ] `max_model_len` is 262144 (or your chosen window)

## Phase 6 — OpenClaw host gateway

```bash
./scripts/disruptron configure --channels
openclaw gateway restart
openclaw doctor
openclaw mcp list
```

- [ ] Agent `disruptron` bound to `vllm/nemotron-3-nano-omni`
- [ ] MCP: `disruptron_ops`, `google_calendar`
- [ ] Telegram channel paired (if enabled)

## Phase 7 — NemoClaw sandbox

```bash
./scripts/disruptron nemoclaw onboard
./scripts/disruptron nemoclaw policy-setup --tunnel
./scripts/disruptron nemoclaw recover
./scripts/disruptron nemoclaw url
```

- [ ] Sandbox name `disruptron`, dashboard on :18790
- [ ] Policies include `google-calendar-mcp`
- [ ] Sandbox MCP points to `host.openshell.internal:3000`

## Phase 8 — Verify

```bash
./deploy/replicate/scripts/verify-device.sh
./scripts/disruptron monitor
./scripts/disruptron token-budget status
```

- [ ] All checks green (or documented known warnings)
- [ ] Test message via Telegram or `./scripts/disruptron run`

## Phase 9 — Optional persistence

- [ ] Copy `data/disruptron_context.db` for conversation recall history
- [ ] Copy `features/agent/workspace/memory/` for agent daily notes
- [ ] Document new hostname in `deploy/replicate/docs/OPERATIONS.md` header

---

**Done:** Stack replicated. Operator commands: [docs/OPERATIONS.md](docs/OPERATIONS.md)
