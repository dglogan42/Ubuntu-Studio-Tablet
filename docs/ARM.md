# ARM Linux base — Ubuntu Studio Tablet layer

This project’s **configs/** and **apps/** layers are architecture-independent.  
On **ARM64** tablets (e.g. most Lenovo Xiaoxin Pad Pro), you do **not** use the AMD64 Studio ISO.  

## Prerequisite: a working ARM Linux port

`install-arm.sh` assumes the tablet **already boots** a Linux userspace with display + touch  
(postmarketOS, Ubuntu arm64, Mobian, …). This repo does **not** unlock bootloaders or ship kernels.

| Step | Doc / tool |
|------|------------|
| 1. Identify device + port status | `./scripts/check-device-support.sh --adb` |
| 2. Get Linux booting | **[ARM-PORT.md](ARM-PORT.md)** (pmOS / fallbacks) |
| 3. Apply Studio Tablet layer | commands below |

If `check-device-support.sh` reports **unsupported**, use remote Studio or proot — see ARM-PORT Path C.

---

Once Linux is up, run:

```bash
sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative --with-waydroid
```

---

## Supported bases

| Base | Arch | UI | Installer path |
|------|------|-----|----------------|
| **Ubuntu 24.04+ / 26.04 arm64** | aarch64 | Plasma Mobile or Plasma Desktop | `install-arm.sh` (apt) |
| **postmarketOS** | aarch64 | Plasma Mobile (`postmarketos-ui-plasma-mobile`) | `install-arm.sh` (apk) |
| **Mobian (Debian)** | aarch64 | Plasma Mobile | `install-arm.sh` (apt) |
| **Generic Plasma 6** | any | already installed | `install-layer.sh` only |

---

## Path A — Ubuntu arm64 + Plasma Mobile (recommended when ports work)

### 1. Get Ubuntu on the device

Options depend on the tablet:

- **Mainline / community images** for your SoC (search postmarketOS/device wiki first — often more realistic than stock Ubuntu).
- **Ubuntu Server arm64** on supported UEFI ARM boards, then install Plasma Mobile.
- **chroot / proot** experimental only — not for daily driver.

Enable universe and update:

```bash
sudo add-apt-repository universe   # if needed
sudo apt update
```

### 2. Install Studio Tablet (ARM)

```bash
git clone <this-repo> ubuntu-studio-tablet   # or copy from USB
cd ubuntu-studio-tablet
./scripts/detect-platform.sh
sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative
sudo ./scripts/setup-chinese.sh
```

With Android apps:

```bash
sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative --with-waydroid
```

### 3. Login

Choose session **Ubuntu Studio Tablet (Plasma Mobile)** or **Plasma Mobile**.

---

## Path B — postmarketOS + Plasma Mobile (best for phones/tablets with community ports)

### 1. Check device support

- https://wiki.postmarketos.org/wiki/Devices  
- Xiaoxin / Lenovo tablets are **often unsupported or testing** — verify before unlocking.

### 2. Install postmarketOS

- Prebuilt: https://postmarketos.org/install/  
- Or `pmbootstrap` → UI: **plasma-mobile**

Default user/password are documented on the install page (historically `user` / `147147` — confirm for your release).

### 3. Apply Studio Tablet layer

```bash
# on the device (or after scp)
cd ubuntu-studio-tablet
sudo ./scripts/install-arm.sh --ui plasma-mobile --with-waydroid
# Chinese fonts/IME:
sudo ./scripts/setup-chinese-apk.sh
```

Creative apps on Alpine are fewer; use `--with-creative` for best-effort, or install Flatpaks where available.

---

## What gets reused from this repo

| Asset | Role on ARM |
|-------|-------------|
| `configs/plasma/kwinrulesrc` | Fullscreen Studio apps |
| `configs/plasma-mobile/*` | Mobile shell tweaks |
| `apps/desktop/ust-*.desktop` | Native app-style launchers |
| `scripts/ust-launch` | Env + maximize helpers |
| `scripts/ust-start-plasma-mobile` | Session wrapper |
| `branding/` | Wallpaper |
| `apps/home-grid.html` | UX preview (browser) |

---

## Plasma Mobile vs Plasma Desktop on a tablet

| | Plasma Mobile | Plasma Desktop (tablet mode) |
|--|---------------|------------------------------|
| Home | App drawer / pages | Desktop + dashboard |
| Apps | Designed fullscreen | Forced maximize via KWin |
| Phone features | Dialer, SMS (if modem) | Not primary |
| Large tablets (11–13") | Excellent | Also good if you want panels |
| Flag | `--ui plasma-mobile` | `--ui plasma-desktop` |

For **Xiaoxin-class tablets**, start with **Plasma Mobile**.

---

## Flatpak for missing arm64 debs

```bash
sudo apt install flatpak   # or apk add flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.kde.krita
flatpak install flathub org.audacityteam.Audacity
# Then either use Flatpak menu entries or wrap with ust-launch
```

---

## Hardware expectations (Xiaoxin / Chinese tablets)

1. **Bootloader unlock** often voids warranty; may wipe device.  
2. **GPU / display** may need device-specific kernel (not generic Ubuntu).  
3. **Touch + rotation** need `iio-sensor-proxy` + working panel drivers.  
4. **Audio low-latency** for DAW work is harder on mobile SoCs — USB interface helps.  
5. If mainline Linux is incomplete, prefer **Android + remote Studio** (see XIAOXIN.md).

---

## Quick commands

```bash
./scripts/detect-platform.sh                 # what am I?
sudo ./scripts/install-arm.sh --help
sudo ./scripts/install-layer.sh mobile       # configs/apps only
sudo ./scripts/install-plasma-mobile.sh      # shell packages only
sudo ./scripts/install-waydroid.sh           # Android apps
```
