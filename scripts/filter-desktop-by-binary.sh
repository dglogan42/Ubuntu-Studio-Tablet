#!/usr/bin/env bash
# Remove generated .desktop files whose Exec binary is missing (optional cleanup)
set -euo pipefail
DIR="${1:-}"
[[ -d "$DIR" ]] || exit 0

for f in "$DIR"/ust-*.desktop; do
  [[ -f "$f" ]] || continue
  # Exec=.../ust-launch --class X -- binary
  bin=$(awk -F'-- ' '/^Exec=/{print $2; exit}' "$f" | awk '{print $1}')
  [[ -n "$bin" ]] || continue
  if ! command -v "$bin" >/dev/null 2>&1; then
    # Keep file but mark OnlyShowIn empty? Prefer hide via NoDisplay if missing
    if ! grep -q '^NoDisplay=' "$f"; then
      echo "NoDisplay=true" >>"$f"
      echo "Hidden=true" >>"$f"
    fi
    echo "hide (missing $bin): $(basename "$f")"
  fi
done
