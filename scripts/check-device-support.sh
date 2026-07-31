#!/usr/bin/env bash
# Check whether this Xiaoxin / Lenovo tablet has a known ARM Linux port path.
# Uses adb (optional) + data/device-matrix.tsv
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MATRIX="$ROOT/data/device-matrix.tsv"
CODENAME=""
MODEL=""
PLATFORM=""
FROM_ADB=0

usage() {
  cat <<EOF
Usage: $0 [--codename NAME] [--model "string"] [--adb]

  --codename   postmarketOS-style codename (e.g. lenovo-j716f)
  --model      marketing / Android model string
  --adb        read props from connected Android device
  -h, --help   this help

Exit codes:
  0  known path (testing/community/mainline-ish)
  2  archived / risky
  3  unsupported / unknown
  1  usage error
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --codename) CODENAME="${2:-}"; shift 2 ;;
    --model) MODEL="${2:-}"; shift 2 ;;
    --adb) FROM_ADB=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ ! -f "$MATRIX" ]]; then
  echo "Missing matrix: $MATRIX" >&2
  exit 1
fi

if [[ "$FROM_ADB" -eq 1 ]]; then
  if ! command -v adb >/dev/null 2>&1; then
    echo "adb not found. Install android-tools-adb / platform-tools." >&2
    exit 1
  fi
  adb start-server >/dev/null 2>&1 || true
  if ! adb get-state 2>/dev/null | grep -q device; then
    echo "No adb device in 'device' state. Enable USB debugging and authorize PC." >&2
    exit 1
  fi
  CODENAME_RAW=$(adb shell getprop ro.product.device 2>/dev/null | tr -d '\r')
  MODEL=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
  NAME=$(adb shell getprop ro.product.name 2>/dev/null | tr -d '\r')
  PLATFORM=$(adb shell getprop ro.board.platform 2>/dev/null | tr -d '\r')
  HARDWARE=$(adb shell getprop ro.hardware 2>/dev/null | tr -d '\r')
  MANU=$(adb shell getprop ro.product.manufacturer 2>/dev/null | tr -d '\r')
  echo "=== adb device ==="
  echo "manufacturer : $MANU"
  echo "model        : $MODEL"
  echo "name         : $NAME"
  echo "device       : $CODENAME_RAW"
  echo "platform     : $PLATFORM"
  echo "hardware     : $HARDWARE"
  echo ""
  # Normalize toward pmOS-style codenames when possible
  if [[ -z "$CODENAME" ]]; then
    low=$(echo "$CODENAME_RAW" | tr '[:upper:]' '[:lower:]')
    case "$low" in
      j716f|tb-j716f|tb_j716f) CODENAME=lenovo-j716f ;;
      q706f|tb-q706f) CODENAME=lenovo-q706f ;;
      tb128fu|tb-128fu) CODENAME=lenovo-tb128fu ;;
      x306f|tb-x306f|tb_x306f|amar_row_wifi|amar-row-wifi) CODENAME=lenovo-amar-row-wifi ;;
      x306x|tb-x306x|tb_x306x|amar_row_lte|amar-row-lte) CODENAME=lenovo-amar-row-lte ;;
      *)
        if [[ "$low" == lenovo-* ]]; then
          CODENAME="$low"
        else
          CODENAME="lenovo-${low}"
        fi
        ;;
    esac
  fi
fi

lookup() {
  local key="$1"
  awk -F'\t' -v k="$key" '
    /^#/ || NF < 6 { next }
    $1 == k {
      print $0
      found=1
      exit
    }
    END { if (!found) exit 1 }
  ' "$MATRIX"
}

echo "=== Studio Tablet — ARM port check ==="
echo "Matrix: $MATRIX"
echo ""

MATCH=""
STATUS=""
if [[ -n "$CODENAME" ]] && MATCH=$(lookup "$CODENAME" 2>/dev/null); then
  :
