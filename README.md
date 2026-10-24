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

## Install

Inside Claude Code:

```
/plugin marketplace add ahmad-00/claude-skills
/plugin install senior-engineers@eng-skills
```

Or from a terminal:

```
claude plugin marketplace add ahmad-00/claude-skills
claude plugin install senior-engineers@eng-skills
```

For a private repo you need read access (SSH key or `gh auth login`). Get updates with `/plugin marketplace update eng-skills`.

Run `/skills` to check they loaded, then try a real task, e.g. "review this viewset". If a skill doesn't trigger, name it in the prompt ("use the senior-devops-gcp skill to…").

## Use in the Claude app (optional)

The Claude app doesn't read from GitHub. Download the zips from the latest GitHub Release (or run `scripts/package.sh`) and upload each one in **Customize > Skills**.

## Development

```
.claude-plugin/marketplace.json          # marketplace catalog (name: eng-skills)
plugins/senior-engineers/
  .claude-plugin/plugin.json             # plugin manifest
  skills/<skill-name>/SKILL.md           # the skills
  skills/<skill-name>/references/        # loaded on demand
  skills/<skill-name>/scripts/           # read-only helper scripts
scripts/validate.py                      # checks every skill (CI runs it)
scripts/package.sh                       # builds dist/*.zip
.github/workflows/skills.yml             # validate on push and PR
.github/workflows/release.yml            # release zips on v* tag
```

1. Edit or add a skill under `plugins/senior-engineers/skills/<name>/` (folder name = `name` in frontmatter). Keep `SKILL.md` lean; put version facts in `references/versions.md`.
2. Test locally with `/plugin marketplace add /path/to/this/repo`, and run `pip install pyyaml && python scripts/validate.py`.
3. Open a PR; CI validates it.
4. To release: bump `version` in `marketplace.json`, `plugin.json`, the `SKILL.md` files and `CHANGELOG.md`, merge, then
   `git tag v1.0.1 && git push origin v1.0.1`. CI creates the GitHub Release with one zip per skill.

Re-verify each `references/versions.md` quarterly, starting with lines marked **verify**.
