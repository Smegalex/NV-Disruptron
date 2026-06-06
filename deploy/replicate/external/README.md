# External dependencies (outside repo)

Install these on the target device before or during bootstrap.

---

## google-calendar-mcp

HTTP MCP server for Google Calendar (host :3000, sandbox via `host.openshell.internal`).

```bash
cd ~
git clone https://github.com/nspady/google-calendar-mcp.git google-calendar-mcp
cd google-calendar-mcp
npm install
npm run build
```

**OAuth (first time on device):**

```bash
cd ~/google-calendar-mcp
npm run auth
# Tokens land in ~/.config/google-calendar-mcp/tokens.json
```

**Or copy tokens from source device:**

```bash
mkdir -p ~/.config/google-calendar-mcp
scp user@source:~/.config/google-calendar-mcp/tokens.json \
  ~/.config/google-calendar-mcp/tokens.json
```

Start via Disruptron:

```bash
./scripts/disruptron calendar ensure
./scripts/disruptron calendar status
```

---

## vLLM Docker image

Pulled automatically by `./scripts/disruptron vllm`:

```
vllm/vllm-openai:v0.20.0-aarch64-cu130-ubuntu2404
```

For x86_64, change `VLLM_IMAGE` in `.env` to a matching tag from [vLLM Docker Hub](https://hub.docker.com/r/vllm/vllm-openai/tags).

**Model weights** download to `~/.cache/huggingface/` on first start (~30B NVFP4).

---

## OpenClaw CLI

```bash
npm install -g openclaw
openclaw --version
```

Gateway systemd unit (if used):

```bash
# After configure — see docs/NEMOCLAW.md / project setup
openclaw gateway restart
```

---

## NemoClaw / OpenShell

Follow NVIDIA Spark docs: [NemoClaw policy setup](https://build.nvidia.com/spark/nemoclaw-applications/policy-setup)

Project wrapper:

```bash
./scripts/disruptron nemoclaw onboard
./scripts/disruptron nemoclaw policy-setup --tunnel
```

Requires NemoClaw CLI on PATH (install per NVIDIA instructions for your Spark image).

---

## cloudflared (Telegram egress / tunnel)

User-space install (no root):

```bash
mkdir -p ~/.local/bin
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 \
  -o ~/.local/bin/cloudflared
chmod +x ~/.local/bin/cloudflared
```

Used by `./scripts/disruptron nemoclaw policy-setup --tunnel`.

---

## uv (Python)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
# or use existing: /home/nvidia/.local/bin/uv
```

MCP deps:

```bash
cd ~/NV-Disruptron-Gyana
uv sync --project platform/mcp
```

---

## ElevenLabs

API key at [elevenlabs.io](https://elevenlabs.io) → set `ELEVENLABS_API_KEY` in `.env`.

---

## Telegram bot

1. Message [@BotFather](https://t.me/BotFather) → `/newbot`
2. Copy token → `TELEGRAM_BOT_TOKEN` in `.env`
3. `./scripts/disruptron configure --channels`
4. Pair DMs: `openclaw channels pair telegram`
