"""Token budget calculator for NV-Disruptron (OpenClaw compaction + context limits).

OpenClaw auto-compacts when estimated usage exceeds:
  contextWindow - max(reserveTokens, reserveTokensFloor)

Memory flush runs when usage exceeds:
  contextWindow - effectiveReserve - softThresholdTokens

See: https://docs.openclaw.ai/concepts/context
     https://docs.openclaw.ai/reference/session-management-compaction
"""

from __future__ import annotations

import json
import os
from dataclasses import asdict, dataclass
from typing import Any


@dataclass(frozen=True)
class TokenBudget:
    context_window: int
    max_output_tokens: int
    reserve_tokens: int
    reserve_tokens_floor: int
    keep_recent_tokens: int
    memory_flush_soft_threshold: int
    compaction_trigger_tokens: int
    memory_flush_trigger_tokens: int
    max_history_share: float
    tool_result_max_chars: int
    post_compaction_max_chars: int
    recall_max_chars: int
    bootstrap_max_chars: int
    bootstrap_total_max_chars: int
    max_skills_prompt_chars: int
    context_soft_trim_max_chars: int
    context_prune_min_tool_chars: int
    max_active_transcript_bytes: int

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


def _env_int(name: str, default: int) -> int:
    raw = os.getenv(name, "").strip()
    if not raw:
        return default
    return int(raw)


def _env_float(name: str, default: float) -> float:
    raw = os.getenv(name, "").strip()
    if not raw:
        return default
    return float(raw)


def compute_token_budget(
    *,
    context_window: int | None = None,
    max_output_tokens: int | None = None,
) -> TokenBudget:
    """Derive OpenClaw + MCP char/token caps from the model context window."""
    window = context_window or _env_int("DISRUPTRON_CONTEXT_WINDOW", _env_int("VLLM_MAX_MODEL_LEN", 262144))
    max_out = max_output_tokens or _env_int("DISRUPTRON_MAX_OUTPUT_TOKENS", 4096)

    # Headroom for system prompt + tool schemas + next model output (OpenClaw reserveTokens).
    reserve_ratio = _env_float("DISRUPTRON_RESERVE_TOKENS_RATIO", 0.08)
    reserve_min = _env_int("DISRUPTRON_COMPACTION_RESERVE_TOKENS", max_out + 12_288)
    reserve = max(reserve_min, int(window * reserve_ratio))
    reserve = min(reserve, int(window * 0.18))

    floor = _env_int("DISRUPTRON_COMPACTION_RESERVE_FLOOR", 0)

    keep_ratio = _env_float("DISRUPTRON_KEEP_RECENT_RATIO", 0.10)
    keep_recent = _env_int("DISRUPTRON_COMPACTION_KEEP_RECENT", max(8192, int(window * keep_ratio)))
    keep_recent = min(keep_recent, int(window * 0.22))

    flush_soft = _env_int("DISRUPTRON_MEMORY_FLUSH_THRESHOLD", 8000)
    max_history_share = _env_float("DISRUPTRON_COMPACTION_MAX_HISTORY_SHARE", 0.45)

    effective_reserve = max(reserve, floor)
    compaction_trigger = window - effective_reserve
    memory_flush_trigger = window - effective_reserve - flush_soft

    # ~4 chars/token heuristic for MCP/tool surfaces.
    chars_per_token = _env_float("DISRUPTRON_CHARS_PER_TOKEN", 4.0)
    tool_result = _env_int(
        "DISRUPTRON_TOOL_RESULT_MAX_CHARS",
        min(12_000, max(4000, int((window * 0.012) * chars_per_token))),
    )
    post_compact = _env_int(
        "DISRUPTRON_POST_COMPACTION_MAX_CHARS",
        min(4000, max(1800, int((keep_recent * 0.08) * chars_per_token))),
    )
    recall_chars = _env_int(
        "DISRUPTRON_RECALL_MAX_CHARS",
        min(6000, max(2400, int((window * 0.006) * chars_per_token))),
    )

    bootstrap_max = _env_int("DISRUPTRON_BOOTSTRAP_MAX_CHARS", 4000)
    bootstrap_total = _env_int("DISRUPTRON_BOOTSTRAP_TOTAL_MAX_CHARS", 12_000)
    skills_max = _env_int("DISRUPTRON_MAX_SKILLS_PROMPT_CHARS", 3200)
    soft_trim = _env_int("DISRUPTRON_CONTEXT_SOFT_TRIM_MAX", min(6000, tool_result // 2))
    prune_min = _env_int("DISRUPTRON_CONTEXT_PRUNE_MIN_CHARS", max(8000, tool_result))

    transcript_mb = _env_float("DISRUPTRON_MAX_ACTIVE_TRANSCRIPT_MB", 24.0)
    transcript_bytes = int(transcript_mb * 1024 * 1024)

    return TokenBudget(
        context_window=window,
        max_output_tokens=max_out,
        reserve_tokens=reserve,
        reserve_tokens_floor=floor,
        keep_recent_tokens=keep_recent,
        memory_flush_soft_threshold=flush_soft,
        compaction_trigger_tokens=compaction_trigger,
        memory_flush_trigger_tokens=memory_flush_trigger,
        max_history_share=max_history_share,
        tool_result_max_chars=tool_result,
        post_compaction_max_chars=post_compact,
        recall_max_chars=recall_chars,
        bootstrap_max_chars=bootstrap_max,
        bootstrap_total_max_chars=bootstrap_total,
        max_skills_prompt_chars=skills_max,
        context_soft_trim_max_chars=soft_trim,
        context_prune_min_tool_chars=prune_min,
        max_active_transcript_bytes=transcript_bytes,
    )


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description="Print NV-Disruptron token budget JSON")
    parser.add_argument("--pretty", action="store_true")
    args = parser.parse_args()
    payload = compute_token_budget().to_dict()
    if args.pretty:
        print(json.dumps(payload, indent=2))
    else:
        print(json.dumps(payload))


if __name__ == "__main__":
    main()
