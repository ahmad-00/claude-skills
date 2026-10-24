#!/usr/bin/env bash
# Read-only: report Android build versions and conventions. Usage: bash detect_versions.sh [repo_root]
set -uo pipefail
root="${1:-.}"
cd "$root" 2>/dev/null || { echo "error: cannot open $root" >&2; exit 1; }

show() { [ -f "$1" ] && { echo "== $1"; grep -nE "$2" "$1" || true; }; }
show gradle/libs.versions.toml '^(agp|android-?[Gg]radle|kotlin|ksp|compose-?[Bb]om|composeBom|hilt|room|room3|navigation|nav3|navigation3|coil|datastore|billing|health|material3)[A-Za-z0-9-]* *='
show gradle/wrapper/gradle-wrapper.properties 'distributionUrl'
show gradle.properties 'android\.(builtInKotlin|newDsl|nonTransitiveRClass)|kotlin\.|org\.gradle\.jvmargs'

echo "== module SDK levels and plugins"
find . \( -name "build.gradle.kts" -o -name "build.gradle" \) -not -path "*/build/*" 2>/dev/null | while read -r f; do
  out=$(grep -nE "compileSdk|targetSdk|minSdk|kotlin\.android|kotlin-android|kotlin-kapt|kapt\(|com\.google\.devtools\.ksp|jvmTarget|jvmToolchain" "$f" 2>/dev/null)
  [ -n "$out" ] && { echo "-- $f"; echo "$out"; }
done
grep -rqE "org\.jetbrains\.kotlin\.android|kotlin\.android\)|\"kotlin-android\"" --include=*.kts --include=*.gradle --include=*.toml . 2>/dev/null \
  && echo "NOTE: Kotlin Android plugin referenced; AGP 9 built-in Kotlin requires removing it"
grep -rqE "kapt\(|kotlin-kapt" --include=*.kts --include=*.gradle . 2>/dev/null && echo "NOTE: kapt in use; prefer KSP"
[ -d build-logic ] && echo "convention plugins: build-logic/"
grep -rl "androidx.room3" --include=*.kts --include=*.toml . 2>/dev/null | head -n 1 | sed 's/^/Room 3 in use: /'
exit 0
