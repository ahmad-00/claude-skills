#!/usr/bin/env python3
"""Merge SARIF files from security-scan/ into one de-duplicated Markdown table.

Usage: python3 merge_sarif.py [security-scan-dir] [--min-level warning|error]
De-duplicates on (rule id, file, start line). Prints counts per tool and level,
then a table sorted by level then file. Exit code is always 0; triage is manual.
"""
import json
import sys
from pathlib import Path

LEVELS = {"error": 0, "warning": 1, "note": 2, "none": 3}


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    folder = Path(args[0] if args else "security-scan")
    min_level = "note"
    if "--min-level" in sys.argv:
        min_level = sys.argv[sys.argv.index("--min-level") + 1]
    rows, seen, per_tool = [], set(), {}
    for f in sorted(folder.glob("*.sarif")):
        try:
            data = json.loads(f.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as e:
            print(f"warn  cannot parse {f.name}: {e}")
            continue
        for run in data.get("runs", []):
            tool = run.get("tool", {}).get("driver", {}).get("name", f.stem)
            for r in run.get("results", []):
                level = r.get("level") or "warning"
                if LEVELS.get(level, 3) > LEVELS.get(min_level, 2):
                    continue
                loc = (r.get("locations") or [{}])[0].get("physicalLocation", {})
                path = loc.get("artifactLocation", {}).get("uri", "?")
                line = loc.get("region", {}).get("startLine", 0)
                rule = r.get("ruleId", "?")
                key = (rule, path, line)
                if key in seen:
                    continue
                seen.add(key)
                msg = (r.get("message", {}).get("text") or "").split("\n")[0][:110]
                rows.append((LEVELS.get(level, 3), level, tool, rule, f"{path}:{line}", msg))
                per_tool[tool] = per_tool.get(tool, 0) + 1
    if not rows:
        print("no SARIF results found in", folder)
        return
    print("## Scanner results (de-duplicated)\n")
    for tool, n in sorted(per_tool.items()):
        print(f"- {tool}: {n}")
    print("\n| level | tool | rule | location | message |\n|---|---|---|---|---|")
    for _, level, tool, rule, where, msg in sorted(rows, key=lambda x: (x[0], x[4])):
        print(f"| {level} | {tool} | `{rule}` | `{where}` | {msg.replace('|', '/')} |")
    print(f"\n{len(rows)} unique results. Triage each: confirmed / false positive / needs dynamic check.")


if __name__ == "__main__":
    main()
