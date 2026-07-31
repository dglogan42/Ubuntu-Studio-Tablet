#!/usr/bin/env bash
# Shared helpers for Ubuntu Studio Tablet installers
# shellcheck disable=SC2034

UST_ROOT="${UST_ROOT:-}"
if [[ -z "$UST_ROOT" ]]; then
  UST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

ust_log()  { printf '==> %s\n' "$*"; }
ust_warn() { printf 'WARN: %s\n' "$*" >&2; }
ust_die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

ust_require_root() {
  [[ "${EUID:-}" -eq 0 ]] || ust_die "Run as root: sudo $0"
}

ust_arch() {
  uname -m
}

ust_is_arm() {
  case "$(ust_arch)" in
    aarch64|arm64|armv7l|armv8l) return 0 ;;
    *) return 1 ;;
  esac
}

ust_is_amd64() {
  case "$(ust_arch)" in
    x86_64|amd64) return 0 ;;
    *) return 1 ;;
  esac
}

# Returns: ubuntu|debian|postmarketos|alpine|unknown
ust_distro_id() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    case "${ID:-}" in
      ubuntu) echo ubuntu; return ;;
      debian) echo debian; return ;;
      postmarketos) echo postmarketos; return ;;
      alpine) echo alpine; return ;;
    esac
    case "${ID_LIKE:-}" in
      *ubuntu*) echo ubuntu; return ;;
      *debian*) echo debian; return ;;
      *alpine*) echo alpine; return ;;
    esac
    echo "${ID:-unknown}"
    return
  fi
  echo unknown
}

# Returns: apt|apk|unknown
ust_pkg_manager() {
  if command -v apk >/dev/null 2>&1 && [[ -f /etc/apk/repositories ]]; then
    echo apk
  elif command -v apt-get >/dev/null 2>&1; then
    echo apt
  else
    echo unknown
  fi
}

# Returns: plasma-mobile|plasma-desktop|none
ust_plasma_variant() {
  if command -v startplasmamobile >/dev/null 2>&1 \
    || command -v plasma-mobile >/dev/null 2>&1 \
    || [[ -f /usr/share/wayland-sessions/plasma-mobile.desktop ]] \
    || [[ -f /usr/share/wayland-sessions/plasmashell-mobile.desktop ]]; then
    echo plasma-mobile
    return
  fi
  if command -v startplasma-wayland >/dev/null 2>&1 \
    || [[ -f /usr/share/wayland-sessions/plasma.desktop ]] \
    || [[ -f /usr/share/wayland-sessions/plasmawayland.desktop ]]; then
    echo plasma-desktop
    return
  fi
  # package names present but not installed yet
  if [[ "$(ust_pkg_manager)" == apt ]] && apt-cache show plasma-mobile >/dev/null 2>&1; then
    echo plasma-mobile-available
    return
  fi
  if [[ "$(ust_pkg_manager)" == apk ]] && apk search -q plasma-mobile 2>/dev/null | grep -q .; then
    echo plasma-mobile-available
    return
  fi
  echo none
}

ust_install_apt_list() {
  local list_file="$1"
  [[ -f "$list_file" ]] || return 0
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y || true
  local p
  while read -r p; do
    [[ -z "$p" || "$p" =~ ^# ]] && continue
    if apt-cache show "$p" >/dev/null 2>&1; then
      apt-get install -y "$p" || ust_warn "apt failed: $p"
    else
      ust_warn "SKIP (not in apt): $p"
    fi
  done <"$list_file"
}

ust_install_apk_list() {
  local list_file="$1"
  [[ -f "$list_file" ]] || return 0
  apk update || true
  local p
  while read -r p; do
    [[ -z "$p" || "$p" =~ ^# ]] && continue
    if apk search -q -e "$p" 2>/dev/null | grep -qx "$p" \
      || apk info -e "$p" >/dev/null 2>&1; then
      apk add "$p" || ust_warn "apk failed: $p"
    else
      # try without exact match
      apk add "$p" 2>/dev/null || ust_warn "SKIP (not in apk): $p"
    fi
  done <"$list_file"
}

ust_detect_report() {
  cat <<EOF
Architecture : $(ust_arch)
Distro       : $(ust_distro_id)
Pkg manager  : $(ust_pkg_manager)
Plasma       : $(ust_plasma_variant)
ARM device   : $(ust_is_arm && echo yes || echo no)
EOF
}
