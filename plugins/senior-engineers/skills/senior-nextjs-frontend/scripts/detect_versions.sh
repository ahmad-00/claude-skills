#!/usr/bin/env bash
# Read-only: report Next.js/React stack versions and conventions. Usage: bash detect_versions.sh [repo_root]
set -uo pipefail
root="${1:-.}"
cd "$root" 2>/dev/null || { echo "error: cannot open $root" >&2; exit 1; }
[ -f package.json ] || { echo "no package.json in $(pwd)"; exit 0; }

for l in pnpm-lock.yaml package-lock.json yarn.lock bun.lock bun.lockb; do [ -f "$l" ] && echo "lockfile: $l"; done
if command -v node >/dev/null 2>&1; then
  node -e '
    const p = require("./package.json"); const all = {...p.dependencies, ...p.devDependencies};
    const keys = ["next","react","react-dom","typescript","tailwindcss","@tailwindcss/postcss","vitest","jest","@playwright/test","eslint","@biomejs/biome","zod","next-auth","better-auth","babel-plugin-react-compiler"];
    for (const k of keys) if (all[k]) {
      let installed = ""; try { installed = require(require.resolve(k + "/package.json", {paths:[process.cwd()]})).version; } catch {}
      console.log(`${k}: declared ${all[k]}${installed ? " | installed " + installed : ""}`);
    }
    if (p.engines) console.log("engines:", JSON.stringify(p.engines));
    if (p.packageManager) console.log("packageManager:", p.packageManager);
  ' 2>/dev/null || echo "warn: could not parse package.json with node"
else
  grep -E '"(next|react|typescript|tailwindcss|vitest|@playwright/test)"' package.json
fi
echo "== structure"
for d in app src/app pages src/pages; do [ -d "$d" ] && echo "dir: $d"; done
for f in proxy.ts src/proxy.ts middleware.ts src/middleware.ts AGENTS.md CLAUDE.md; do [ -f "$f" ] && echo "file: $f"; done
[ -d node_modules/next/dist/docs ] && echo "bundled docs: node_modules/next/dist/docs"
cfg=$(ls next.config.* 2>/dev/null | head -n 1)
[ -n "$cfg" ] && { echo "== $cfg"; grep -nE "cacheComponents|partialPrefetching|reactCompiler|experimental|ppr|useCache" "$cfg" || true; }
edge=$(grep -rlE "runtime\s*=\s*['\"]edge['\"]" --include=*.ts --include=*.tsx app src 2>/dev/null | head -n 10)
[ -n "$edge" ] && { echo "WARNING runtime='edge' found (deprecated/unsupported in 16.3+):"; echo "$edge"; }
exit 0