elif [[ -n "$MODEL" ]]; then
  # fuzzy marketing name
  MATCH=$(awk -F'\t' -v m="$(echo "$MODEL" | tr '[:upper:]' '[:lower:]')" '
    /^#/ || NF < 6 { next }
    {
      names=tolower($2)
      if (index(names, m) || index(m, tolower($1))) { print; exit }
    }
  ' "$MATRIX" || true)
fi

# SoC family heuristic if still empty
if [[ -z "${MATCH:-}" && -n "$PLATFORM" ]]; then
  pl=$(echo "$PLATFORM" | tr '[:upper:]' '[:lower:]')
  case "$pl" in
    *sm8250*|*kona*|*lito*)
      echo "SoC heuristic: Snapdragon 870-class platform ($PLATFORM)"
      MATCH=$(lookup "generic-sd870" || true)
      ;;
    *mt6897*|*mt6989*|*dimensity*)
      echo "SoC heuristic: recent Dimensity ($PLATFORM)"
      MATCH=$(lookup "generic-dimensity-8300" || true)
      ;;
    *kalama*|*sm8550*|*sm8650*)
      echo "SoC heuristic: Snapdragon 8 Gen class ($PLATFORM)"
      MATCH=$(lookup "generic-sd8gen3" || true)
      ;;
  esac
fi

if [[ -z "${MATCH:-}" ]]; then
  echo "Result: UNKNOWN / not in matrix"
  echo ""
  echo "This does NOT mean Linux is impossible — only that we have no"
  echo "recorded postmarketOS/mainline path for this id."
  echo ""
  echo "Next:"
  echo "  1. Search https://wiki.postmarketos.org/wiki/Devices for your model"
  echo "  2. Read docs/ARM-PORT.md  (Path C remote / proot, Path D other hardware)"
  echo "  3. Re-run with: $0 --codename <vendor-device>"
  echo ""
  echo "Do NOT run install-arm.sh until a Linux userspace boots with display+touch."
  exit 3
fi

# Parse match fields
codename=$(echo "$MATCH" | cut -f1)
names=$(echo "$MATCH" | cut -f2)
soc=$(echo "$MATCH" | cut -f3)
arch=$(echo "$MATCH" | cut -f4)
STATUS=$(echo "$MATCH" | cut -f5)
notes=$(echo "$MATCH" | cut -f6)
wiki=$(echo "$MATCH" | cut -f7)

echo "codename     : $codename"
echo "names        : $names"
echo "SoC          : $soc"
echo "arch         : $arch"
echo "port status  : $STATUS"
echo "notes        : $notes"
if [[ -n "$wiki" && "$wiki" != "-" ]]; then
  if [[ "$wiki" == https://* || "$wiki" == http://* ]]; then
    echo "device page  : $wiki"
  else
    echo "wiki         : https://wiki.postmarketos.org/wiki/$wiki"
  fi
fi
echo ""

case "$STATUS" in
  ubuntu_touch)
    echo "Result: UBUNTU TOUCH path (Halium / UBports — not Plasma Studio layer)"
    echo ""
    echo "Recommended:"
    echo "  1. Confirm exact model on the device page above"
    echo "  2. Stock firmware requirements (often Android 11) — read device page"
    echo "  3. Install via UBports Installer:"
    echo "       https://devices.ubuntu-touch.io/installer/"
    echo "  4. Dual-boot is NOT supported"
    echo ""
    echo "Guide: docs/UBUNTU-TOUCH.md"
    echo "Note: install-arm.sh targets Plasma Mobile, not Lomiri/Ubuntu Touch."
    exit 0
    ;;
  community|community_mainline|testing|testing_unmerged)
    echo "Result: POSSIBLE native ARM Linux path"
    echo ""
    echo "Recommended:"
    echo "  ./scripts/pmbootstrap-hints.sh $codename"
    echo "  # follow device wiki for unlock + flash (NOT automated here)"
    echo "  # after Plasma Mobile boots:"
    echo "  sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative --with-waydroid"
    echo ""
    echo "Full guide: docs/ARM-PORT.md  (Path A)"
    exit 0
    ;;
  archived)
    echo "Result: ARCHIVED / RISKY"
    echo "  Historical port; often broken. Experts only."
    echo "  Prefer Path C (remote Studio) or Path D unless you fix the port."
    echo "  docs/ARM-PORT.md"
    exit 2
    ;;
  unsupported|*)
    echo "Result: NO READY PORT in our matrix"
    echo ""
    echo "Recommended fallbacks:"
    echo "  ./scripts/android-linux-bridge.sh --print-all"
    echo "  docs/ARM-PORT.md  (Path C remote/proot, Path D other hardware)"
    echo "  docs/UBUNTU-TOUCH.md  (if listed on devices.ubuntu-touch.io)"
    echo ""
    echo "install-arm.sh will not help until Linux boots natively."
    exit 3
    ;;
esac
