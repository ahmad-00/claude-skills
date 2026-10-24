#!/usr/bin/env bash
# Read-only: report Django-stack versions and conventions. Usage: bash detect_versions.sh [repo_root]
set -uo pipefail
root="${1:-.}"
cd "$root" 2>/dev/null || { echo "error: cannot open $root" >&2; exit 1; }

pkgs='django|djangorestframework|django-ninja|celery|django-tasks|psycopg|psycopg2|gunicorn|uvicorn|pytest-django|factory-boy|ruff|mypy|django-stubs'

[ -f .python-version ] && echo "python (.python-version): $(cat .python-version)"
if [ -f pyproject.toml ]; then
  echo "== pyproject.toml"
  grep -nE "requires-python|^\[tool\.(poetry|uv|pytest|ruff|mypy)" pyproject.toml || true
  grep -niE "\"?($pkgs)[\"<>=~! \[]" pyproject.toml | head -n 30 || true
fi
if [ -f uv.lock ]; then
  echo "== uv.lock (resolved)"
  awk -v re="^\"($pkgs)\"$" '/^name = /{n=$3} /^version = /{ if (n ~ re) print n, $3 }' uv.lock
fi
[ -f poetry.lock ] && echo "== poetry.lock present (Poetry project)"
for f in requirements*.txt requirements/*.txt; do
  [ -f "$f" ] && { echo "== $f"; grep -iE "^($pkgs)\b" "$f" || true; }
done
echo "== layout"
[ -f manage.py ] && grep -oE "DJANGO_SETTINGS_MODULE\", \"[^\"]*" manage.py | sed 's/.*"//' | sed 's/^/settings module: /'
ls -d */settings 2>/dev/null | sed 's/^/split settings dir: /'
find . -maxdepth 3 -name "services.py" -not -path "./.venv/*" 2>/dev/null | head -n 3 | sed 's/^/service layer: /'
{ [ -f pytest.ini ] || grep -q "\[tool.pytest" pyproject.toml 2>/dev/null; } && echo "tests: pytest"
grep -rln "DB_CASCADE\|fetch_mode(" --include=*.py . 2>/dev/null | grep -v ".venv" | head -n 5 | sed 's/^/uses 6.1 APIs: /'
exit 0
