# Replicate NV-Disruptron on a new device

**Purpose:** Copy this folder structure with the repo to another machine and run the same stack (vLLM + OpenClaw + NemoClaw + Calendar MCP + Telegram).

**Reference snapshot:** 2026-06-06 · DGX Spark GB10 · aarch64 · CUDA 13.0

---

## Quick start (new machine)

```bash
# 1. Clone repo
git clone <your-remote> ~/NV-Disruptron-Gyana
cd ~/NV-Disruptron-Gyana

# 2. Bootstrap (checks deps, creates .env, installs MCP deps)
./deploy/replicate/scripts/bootstrap-device.sh

# 3. Edit secrets
${EDITOR:-nano} .env   # ELEVENLABS_API_KEY, TELEGRAM_BOT_TOKEN, etc.

# 4. Start inference (downloads model on first run — long)
./scripts/disruptron vllm

# 5. Configure OpenClaw + channels
./scripts/disruptron configure --channels
openclaw gateway restart

# 6. NemoClaw sandbox (optional but recommended)
./scripts/disruptron nemoclaw onboard
./scripts/disruptron nemoclaw policy-setup --tunnel

# 7. Verify
./deploy/replicate/scripts/verify-device.sh
```

---

## What lives where

```
deploy/replicate/
├── README.md              ← you are here
├── CHECKLIST.md           ← step-by-step checklist
├── FILE-MAP.md            ← paths on source vs target
├── manifest.yaml          ← ports, models, policies (machine-readable)
├── docs/
│   └── OPERATIONS.md      ← full stack reference (self-contained)
├── env/
│   └── .env.template      ← copy to repo root .env
├── config/
│   ├── ports.env          ← all service ports
│   └── stack.env          ← non-secret defaults
├── external/
│   └── README.md          ← google-calendar-mcp, cloudflared, model cache
├── nemoclaw/
│   └── policies/          ← policy YAML copies (sync with platform/nemoclaw/policies/)
├── scripts/
│   ├── bootstrap-device.sh
│   └── verify-device.sh
└── state/
    └── .gitkeep           ← optional: export non-secret state snapshots here
```

The **repo itself** holds runtime logic (`platform/scripts-lib/`, `features/agent/workspace/`, etc.). This folder is the **replication kit** — templates, manifests, and bootstrap scripts.

---

## Copy from an existing device

Use [FILE-MAP.md](FILE-MAP.md) and [CHECKLIST.md](CHECKLIST.md).

**Copy with the repo (git):**
- Entire `NV-Disruptron-Gyana` tree

**Copy manually (secrets — never commit):**
| Artifact | Typical source path |
|----------|---------------------|
| Environment | `.env` (or recreate from `env/.env.template`) |
| Google Calendar OAuth | `~/.config/google-calendar-mcp/tokens.json` |
| OpenClaw gateway token | `~/.openclaw/openclaw.json` (gateway.auth.token) |
| Hugging Face cache (optional, large) | `~/.cache/huggingface/` |
| NemoClaw sandbox state (optional) | `~/.nemoclaw/` or sandbox volumes |

**External repos (install on target):**
- `~/google-calendar-mcp` — see [external/README.md](external/README.md)

---

## Hardware assumptions

| Requirement | Notes |
|-------------|-------|
| **GPU** | NVIDIA GB10 or similar with enough unified memory for 256k Nemotron Omni (~121GB works) |
| **Arch** | aarch64 (Spark image uses `vllm/vllm-openai:v0.20.0-aarch64-cu130-ubuntu2404`) |
| **CUDA** | 13.x driver compatible |
| **Docker** | User in `docker` group |
| **Node** | For OpenClaw, google-calendar-mcp |
| **uv** | Python deps (`~/.local/bin/uv` or PATH) |

For x86_64 or smaller GPUs, reduce `VLLM_MAX_MODEL_LEN` (e.g. 131072) and `VLLM_GPU_UTIL` in `.env` — see `docs/CONTEXT.md`.

---

## Port map (default)

| Service | Port |
|---------|------|
| vLLM OpenAI API | 8000 |
| OpenClaw host gateway | 18789 |
| NemoClaw sandbox dashboard | 18790 |
| google-calendar-mcp HTTP | 3000 |
| Context API | 8010 |
| AI-Q sidecar (optional) | 8001 |

Details: [config/ports.env](config/ports.env) and [manifest.yaml](manifest.yaml).

---

## After replication

```bash
./scripts/disruptron monitor
./scripts/disruptron token-budget status
./scripts/disruptron nemoclaw url          # sandbox UI + token
openclaw channels status
```

Full operator reference: [docs/OPERATIONS.md](docs/OPERATIONS.md)

---

## Keeping this bundle in sync

When you change stack defaults in the repo:

1. Update `docs/OPERATIONS.md` in the main repo, then copy:
   ```bash
   cp docs/OPERATIONS.md deploy/replicate/docs/OPERATIONS.md
   ```
2. Sync NemoClaw policies:
   ```bash
   cp platform/nemoclaw/policies/*.yaml deploy/replicate/nemoclaw/policies/
   ```
3. Refresh `env/.env.template` if new `.env` keys were added.
