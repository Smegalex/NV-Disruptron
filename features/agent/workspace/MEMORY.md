# NV-Disruptron long-term memory (compact index)

Curated durable facts only — keep this file short. Detailed notes go in `memory/YYYY-MM-DD.md`.

## Stack snapshot (2026-06-06)

- **Host:** DGX Spark GB10 · repo `/home/nvidia/NV-Disruptron-Gyana`
- **Model:** `nemotron-3-nano-omni` via vLLM Docker `:8000` · **256k** context (`262144`)
- **Reasoning:** on (vLLM nemotron_v3 parser + OpenClaw thinkingDefault=medium)
- **Host gateway:** OpenClaw `:18789` · agent `disruptron` · MCP `disruptron_ops` + `google_calendar`
- **NemoClaw sandbox:** `disruptron` · dashboard `:18790` · OpenShell policies incl. telegram + calendar
- **Telegram:** `@nv_disruptron_bot` · token in `.env` · pairing for first DM
- **Calendar MCP:** host `:3000` · tokens `~/.config/google-calendar-mcp/tokens.json`
- **Token budget:** `./scripts/disruptron token-budget status` · reserve ~21k · keepRecent ~26k
- **Skills added:** `disruptron-investigation` (vague queries), `disruptron-token-budget` (multi-tool context)
- **Full ops doc:** `docs/OPERATIONS.md`

## London mobility state (update after briefings)

- Last stress score: _(unset)_
- Last briefing time: _(unset)_
- Lines under stress: _(unset)_
- EV availability trend: _(unset)_

## User mobility (no PII — areas/lines only)

- Primary lines: see USER.md
- EV threshold alerts: default 25% availability

## Open investigations

- _(none)_

## How to use

- Before compaction, flush new facts here or to daily memory files.
- On new sessions, read this + latest `analysis/CONTEXT.md` instead of replaying full tool JSON.
- Operator reference: `docs/OPERATIONS.md`
