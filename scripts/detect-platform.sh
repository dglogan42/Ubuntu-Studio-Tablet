#!/usr/bin/env bash
# Print platform facts for Ubuntu Studio Tablet install decisions
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT/scripts/lib/common.sh"
UST_ROOT="$ROOT"
ust_detect_report

# Suggested install profile
DISTRO="$(ust_distro_id)"
PM="$(ust_pkg_manager)"
ARCH="$(ust_arch)"

echo ""
echo "Suggested profile:"
if ust_is_arm; then
  if [[ "$DISTRO" == postmarketos || "$DISTRO" == alpine ]]; then
    echo "  arm-postmarketos-plasma-mobile"
    echo "  → sudo ./scripts/install-arm.sh --ui plasma-mobile"
  elif [[ "$PM" == apt ]]; then
    echo "  arm-ubuntu-plasma-mobile"
    echo "  → sudo ./scripts/install-arm.sh --ui plasma-mobile"
  else
    echo "  arm-generic (layer-only)"
    echo "  → sudo ./scripts/install-layer.sh"
  fi
else
  echo "  amd64-studio-tablet (Plasma Desktop tablet mode)"
  echo "  → sudo ./scripts/install-tablet-mode.sh"
fi
