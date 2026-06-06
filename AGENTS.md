## Learned User Preferences

- Branding is **NV-Disruptron** only — no legacy aliases in docs or scripts.
- 24/7 autonomous monitor with proactive text + ElevenLabs voice alerts; privacy-safe TTS (no PII in speech).
- EV/charging companion personalized via `features/agent/workspace/USER.md` activity profile.
- Prefer **vLLM + Nemotron Omni NVFP4** over llama.cpp GGUF for production on GB10.
- Use `uv` for Python env management; optimize for parallel execution where practical.
- NemoClaw + Nemotron Omni on DGX Spark for hackathon demos; local-first on open London data.
- Local vLLM Nemotron + OpenClaw gateway; optional AI-Q deep research on `:8001`.
- Web delivery UI lives under `features/delivery/web/` (React + Vite); gateway at `features/delivery/disruptron-api/`.

## Learned Workspace Facts

- Repo `/home/nvidia/NV-Disruptron-Gyana`; launch: `./scripts/disruptron daemon` (24/7) or `./scripts/disruptron run` (interactive).
- **Operations snapshot:** `docs/OPERATIONS.md` (models, gateways, MCP, token budget, channels).
- **Replicate on new device:** `deploy/replicate/README.md` + `./deploy/replicate/scripts/bootstrap-device.sh`.
- **Model:** `nemotron-3-nano-omni` · vLLM `:8000` · **262144** context · multimodal + reasoning on.
- **Dual gateway:** host OpenClaw `:18789` + NemoClaw sandbox `:18790` (sandbox `disruptron`).
- OpenClaw agent id: `disruptron`; MCP prefix: `disruptron_ops__*`; calendar: `google_calendar__*`; heartbeat 10m.
- NemoClaw: `./scripts/disruptron nemoclaw recover` starts calendar MCP + wires sandbox; `./scripts/disruptron nemoclaw url` for dashboard token.
- Telegram: `@nv_disruptron_bot` · `TELEGRAM_BOT_TOKEN` in `.env` · `./scripts/disruptron configure --channels`.
- Token budgeting: `./scripts/disruptron token-budget status` · skills `disruptron-investigation`, `disruptron-token-budget`.
- Voice: ElevenLabs persona `disruptron-public`; rules in `features/agent/workspace/VOICE.md`.
- Key tools: `get_london_city_briefing`, `recall_conversation_context`, `get_ev_charge_summary`.
- Google Calendar MCP: `~/google-calendar-mcp` HTTP `:3000`; auto-launched on nemoclaw recover.
- vLLM image: `vllm/vllm-openai:v0.20.0-aarch64-cu130-ubuntu2404` · `uv` at `/home/nvidia/.local/bin/uv`.
- TfL transport MCP path: `platform/mcp/transport/`.
