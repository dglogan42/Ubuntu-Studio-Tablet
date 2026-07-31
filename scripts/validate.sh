#!/usr/bin/env bash
# Sanity-check the Ubuntu Studio Tablet project tree
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERR=0

ok() { echo "  OK  $1"; }
bad() { echo " FAIL $1"; ERR=1; }

echo "Validating $ROOT"

[[ -f "$ROOT/README.md" ]] && ok README || bad README
[[ -f "$ROOT/scripts/lib/common.sh" ]] && ok common-lib || bad common-lib
[[ -f "$ROOT/scripts/ust-launch" ]] && ok ust-launch || bad ust-launch
[[ -f "$ROOT/scripts/install-tablet-mode.sh" ]] && ok install-desktop || bad install-desktop
[[ -f "$ROOT/scripts/install-arm.sh" ]] && ok install-arm || bad install-arm
[[ -f "$ROOT/scripts/install-layer.sh" ]] && ok install-layer || bad install-layer
[[ -f "$ROOT/scripts/install-plasma-mobile.sh" ]] && ok install-pm || bad install-pm
[[ -f "$ROOT/scripts/install-waydroid.sh" ]] && ok install-waydroid || bad install-waydroid
[[ -f "$ROOT/scripts/ust-start-plasma-mobile" ]] && ok pm-session || bad pm-session
[[ -f "$ROOT/packages/tablet-packages.list" ]] && ok packages-desktop || bad packages-desktop
[[ -f "$ROOT/packages/plasma-mobile-apt.list" ]] && ok packages-pm-apt || bad packages-pm-apt
[[ -f "$ROOT/packages/plasma-mobile-apk.list" ]] && ok packages-pm-apk || bad packages-pm-apk
[[ -f "$ROOT/configs/plasma/kwinrulesrc" ]] && ok kwin-rules || bad kwin-rules
[[ -f "$ROOT/configs/plasma-mobile/kwinrc" ]] && ok pm-kwin || bad pm-kwin
[[ -f "$ROOT/docs/XIAOXIN.md" ]] && ok xiaoxin-docs || bad xiaoxin-docs
[[ -f "$ROOT/docs/XIAOXIN-LAPTOP.md" ]] && ok xiaoxin-laptop-docs || bad xiaoxin-laptop-docs
[[ -f "$ROOT/docs/ARM.md" ]] && ok arm-docs || bad arm-docs
[[ -f "$ROOT/docs/ARM-PORT.md" ]] && ok arm-port-docs || bad arm-port-docs
[[ -f "$ROOT/docs/WAYDROID.md" ]] && ok waydroid-docs || bad waydroid-docs
[[ -f "$ROOT/docs/PLASMA-MOBILE.md" ]] && ok pm-docs || bad pm-docs
[[ -f "$ROOT/data/device-matrix.tsv" ]] && ok device-matrix || bad device-matrix
[[ -f "$ROOT/scripts/check-device-support.sh" ]] && ok device-check || bad device-check
[[ -f "$ROOT/scripts/pmbootstrap-hints.sh" ]] && ok pmbootstrap-hints || bad pmbootstrap-hints
[[ -f "$ROOT/scripts/android-linux-bridge.sh" ]] && ok android-bridge || bad android-bridge

# Generate desktops into apps/desktop
bash "$ROOT/scripts/generate-app-desktops.sh" "$ROOT/apps/desktop" >/dev/null
count=$(find "$ROOT/apps/desktop" -name 'ust-*.desktop' | wc -l)
[[ "$count" -ge 20 ]] && ok "desktop entries ($count)" || bad "desktop entries ($count)"

# Shell syntax
for s in "$ROOT"/scripts/*.sh "$ROOT"/scripts/ust-* "$ROOT"/scripts/lib/*.sh; do
  [[ -f "$s" ]] || continue
  bash -n "$s" && ok "syntax $(basename "$s")" || bad "syntax $(basename "$s")"
done

# chmod
chmod +x "$ROOT"/scripts/*.sh "$ROOT"/scripts/ust-* 2>/dev/null || true

# detect-platform runs without root
if bash "$ROOT/scripts/detect-platform.sh" >/tmp/ust-detect.out 2>&1; then
  ok "detect-platform"
  head -5 /tmp/ust-detect.out | sed 's/^/       /'
else
  bad "detect-platform"
fi

if [[ $ERR -eq 0 ]]; then
  echo "All checks passed."
else
  echo "Some checks failed."
  exit 1
fi
