# Linux on Android tablets — what actually works

**Running a full desktop OS like Ubuntu Studio directly on an Android tablet is not natively supported.**

Ubuntu Studio 26.04 ships as an **amd64** desktop image. Most Chinese Android tablets (Xiaoxin Pad, MediaTek / Qualcomm) are **ARM64** and boot **Android**. This project is a **Plasma configuration layer** for a machine that already runs Linux — it does **not** replace Android by itself, unlock bootloaders, or ship device kernels.

Use one of the paths below depending on how deep you want to go.

---

## At a glance

| Approach | Replaces Android? | Full desktop DE? | Fits this repo? |
|----------|-------------------|------------------|-----------------|
| **Ubuntu Studio ISO (amd64)** | N/A — PC/laptop only | Yes | **Primary** — `install-tablet-mode.sh` |
| **Ubuntu Touch** | Yes (supported devices only) | Mobile shell, not Studio desktop | Port first → maybe layer later |
| **postmarketOS** | Yes (if device port exists) | Plasma Mobile possible | **ARM path** — then `install-arm.sh` |
| **Andronix** | No — runs on Android | XFCE / LXQt via proot | CLI/GUI experiments only |
| **Termux** | No | CLI (+ optional Termux:X11) | Scripts / remote helper only |
| **Remote into AMD64 Studio** | No | Full Studio on the PC | **Recommended creative path** |

---

## Mobile Linux operating systems (replace Android)

These install a real Linux userspace as the device OS. You need **device support** (kernel, display, touch, modem optional). This repo never flashes firmware.

> **“Sideload via kernel”** here means: unlock bootloader (device-specific), flash a **Linux kernel + initramfs + rootfs** (fastboot / recovery / `pmbootstrap flasher`), not “copy Ubuntu Studio.iso onto internal storage.”  
> Wrong codename or stock firmware = soft-brick risk. Always keep a stock ROM package.

### Download & install links (official)

