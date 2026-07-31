#!/usr/bin/env bash
# Chinese fonts + fcitx5 on postmarketOS / Alpine (apk)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT/scripts/lib/common.sh"
UST_ROOT="$ROOT"
ust_require_root

ust_log "Chinese setup (apk)"

apk update || true
# Package names vary by Alpine branch — best-effort
for p in \
  font-noto-cjk \
  font-wqy-zenhei \
  fcitx5 \
  fcitx5-chinese-addons \
  fcitx5-qt \
  fcitx5-gtk \
  lang \
  musl-locales
do
  apk add "$p" 2>/dev/null || ust_warn "skip $p"
done

mkdir -p /etc/profile.d
cat >/etc/profile.d/ust-im.sh <<'EOF'
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx5
EOF

# skel fcitx profile
SKEL_FCITX="/etc/skel/.config/fcitx5"
mkdir -p "$SKEL_FCITX"
cat >"$SKEL_FCITX/profile" <<'EOF'
[Groups/0]
Name=默认
Default Layout=us
DefaultIM=pinyin

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=pinyin
Layout=

[GroupOrder]
0=默认
EOF

# Locale hint (Alpine often needs musl-locales / openrc env)
if [[ -f /etc/profile.d/locale.sh ]]; then
  :
fi
echo "export LANG=zh_CN.UTF-8" >/etc/profile.d/ust-locale.sh 2>/dev/null || true

ust_log "Chinese apk setup done. Re-login for IME env."
