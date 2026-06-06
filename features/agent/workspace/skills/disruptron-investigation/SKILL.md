---
name: disruptron-investigation
description: >-
  Turn vague, underspecified, or open-ended user questions into multi-step
  investigations. Use when intent is unclear, the user says "what's going on",
  "anything I should know", "help me plan", "is it bad out there", or asks
  without naming lines/wards/tools. Decompose goals, pick tools, synthesize
  insights, and ask one sharp clarifying question only when blocked.
---

# Investigation playbook (vague inputs → insights)

## When to activate (always prefer this over guessing)

- Message is **short, fuzzy, or emotional** ("ugh commute", "London?", "EV situation")
- User names a **goal** but not data sources ("should I leave now?", "any chargers?")
- Question spans **time + place + mode** without specifics
- **Multi-domain** hint (transport + calendar + EV + equity in one breath)
- After `disruptron-ops` briefing, user still needs **actionable insight**, not a status dump

## Do NOT ask the user to pick tools

Infer a plan, execute it, then offer **optional** refinements ("Want Jubilee-only or ward detail?").

## Phase 0 — Parse (silent, before tools)

Extract slots; fill `unknown` with defaults from **USER.md** + time-of-day:

| Slot | Examples | Default if missing |
|------|----------|-------------------|
| **When** | now, tonight, tomorrow AM | `now`; check calendar MCP for next 2h |
| **Where** | home, work, "my area", postcode | USER.md `areas` labels |
| **Mode** | tube, drive, EV | USER.md `usual_modes` / `ev.enabled` |
| **Stake** | late, cost, stress, equity | `reliability` for commute windows |
| **Depth** | quick / deep | quick = 3–5 tools; deep = chain + optional research |

Write 1–2 **hypotheses** (e.g. "Jubilee delay affects E15 commute") to guide tool order.

## Phase 1 — Orient (always)

1. `disruptron_ops__recall_conversation_context` — prior session facts (interactive only)
2. `disruptron_ops__get_london_city_briefing` — city-wide live snapshot
3. **Optional:** `google_calendar__list-events` or `get-freebusy` — next 2–4h (never speak event titles; use for timing only)

## Phase 2 — Hypothesis-driven drill (pick 2–5 tools)

Use evidence to **confirm or kill** hypotheses. Never repeat identical tool+args.

| If hypothesis involves… | Tools (in order) |
|-------------------------|------------------|
| Usual tube lines | `get_london_traffic_snapshot` → `score_line_disruption_impact` (USER lines) |
| Road / drive commute | `get_all_road_status` → `get_street_disruptions` |
| EV / charging | `get_ev_charge_summary` → `get_parking_and_charging_snapshot` |
| "My area" / postcode | `lookup_ward_by_postcode` → `get_ward_profile` |
| Who suffers most | `score_line_disruption_impact` + ward IMD from briefing |
| Live page / map / news | `browser` navigate + screenshot → then MCP for numbers |
| Stale or conflicting APIs | `web_fetch` TfL/data.london.gov.uk docs + second MCP snapshot |

Cross-check: if two sources disagree, say so and trust **MCP live JSON** over memory or web copy.

## Phase 3 — Synthesize (required format)

**Situation** — one plain sentence (what's true *now*)  
**Impact on you** — tie to USER.md areas/lines/EV; no private field names in voice  
**Evidence** — 3–5 bullets, each cites tool (`disruptron_ops__…`, `google_calendar__…`, browser)  
**Recommended actions** — 1–3 concrete next steps (leave now / alternate line / charge here)  
**Confidence & gaps** — what you couldn't verify; one optional follow-up question max

## Vague query → plan (examples)

| User says | Interpret | Tool chain |
|-----------|-----------|------------|
| "How's London?" | City stress + user-relevant slice | briefing → USER lines impact → 1 equity bullet |
| "Should I drive?" | Roads vs usual tube | roads + street disruptions + briefing tube summary |
| "Anything for my trip?" | Calendar window + commute | calendar freebusy → briefing → lines + EV if enabled |
| "Chargers?" | EV near USER areas | EV summary → parking snapshot → ward lookup if prefix given |
| "Who gets hit worst?" | Equity lens | briefing equity section → score_line for worst delayed line |
| "Look at TfL" | Visual + quantitative | browser TfL status page → screenshot → MCP line snapshot |

## Escalation ladder

1. **3–5 MCP tools** + USER.md — default for vague chat  
2. **`disruptron-multi-tool-analysis`** — comparisons, 3+ domains, web_fetch  
3. **`disruptron-deep-research`** — user wants report, policy narrative, or MCP insufficient  
4. **`./scripts/run_analysis_pipeline.sh`** — stress score / metrics for "how bad vs yesterday"

## Budget & failure

- Max **8** tool steps/turn (including browser + calendar + web_fetch)  
- Max **2** identical tool+args  
- Apply skill **`disruptron-token-budget`** when chaining 4+ tools or `/status` shows high usage  
- On error: switch domain tool or summarize partial evidence; never invent numbers  
- Summarize large JSON in ≤5 bullets; stash detail in `memory/YYYY-MM-DD.md`

## Anti-patterns

- Answering from training data about **current** delays or charger counts  
- Asking "which line?" before a briefing when USER.md lists `usual_lines`  
- Dumping raw tool JSON to Telegram or TTS  
- Single-tool answer when user question implies **impact on them** (needs USER + drill-down)