| Project | What you download | Official links |
|---------|-------------------|----------------|
| **Ubuntu Studio (PC/laptop)** | Live **ISO** (amd64) | [26.04 Resolute release](https://cdimage.ubuntu.com/ubuntustudio/releases/resolute/release/) · [all Studio images](https://cdimage.ubuntu.com/ubuntustudio/) |
| **Ubuntu Touch** | **UBports Installer** (pulls recovery + system + device kernel for you) | Homepage: [ubuntu-touch.io](https://www.ubuntu-touch.io/) · [Get Ubuntu Touch / devices](https://devices.ubuntu-touch.io/) · [Installer hub](https://devices.ubuntu-touch.io/installer/) · [GitHub releases](https://github.com/ubports/ubports-installer/releases/latest) · [Snap](https://snapcraft.io/ubports-installer) · [Apps](https://www.ubuntu-touch.io/apps) |
| **postmarketOS** | Prebuilt **device images** *or* build/flash with **pmbootstrap** | [Download guide](https://postmarketos.org/download/) · [Image mirror](https://images.postmarketos.org/) · [Devices wiki](https://wiki.postmarketos.org/wiki/Devices) · [pmbootstrap](https://wiki.postmarketos.org/wiki/Pmbootstrap) · [Installation](https://wiki.postmarketos.org/wiki/Installation_guide) |
| **Ubuntu arm64 (generic)** | Server/cloud **ISO / img** (only if hardware is mainline/UEFI) | [Ubuntu arm64 downloads](https://ubuntu.com/download/server/arm) · [cdimage arm64](https://cdimage.ubuntu.com/releases/) |
| **Mobian** (Debian mobile) | Device images (PinePhone / Librem / limited set) | [mobian.org downloads](https://images.mobian.org/) · [wiki](https://wiki.mobian.org/) |

Installer packages for **Ubuntu Touch** (PC host, then flash the phone/tablet over USB):

| Host OS | Package link |
|---------|----------------|
| **Linux (AppImage)** | [devices.ubuntu-touch.io/installer?package=appimage](https://devices.ubuntu-touch.io/installer?package=appimage) |
| **Debian/Ubuntu (.deb)** | [installer?package=deb](https://devices.ubuntu-touch.io/installer?package=deb) |
| **Snap** | `snap install ubports-installer` → [snapcraft.io/ubports-installer](https://snapcraft.io/ubports-installer) |
| **macOS (.dmg)** | [installer?package=dmg](https://devices.ubuntu-touch.io/installer?package=dmg) |
| **Windows (.exe)** | [installer?package=exe](https://devices.ubuntu-touch.io/installer?package=exe) |
| **All releases** | [github.com/ubports/ubports-installer/releases/latest](https://github.com/ubports/ubports-installer/releases/latest) |

**postmarketOS** image channels (pick **your device folder** under the release, then UI e.g. `plasma-mobile`):

| Channel | URL |
|---------|-----|
| **Latest stable-ish / current** | [images.postmarketos.org/v26.06/](https://images.postmarketos.org/v26.06/) |
| Previous | [images.postmarketos.org/v25.12/](https://images.postmarketos.org/v25.12/) |
| Rolling **edge** | [images.postmarketos.org/edge/](https://images.postmarketos.org/edge/) |
| How to flash | [postmarketos.org/download/](https://postmarketos.org/download/) |

If no prebuilt image exists for your codename, **build + flash kernel/rootfs** on a Linux PC:

```bash
pipx install pmbootstrap   # or distro package
pmbootstrap init           # vendor + device + UI: plasma-mobile
pmbootstrap install
# Device wiki then typically:
#   pmbootstrap flasher flash_rootfs
#   pmbootstrap flasher flash_kernel
```

Repo helper (prints matrix hints only — does **not** flash):

```bash
./scripts/pmbootstrap-hints.sh <codename>   # e.g. lenovo-j716f
./scripts/check-device-support.sh --adb
```

### Ubuntu Touch

Official site: **[https://www.ubuntu-touch.io/](https://www.ubuntu-touch.io/)**  
Libre mobile OS (**Lomiri**), originally Canonical, now **UBports** volunteers. Replaces Android on **supported** devices only. Full pre-install guide in this repo: **[UBUNTU-TOUCH.md](UBUNTU-TOUCH.md)**.

| Step | Link |
|------|------|
| Homepage | [www.ubuntu-touch.io](https://www.ubuntu-touch.io/) |
| **Get Ubuntu Touch** / devices | [devices.ubuntu-touch.io](https://devices.ubuntu-touch.io/) |
| Installer | [devices.ubuntu-touch.io/installer](https://devices.ubuntu-touch.io/installer/) |
| Apps | [ubuntu-touch.io/apps](https://www.ubuntu-touch.io/apps) |
| FAQ (read first) | [ubports.com FAQ](https://ubports.com/community/faq) |
| Install docs | [docs.ubports.com](https://docs.ubports.com/en/latest/userguide/install.html) |
| Lomiri on PC | [lomiri.com](https://lomiri.com/) |
| Source | [gitlab.com/ubports](https://gitlab.com/ubports/) |

#### Before installation (UBports)

- Mostly stable, **still missing features** — read the FAQ first.  
- Stick to guidelines; prefer **recently updated** devices.  
- Confirm the phone/tablet is **fully functional** before flashing.  
- **VoLTE / calls** may be problematic (noted for **North America** on some devices).  
- **Dual booting is not supported.**  
- Prefer the **UBports Installer**; **avoid manual install** unless you know what you are doing.  
- **Not on the device list (any filter)?** → unsupported; porting requires you / community (docs on GitLab).  
- Risk is yours (best-effort volunteer software).

#### Ways to get it

| Option | Notes |
|--------|--------|
| **Preinstalled** | Volla, Pine64, FXP and other commercial offerings |
| **Installer** | Switch from Android on [listed devices](https://devices.ubuntu-touch.io/) |
| **Native image** | PinePhone / PineTab: image on device, boots directly |
| **Manual** | Discouraged; for unfinished ports only |
| **Virtual / Lomiri desktop** | Dev kit or Lomiri on PC if you lack hardware |

Commercial example: **Volla Phone** · Community example: **Fairphone 5** (see live devices page).

**Tablet pick with Installer + Fully Optimized support:**  
**[Lenovo Tab M10 HD 2nd Gen Wi‑Fi (X306F)](https://devices.ubuntu-touch.io/device/amar-row-wifi/)** — Halium 11.0, codename **`amar_row_wifi`**, ~$140, focal + noble, Waydroid/Wi‑Fi/cameras reported working. Requires **Android 11 stock** before flash. Full notes: [UBUNTU-TOUCH.md § M10 HD](UBUNTU-TOUCH.md#featured-tablet-lenovo-tab-m10-hd-2nd-gen-wi-fi).

Installer flashes **recovery + kernel + system** over USB. Mature ports use the installer; early ports may need painful manual steps.

**Not** Ubuntu Studio. After Touch boots, this repo’s Plasma scripts do **not** apply directly — see [UBUNTU-TOUCH.md](UBUNTU-TOUCH.md).

### postmarketOS

A lightweight, touch-oriented system based on **Alpine Linux**, designed for mobile devices.

1. Confirm your model: [Devices wiki](https://wiki.postmarketos.org/wiki/Devices)  
2. Prefer a prebuilt image under [images.postmarketos.org](https://images.postmarketos.org/) with **plasma-mobile** (or build via pmbootstrap)  
3. Flash per device wiki (**kernel** + rootfs via `fastboot` / SD / `pmbootstrap flasher`)  
4. Once Plasma boots, layer this repo:

```bash
sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative --with-waydroid
```

See **[ARM-PORT.md](ARM-PORT.md)** and **[PLASMA-MOBILE.md](PLASMA-MOBILE.md)**.

### Other ARM bases

| Base | Download / notes |
|------|------------------|
| **Mobian** | [images.mobian.org](https://images.mobian.org/) — Debian mobile; limited device list |
| **Ubuntu Server arm64** | [ubuntu.com/download/server/arm](https://ubuntu.com/download/server/arm) — only if board/tablet is mainline UEFI; **not** for locked Xiaoxin pads |
| **Droidian** | [droidian.org](https://droidian.org/) — Halium-based; device-specific images |

Same rule: **working Linux first**, then UST layer (`install-arm.sh` / `install-layer.sh`).

---

## Running Linux *inside* Android (Android stays)

No bootloader unlock required for the common options. You do **not** get a native KMS/DRM Plasma session or low-latency Ubuntu Studio DAW stack.

### Andronix

An app that installs full Linux **desktop environments** (e.g. **XFCE**, **LXQt**) on top of your existing Android system, typically via **Termux** + proot-style containers.

| Good for | Weak for |
|----------|----------|
| Trying Ubuntu/Debian GUI apps without wiping Android | Real-time audio, GPU-heavy video, “native tablet OS” feel |
| Learning Linux packages on a pad | Running `install-tablet-mode.sh` as the device shell |

Treat Andronix as a **sandbox**, not a substitute for amd64 Studio hardware.

### Termux

A powerful Android **terminal emulator** that provides a Linux command-line environment and packages **directly on the tablet** (no root for basic use; prefer F-Droid builds).

Typical flow:

```text
Install Termux → pkg update → proot-distro install ubuntu → proot-distro login ubuntu
```

Optional: **Termux:X11** for a nested GUI.

| Good for | Weak for |
|----------|----------|
| CLI tools, scripts, SSH, light packages | Plasma Mobile as the real home screen |
| Bridge workflows (`android-linux-bridge.sh`) | Hardware RT audio / full Studio session |

Print the built-in bridge guide from this repo:

```bash
./scripts/android-linux-bridge.sh --termux
./scripts/android-linux-bridge.sh --print-all
```

### Root / chroot (Linux Deploy, etc.)

Still shares the **Android kernel**. Higher risk (unlock/root), often janky for full desktop shells. Prefer remote Studio or a real port when possible. See Path C3 in `android-linux-bridge.sh`.

---

## Recommended creative workflows

### 1. AMD64 laptop / mini-PC (best)

1. Install **Ubuntu Studio 26.04** from the official ISO.  
2. `sudo ./scripts/install-tablet-mode.sh`  
3. Optional: `sudo ./scripts/setup-chinese.sh`  

Xiaoxin **laptop** dual-boot: **[XIAOXIN-LAPTOP.md](XIAOXIN-LAPTOP.md)**.

### 2. Keep Android tablet + remote Studio host

- PC: Ubuntu Studio + Sunshine / RDP / similar  
- Tablet: Moonlight / remote desktop / scrcpy  
- Full DAW and video on real hardware; pad is glass + touch  

```bash
./scripts/android-linux-bridge.sh --remote
```

### 3. Real ARM Linux port, then UST layer

Only if postmarketOS / Ubuntu Touch / mainline exists for **your exact model**.

1. **[ARM-PORT.md](ARM-PORT.md)**  
2. **[ARM.md](ARM.md)** + **[PLASMA-MOBILE.md](PLASMA-MOBILE.md)**  
3. Optional Android apps on Linux: **[WAYDROID.md](WAYDROID.md)** (opposite direction of Andronix)

### 4. Android-only Linux toys

Andronix / Termux for learning and light tools — **not** claimed as “Ubuntu Studio on the Pad.”

---

## How this relates to Ubuntu Studio Tablet

```
Android tablet (stock)
        │
        ├─► Stay on Android ──► Termux / Andronix (nested Linux)
        │                   └──► Remote into amd64 Studio  ← recommended
        │
        └─► Replace Android (supported devices only)
                  Ubuntu Touch / postmarketOS / mainline
                        └──► then install-arm.sh (this repo)
```

**Never expected:** flashing the Ubuntu Studio **amd64** ISO onto a typical ARM Android pad and getting a working Studio desktop.

---

## Related docs

| Doc | Topic |
|-----|--------|
| [XIAOXIN.md](XIAOXIN.md) | Laptop vs Pad |
| [ARM-PORT.md](ARM-PORT.md) | Get ARM Linux booting first |
| [WAYDROID.md](WAYDROID.md) | Android apps *on* Linux (not Linux on Android) |
| `scripts/android-linux-bridge.sh` | Termux / remote / chroot cheat sheets |
