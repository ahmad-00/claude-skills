#!/usr/bin/env python3
"""Validate every skill in plugins/*/skills/ against the Agent Skills rules.

Checks: frontmatter present; name rules (<=64 chars, lowercase/digits/hyphens,
matches folder, no reserved words); description (non-empty, <=1024 chars, no
angle brackets); SKILL.md body <=500 lines; no README.md in skill folders;
every references/ or scripts/ path mentioned in SKILL.md exists; shell scripts
pass `bash -n`; marketplace.json and plugin.json parse and carry the same version
(SKILL.md must not carry a version of its own).
Exit code 1 if anything fails. Requires PyYAML (pip install pyyaml).
"""
import json
import re
import subprocess
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit("PyYAML missing: pip install pyyaml")

ROOT = Path(__file__).resolve().parent.parent
NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
RESERVED = ("anthropic", "claude")
errors, warnings = [], []


def err(msg):
    errors.append(msg)


def check_skill(skill_dir: Path):
    rel = skill_dir.relative_to(ROOT)
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.is_file():
        err(f"{rel}: missing SKILL.md")
        return
    text = skill_md.read_text(encoding="utf-8")
    m = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.S)
    if not m:
        err(f"{rel}/SKILL.md: missing YAML frontmatter")
        return
    try:
        fm = yaml.safe_load(m.group(1)) or {}
    except yaml.YAMLError as e:
        err(f"{rel}/SKILL.md: invalid YAML frontmatter: {e}")
        return
    body = m.group(2)

    name = str(fm.get("name", ""))
    if not name:
        err(f"{rel}: frontmatter 'name' missing")
    else:
        if len(name) > 64 or not NAME_RE.match(name):
            err(f"{rel}: name '{name}' must be <=64 chars of lowercase letters, digits, single hyphens")
        if name != skill_dir.name:
            err(f"{rel}: name '{name}' must match folder '{skill_dir.name}'")
        if any(r in name for r in RESERVED):
            err(f"{rel}: name must not contain {RESERVED}")

    desc = str(fm.get("description", "")).strip()
    if not desc:
        err(f"{rel}: frontmatter 'description' missing")
    elif len(desc) > 1024:
        err(f"{rel}: description is {len(desc)} chars (max 1024)")
    elif "<" in desc or ">" in desc:
        err(f"{rel}: description must not contain angle brackets")

    lines = body.count("\n") + 1
    if lines > 500:
        err(f"{rel}/SKILL.md: body is {lines} lines (max 500)")
    elif lines > 350:
        warnings.append(f"{rel}/SKILL.md: body is {lines} lines (target <=350)")

    if (skill_dir / "README.md").exists():
        err(f"{rel}: remove README.md (put docs in SKILL.md or references/)")

    for ref in sorted(set(re.findall(r"`((?:references|scripts)/[\w./-]+)`", body))):
        if not (skill_dir / ref).exists():
            err(f"{rel}/SKILL.md: references missing file '{ref}'")

    for sh in skill_dir.glob("scripts/*.sh"):
        r = subprocess.run(["bash", "-n", str(sh)], capture_output=True, text=True)
        if r.returncode != 0:
            err(f"{sh.relative_to(ROOT)}: bash syntax error: {r.stderr.strip()}")

    md = fm.get("metadata") or {}
    if "last-verified" not in md:
        warnings.append(f"{rel}: add metadata.last-verified")
    if "version" in md:
        err(f"{rel}: remove metadata.version; the plugin version lives in marketplace.json and plugin.json only")
    print(f"ok  {name or rel}  ({len(desc)} char description, {lines} line body)")


def check_manifests():
    mp_path = ROOT / ".claude-plugin" / "marketplace.json"
    try:
        mp = json.loads(mp_path.read_text())
    except Exception as e:  # noqa: BLE001
        err(f"marketplace.json: {e}")
        return
    for key in ("name", "owner", "plugins"):
        if key not in mp:
            err(f"marketplace.json: missing required '{key}'")
    for p in mp.get("plugins", []):
        src = p.get("source", "")
        if isinstance(src, str) and src.startswith("./"):
            pdir = ROOT / src
            pj = pdir / ".claude-plugin" / "plugin.json"
            if not pj.is_file():
                err(f"plugin '{p.get('name')}': missing {pj.relative_to(ROOT)}")
                continue
            meta = json.loads(pj.read_text())
            if meta.get("name") != p.get("name"):
                err(f"plugin '{p.get('name')}': name differs from plugin.json ('{meta.get('name')}')")
            if meta.get("version") != p.get("version"):
                err(f"plugin '{p.get('name')}': version differs between marketplace.json "
                    f"('{p.get('version')}') and plugin.json ('{meta.get('version')}')")


def main():
    check_manifests()
    skills = sorted(d for d in ROOT.glob("plugins/*/skills/*") if d.is_dir())
    if not skills:
        err("no skills found under plugins/*/skills/")
    for d in skills:
        check_skill(d)
    for w in warnings:
        print(f"warn  {w}")
    for e in errors:
        print(f"FAIL  {e}")
    print(f"\n{len(skills)} skill(s), {len(errors)} error(s), {len(warnings)} warning(s)")
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
