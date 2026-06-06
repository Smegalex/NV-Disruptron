# MCP tools — routing guide

OpenClaw prefixes: `disruptron_ops__*` (slim), `google_calendar__*` (host calendar MCP).

## Start here

| Tool | When |
|------|------|
| `get_london_city_briefing` | **Every investigation** — city-wide live snapshot |
| `recall_conversation_context` | Start of interactive turn — prior chat facts |
| `get_disruptron_ops_health` | Debugging only |

## Decision tree (after briefing)

```
User intent unclear? → skill: disruptron-investigation
├─ Tube / rail / line named?     → get_london_traffic_snapshot, score_line_disruption_impact
├─ Roads / driving?              → get_all_road_status, get_street_disruptions
├─ EV / chargers / parking?      → get_ev_charge_summary, get_parking_and_charging_snapshot
├─ Postcode / ward / IMD?        → lookup_ward_by_postcode, get_ward_profile
├─ Calendar / "before meeting"?  → google_calendar__list-events, get-freebusy (timing only)
├─ Live webpage / map?           → browser → then MCP for numbers
└─ Compare / policy / report?    → disruptron-multi-tool-analysis → deep-research
```

## Slim catalog (`disruptron_ops__`)

| Tool | Purpose |
|------|---------|
| `get_london_city_briefing` | City-wide live snapshot |
| `get_london_traffic_snapshot` | Full transport snapshot |
| `get_parking_and_charging_snapshot` | EV + car parks |
| `get_ev_charge_summary` | Connector availability counts |
| `score_line_disruption_impact` | Line → ward equity scoring |
| `get_all_road_status` | Road corridors |
| `get_street_disruptions` | Closures / restrictions |
| `lookup_ward_by_postcode` | Postcode prefix → ward |
| `get_ward_profile` | Ward IMD profile |
| `store_memory_fact` / `recall_conversation_context` | Cross-session memory |

## Calendar MCP (`google_calendar__`)

Use for **timing context only** — never read event titles aloud (VOICE.md).

| Tool | Purpose |
|------|---------|
| `list-events` | Events in a time window |
| `get-freebusy` | Busy blocks before trips |
| `get-current-time` | Anchor "now" for vague "later" queries |
| `search-events` | When user mentions a meeting type without time |

## Other capabilities

| Capability | Use when |
|------------|----------|
| `web_fetch` | Stable public docs (TfL API, data.london.gov.uk) |
| `browser` | Live pages, maps, screenshots + vision |
| `message` | Proactive alerts (heartbeat / material change) |

Example call: `disruptron_ops__get_london_city_briefing`
