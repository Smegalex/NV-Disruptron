---
name: disruptron-token-budget
description: >-
  Manage context window and token budget during multi-tool investigations.
  Use when chaining many MCP/browser/calendar calls, after /status shows high
  usage, or before pasting large tool JSON into chat.
---

# Token budget discipline (256k Nemotron Omni)

OpenClaw compacts when usage exceeds `contextWindow - reserveTokens`. Pruning trims old tool output in-memory between turns.

## Before a tool-heavy turn

1. Run **`/status`** or **`/context list`** — know how full the window is.
2. Call **`disruptron_ops__recall_conversation_context`** once (bounded SQLite recall), not full history replay.
3. Prefer **one briefing** then **targeted drills** — avoid duplicate snapshots.

## During investigation (8-step budget)

| Rule | Why |
|------|-----|
| Summarize each tool result in **≤5 bullets** before the next call | Tool JSON is the #1 context hog |
| Never paste raw MCP JSON into user chat | Use Evidence bullets with source tag |
| After 3+ tools, write key facts to **`memory/YYYY-MM-DD.md`** | Survives compaction |
| Drop stale hypotheses — don't re-fetch identical args | Saves tokens + API load |
| Use **`browser` screenshot + vision** only when MCP lacks the number | Vision tokens are expensive |

## When context is tight

- **`/compact Focus on <topic>`** — summarize older turns, keep recent tail
- Store durable facts → **`disruptron_ops__store_memory_fact`**
- Read **`analysis/metrics/latest.json`** instead of re-running pipeline
- Offer **`/new`** if the session is stale and recall + memory cover continuity

## Operator knobs (host)

```bash
./scripts/disruptron token-budget status   # computed reserve/keepRecent/char caps
./scripts/disruptron configure             # apply to openclaw.json
```

Env overrides: `DISRUPTRON_CONTEXT_WINDOW`, `DISRUPTRON_COMPACTION_KEEP_RECENT`, `DISRUPTRON_MEMORY_FLUSH_THRESHOLD` — see `docs/CONTEXT.md`.

## Output format under pressure

Still use **Situation → Impact → Evidence → Actions**, but Evidence is **max 3 bullets** until the user asks for depth.
