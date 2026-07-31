#!/bin/bash
# Optional live-build / cubic hook — run inside chroot
set -euo pipefail
if [[ -d /opt/ubuntu-studio-tablet ]]; then
  bash /opt/ubuntu-studio-tablet/scripts/install-tablet-mode.sh
  bash /opt/ubuntu-studio-tablet/scripts/setup-chinese.sh || true
fi
