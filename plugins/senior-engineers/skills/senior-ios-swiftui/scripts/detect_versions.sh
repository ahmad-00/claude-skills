#!/usr/bin/env bash
# Read-only: report iOS project toolchain settings. Usage: bash detect_versions.sh [repo_root]
set -uo pipefail
root="${1:-.}"
cd "$root" 2>/dev/null || { echo "error: cannot open $root" >&2; exit 1; }

command -v xcodebuild >/dev/null 2>&1 && xcodebuild -version 2>/dev/null | tr '\n' ' ' && echo
command -v swift >/dev/null 2>&1 && swift --version 2>/dev/null | head -n 1

found=0
while IFS= read -r pbx; do
  found=1
  echo "== $pbx"
  grep -hoE "(IPHONEOS_DEPLOYMENT_TARGET|SWIFT_VERSION|SWIFT_DEFAULT_ACTOR_ISOLATION|SWIFT_APPROACHABLE_CONCURRENCY|SWIFT_STRICT_CONCURRENCY|SWIFT_UPCOMING_FEATURE_[A-Z_]+) = [^;]+" "$pbx" | sort | uniq -c
done < <(find . -name project.pbxproj -not -path "*/Pods/*" -not -path "*/.build/*" 2>/dev/null)
[ "$found" -eq 0 ] && echo "no .xcodeproj found"

find . -name Package.swift -not -path "*/.build/*" -not -path "*/checkouts/*" 2>/dev/null | head -n 10 | while read -r p; do
  echo "== $p: $(head -n 1 "$p")"
done
res=$(find . -name Package.resolved -not -path "*/.build/*" 2>/dev/null | head -n 1)
[ -n "$res" ] && { echo "== $res (pins)"; grep -oE '"identity" : "[^"]+"|"version" : "[^"]+"' "$res" | paste - - | head -n 40; }

echo "== lifecycle / compliance"
grep -rl "UIApplicationSceneManifest" --include=*.plist . 2>/dev/null | head -n 3 | sed 's/^/scene manifest: /'
grep -rlE ": App \{" --include=*.swift . 2>/dev/null | head -n 3 | sed 's/^/SwiftUI App entry: /'
grep -rl "UIApplicationDelegate" --include=*.swift . 2>/dev/null | head -n 3 | sed 's/^/AppDelegate: /'
find . -name "PrivacyInfo.xcprivacy" -not -path "*/Pods/*" 2>/dev/null | head -n 3 | sed 's/^/privacy manifest: /'
[ -f Podfile ] && echo "dependency manager: CocoaPods (Podfile)"
grep -rl "import Testing" --include=*.swift . 2>/dev/null | head -n 1 | sed 's/^/Swift Testing used: /'
exit 0
