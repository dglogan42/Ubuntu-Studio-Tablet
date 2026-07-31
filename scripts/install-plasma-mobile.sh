#!/usr/bin/env bash
# Install Plasma Mobile shell packages (Ubuntu/Debian apt or postmarketOS apk)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT/scripts/lib/common.sh"
UST_ROOT="$ROOT"
ust_require_root

ust_log "Installing Plasma Mobile shell"
ust_detect_report
echo ""

PM="$(ust_pkg_manager)"
case "$PM" in
  apt)
    ust_install_apt_list "$ROOT/packages/plasma-mobile-apt.list"
    # Ensure session binary exists
    if ! command -v startplasmamobile >/dev/null 2>&1; then
      # Some releases use different entry points
      if [[ -x /usr/bin/plasma-mobile ]]; then
        ust_log "plasma-mobile binary present"
      else
        ust_warn "startplasmamobile not found — check plasma-mobile package"
      fi
    fi
    ;;
  apk)
    ust_install_apk_list "$ROOT/packages/plasma-mobile-apk.list"
    ;;
  *)
    ust_die "Unsupported package manager for Plasma Mobile install"
    ;;
esac

ust_log "Plasma Mobile packages step done."
echo "    Next: sudo $ROOT/scripts/install-layer.sh mobile"
echo "    Then: sudo $ROOT/scripts/setup-chinese.sh   # if apt/zh_CN"
