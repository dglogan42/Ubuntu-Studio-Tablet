#!/usr/bin/env bash
# ARM entrypoint: Ubuntu arm64 / postmarketOS / Mobian
# Reuses configs/ + apps/ layer with Plasma Mobile (default) or Plasma Desktop.
#
# Usage:
#   sudo ./scripts/install-arm.sh
#   sudo ./scripts/install-arm.sh --ui plasma-mobile
#   sudo ./scripts/install-arm.sh --ui plasma-desktop
#   sudo ./scripts/install-arm.sh --ui plasma-mobile --with-waydroid
#   sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative
#   sudo ./scripts/install-arm.sh --layer-only
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT/scripts/lib/common.sh"
UST_ROOT="$ROOT"

UI="plasma-mobile"
WITH_WAYDROID=0
WITH_CREATIVE=0
LAYER_ONLY=0
WITH_CHINESE=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ui) UI="${2:-}"; shift 2 ;;
    --with-waydroid) WITH_WAYDROID=1; shift ;;
    --with-creative) WITH_CREATIVE=1; shift ;;
    --layer-only) LAYER_ONLY=1; shift ;;
    --no-chinese) WITH_CHINESE=0; shift ;;
    -h|--help)
      cat <<'EOF'
Usage: sudo ./scripts/install-arm.sh [options]

  --ui plasma-mobile|plasma-desktop   Shell (default: plasma-mobile)
  --with-creative                     Install best-effort creative apps
  --with-waydroid                     Install Waydroid (Android apps)
  --layer-only                        Only configs + launchers + .desktop
  --no-chinese                        Skip Chinese locale/IME setup
  -h, --help                          Show this help

Examples:
  sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative --with-waydroid
  sudo ./scripts/install-arm.sh --layer-only
EOF
      exit 0
      ;;
    *) ust_die "Unknown option: $1" ;;
  esac
done

ust_require_root

ust_log "Ubuntu Studio Tablet — ARM installer"
ust_detect_report
echo "UI=$UI waydroid=$WITH_WAYDROID creative=$WITH_CREATIVE layer_only=$LAYER_ONLY"
echo ""

if ! ust_is_arm; then
  ust_warn "This machine is $(ust_arch), not ARM."
  ust_warn "Continuing anyway (useful for testing scripts in VMs)."
fi

PM="$(ust_pkg_manager)"
DISTRO="$(ust_distro_id)"

if [[ "$LAYER_ONLY" -eq 0 ]]; then
  case "$UI" in
    plasma-mobile|mobile)
      bash "$ROOT/scripts/install-plasma-mobile.sh"
      LAYER_MODE=mobile
      ;;
    plasma-desktop|desktop|tablet)
      case "$PM" in
        apt)
          ust_install_apt_list "$ROOT/packages/tablet-packages.list"
          ;;
        apk)
          ust_install_apk_list "$ROOT/packages/plasma-desktop-apk.list"
          ;;
      esac
      LAYER_MODE=desktop
      ;;
    *)
      ust_die "Unknown --ui $UI (use plasma-mobile or plasma-desktop)"
      ;;
  esac
else
  LAYER_MODE=auto
fi

# Creative stack (best-effort; many Studio apps exist on arm64 Ubuntu)
if [[ "$WITH_CREATIVE" -eq 1 && "$LAYER_ONLY" -eq 0 ]]; then
  ust_log "Installing creative apps (best-effort for ARM)"
  case "$PM" in
    apt) ust_install_apt_list "$ROOT/packages/arm-creative-apt.list" ;;
    apk) ust_install_apk_list "$ROOT/packages/arm-creative-apk.list" ;;
  esac
fi

# Portable layer (configs + apps)
if [[ "$LAYER_MODE" == auto ]]; then
  bash "$ROOT/scripts/install-layer.sh" auto
else
  bash "$ROOT/scripts/install-layer.sh" "$LAYER_MODE"
fi

# Chinese
if [[ "$WITH_CHINESE" -eq 1 && "$LAYER_ONLY" -eq 0 ]]; then
  if [[ "$PM" == apt && -x "$ROOT/scripts/setup-chinese.sh" ]]; then
    bash "$ROOT/scripts/setup-chinese.sh" || ust_warn "Chinese setup had errors"
  elif [[ "$PM" == apk ]]; then
    bash "$ROOT/scripts/setup-chinese-apk.sh" || ust_warn "Chinese apk setup had errors"
  fi
fi

# Waydroid
if [[ "$WITH_WAYDROID" -eq 1 ]]; then
  bash "$ROOT/scripts/install-waydroid.sh" || ust_warn "Waydroid install had errors"
fi

# Device notes
if [[ -f "$ROOT/docs/XIAOXIN.md" ]]; then
  ust_log "Device notes: docs/XIAOXIN.md and docs/ARM.md"
fi

echo ""
ust_log "ARM install finished."
cat <<EOF

Next steps
----------
1. Reboot (recommended on phones/tablets).
2. At login / greetd / SDDM, choose:
     "Ubuntu Studio Tablet (Plasma Mobile)"  or  Plasma Mobile
3. Open ust-* apps from the drawer — fullscreen native style.
4. Optional: sudo $ROOT/scripts/install-waydroid.sh
5. Optional creative: sudo $ROOT/scripts/install-arm.sh --layer-only
   then apt/apk install from packages/arm-creative-*.list

Distro tips ($DISTRO / $PM):
  postmarketOS — UI package was postmarketos-ui-plasma-mobile
  Ubuntu arm64 — uses ports.ubuntu.com; enable universe if needed:
    sudo add-apt-repository universe && sudo apt update
  Xiaoxin Pad — often unlocked bootloader + custom recovery; see docs/ARM.md
EOF
