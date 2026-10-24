# Claude skills: senior engineers

Generic, project-agnostic Agent Skills for Claude Code (and the Claude app):

| Skill | Use it for |
|---|---|
| `senior-django-backend` | Django / DRF models, migrations, APIs, tasks, reviews, upgrades |
| `senior-nextjs-frontend` | Next.js App Router, React, TypeScript, caching, auth, reviews, upgrades |
| `senior-ios-swiftui` | Swift / SwiftUI apps, concurrency, release readiness, reviews |
| `senior-android-kotlin` | Kotlin / Compose apps, AGP 9 builds, release, reviews |
| `senior-devops-gcp` | Terraform on GCP, Cloud Run, GKE, IAM/WIF, CI/CD, provider upgrades |

Every skill starts by detecting the project's real versions and conventions, then follows them over its own defaults.

## Install into your local Claude Code

Pick **one** method. Using both loads every skill twice.

### Option A: symlinks (recommended for your own machines)

```bash
git clone git@github.com:<you>/claude-skills.git ~/code/claude-skills
~/code/claude-skills/scripts/install.sh
```

This links each skill into `~/.claude/skills/`. Because they are symlinks, `git pull` updates them in place. Re-run `install.sh` only when a new skill is added.

Other options:

```bash
scripts/install.sh --list                         # what's installed
scripts/install.sh --only senior-devops-gcp       # just one skill
scripts/install.sh --project ~/code/some-repo     # into that repo's .claude/skills/
scripts/install.sh --copy                         # copies instead of links
scripts/install.sh --uninstall                    # remove what this repo installed
```

### Option B: plugin marketplace (good for sharing with a team)

Inside Claude Code:

```
/plugin marketplace add <you>/claude-skills
/plugin install senior-engineers@eng-skills
```

For a private repo, teammates need read access to it. Relative-path plugin sources need a recent Claude Code version.

### Check it works

Run `/skills` in Claude Code. Then try a real task in a project, e.g. "review this viewset" or "upgrade our google provider to v8". The matching skill should load and run its version-detection step first. If a skill doesn't trigger, name it in the prompt ("use the senior-devops-gcp skill to…").

## Use in the Claude app (optional)

The Claude app doesn't read from GitHub. Download the zips from the latest GitHub Release (or run `scripts/package.sh`) and upload each one in **Customize > Skills**.

## Repo layout

```
.claude-plugin/marketplace.json          # marketplace catalog (name: eng-skills)
plugins/senior-engineers/
  .claude-plugin/plugin.json             # plugin manifest
  skills/<skill-name>/SKILL.md           # the skills
  skills/<skill-name>/references/        # loaded on demand
  skills/<skill-name>/scripts/           # read-only helper scripts
scripts/install.sh                       # local install (symlink/copy)
scripts/validate.py                      # checks every skill (CI runs it)
scripts/package.sh                       # builds dist/*.zip
.github/workflows/skills.yml             # validate on PR; release zips on tag
```

## Editing and releasing

1. Edit a skill on a branch. Keep `SKILL.md` lean; put version facts in `references/versions.md` and update its `last-verified` date.
2. Run `pip install pyyaml && python scripts/validate.py`.
3. Open a PR; CI validates and smoke-tests the installer.
4. To release: bump `version` in `marketplace.json`, `plugin.json` and `CHANGELOG.md`, then
   `git tag v1.0.1 && git push origin v1.0.1`. CI creates the GitHub Release with one zip per skill.

Marketplace users pick up new versions with `/plugin marketplace update eng-skills` (or Claude Code's auto-update, if enabled).

## Adding a new skill

1. Create `plugins/senior-engineers/skills/<new-name>/SKILL.md` (folder name = `name` in frontmatter).
2. Add `references/` and `scripts/` as needed. No README inside the skill folder.
3. Validate, then re-run `scripts/install.sh` locally.

## Maintenance

Re-verify each `references/versions.md` quarterly, starting with lines marked **verify**. Treat these skills as code: review changes in PRs.
