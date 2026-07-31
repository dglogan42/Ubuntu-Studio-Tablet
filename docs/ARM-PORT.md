# Getting a working ARM Linux port (before Studio Tablet)

This repo **does not**:

- Unlock bootloaders  
- Ship device kernels / device trees  
- Flash firmware  
- Guarantee postmarketOS on every Xiaoxin model  
- Run **Ubuntu Studio’s amd64 ISO** on a typical Android tablet  

**Running a full desktop OS like Ubuntu Studio directly on an Android tablet is not natively supported.**  
If you must stay on Android, use Termux / Andronix / remote Studio — see **[ANDROID-ALTERNATIVES.md](ANDROID-ALTERNATIVES.md)**.  
If you can replace Android on a *supported* device, **postmarketOS** or **Ubuntu Touch** come first; this repo is step 2+.

It **does** turn an already-booting **Plasma 6 ARM system** into a Studio Tablet experience (`install-arm.sh`).

```
┌─────────────────────────────┐
│ 1. Working ARM Linux base   │  ← this document
│    (kernel + display + touch│
│     + input + storage)      │
└─────────────┬───────────────┘
              ▼
┌─────────────────────────────┐
│ 2. Plasma Mobile / Desktop  │  ← install-plasma-mobile.sh
└─────────────┬───────────────┘
              ▼
┌─────────────────────────────┐
│ 3. Studio Tablet layer      │  ← install-layer.sh / install-arm.sh
│    (configs + ust apps)     │
└─────────────────────────────┘
```

---

## Step 0 — Identify your exact device

On Android (Settings or ADB):

```bash
# USB debugging enabled
adb shell getprop ro.product.device
adb shell getprop ro.product.model
adb shell getprop ro.product.name
adb shell getprop ro.board.platform
adb shell getprop ro.hardware
adb shell getprop ro.build.product
```

Or run from this repo (with `adb` on your PC):

```bash
./scripts/check-device-support.sh
./scripts/check-device-support.sh --codename lenovo-j716f
```

Match against `data/device-matrix.tsv`.

| You find… | Meaning for native Linux |
|-----------|---------------------------|
| Codename in matrix with **testing** / **community** | Possible — follow pmOS wiki carefully |
| **archived** | Historically attempted; often broken; advanced only |
| **unsupported** / no match | No ready port — use Path C/D/E below |

---

## Path A — postmarketOS (native dual-boot / replace Android)

**Best when:** your codename is listed and status is not pure fantasy.

### A0. Official downloads (images + kernel flash)

| Resource | URL |
|----------|-----|
| Download how-to | https://postmarketos.org/download/ |
| Prebuilt images | https://images.postmarketos.org/ |
| Current branch example | https://images.postmarketos.org/v26.06/ |
| Edge (rolling) | https://images.postmarketos.org/edge/ |
| Devices list | https://wiki.postmarketos.org/wiki/Devices |
| Installation guide | https://wiki.postmarketos.org/wiki/Installation_guide |
| pmbootstrap | https://wiki.postmarketos.org/wiki/Pmbootstrap |

Prebuilt trees are usually:  
`https://images.postmarketos.org/<channel>/<vendor>/<device>/…`  
Pick a UI tarball that includes **plasma-mobile** when available, then flash **rootfs + kernel** as the device wiki describes (`fastboot flash boot …`, `pmbootstrap flasher flash_kernel`, SD card, etc.).

**Ubuntu Touch** (if the pad is on the UBports list instead of pmOS):

| Resource | URL |
|----------|-----|
| Official homepage | https://www.ubuntu-touch.io/ |
| Get Ubuntu Touch / devices | https://devices.ubuntu-touch.io/ |
| Installer (downloads recovery/kernel/system) | https://devices.ubuntu-touch.io/installer/ |
| Installer releases | https://github.com/ubports/ubports-installer/releases/latest |
| Apps | https://www.ubuntu-touch.io/apps |
| Install docs | https://docs.ubports.com/en/latest/userguide/install.html |

Full comparison + Studio ISO links: **[ANDROID-ALTERNATIVES.md](ANDROID-ALTERNATIVES.md)**.

### A1. Read the device wiki

```
https://wiki.postmarketos.org/wiki/<Wiki_Slug_from_matrix>
https://wiki.postmarketos.org/wiki/Devices
```

Note: **USB**, **display**, **touch**, **Wi‑Fi**, **gpu**, **flash method** (fastboot vs lk2nd vs etc.).

### A2. Warnings (Chinese tablets)

1. **Unlocking the bootloader often factory-resets and can void warranty.**  
2. Some Xiaoxin models have **no known relock**.  
3. **CN vs ROW** firmware differences break generic guides.  
4. **Widevine / banking apps** may die after unlock.  
5. Always keep a **stock ROM package** for recovery.

This project will **not** walk you through vendor unlock exploits. Use:

- Official Lenovo unlock tools where they exist  
- Device-specific XDA / Coolapk threads  
- postmarketOS device page “Installation” section only  

### A3. Build with pmbootstrap (on a Linux PC)

```bash
# On a development PC (x86_64 or aarch64), not necessarily the tablet:
pipx install pmbootstrap   # or distro package

pmbootstrap init
# Channel: recommended default for your pmOS version
# Vendor:  lenovo   (or as wiki says)
# Device:  j716f    (example — YOUR codename)
# UI:      plasma-mobile
# User / password: choose carefully

pmbootstrap install
# Follow device wiki for:
#   pmbootstrap flasher flash_rootfs
#   pmbootstrap flasher flash_kernel
#   or dd to SD / fastboot boot
```

Helper with codename hints:

```bash
./scripts/pmbootstrap-hints.sh lenovo-j716f
```

### A4. After first boot of Plasma Mobile

```bash
# On the tablet (ssh or terminal)
# Copy this repo, then:
sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative --with-waydroid
```

You now have the Studio Tablet layer on a **real** ARM Linux port.

---

## Path B — Ubuntu arm64 on “almost mainline” hardware

Only realistic if:

- Device is a **Chromebook tablet**, or  
- SoC has solid **mainline** (rare for recent Xiaoxin Snapdragon/Dimensity), or  
- You use a **generic ARM board** (not the Xiaoxin) as the Studio host  

Generic:

```bash
# Example: Ubuntu Server arm64 on supported UEFI hardware, then:
sudo apt update
sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative
```

Xiaoxin Pad Pro 2024/2025 **Dimensity / 8 Gen** class: **do not expect** a drop-in Ubuntu ISO.

---

## Path C — No native port: Android stays, Linux in a box

When `check-device-support.sh` says **unsupported**, you still can:

### C1. proot / chroot (no dual-boot)

- **Termux** + **proot-distro** (Ubuntu) for CLI tools  
- **UserLAnd**, **Andronix**, or **Linux Deploy** (chroot; needs root for best results)  
- GUI via VNC/XSDL — **not** a native Plasma Mobile session; Studio Tablet layer is limited  

```bash
./scripts/android-linux-bridge.sh --print-termux
```

### C2. Remote Studio host (recommended for real DAW/video)

| Role | Machine |
|------|---------|
| Glass + touch | Xiaoxin on Android |
| Heavy Studio | AMD64 mini-PC with Ubuntu Studio Tablet layer |

Connect with **Sunshine/Moonlight**, **RDP**, **KDE Connect**, or **SSH + Waypipe**.

```bash
./scripts/android-linux-bridge.sh --print-remote
```

### C3. Waydroid is the opposite direction

Waydroid = Android **on** Linux.  
It needs Path A/B first. It does **not** replace a missing kernel port.

---

## Path D — Buy / use hardware that already has a port

If the goal is “Plasma Mobile tablet that runs Studio apps” rather than “must be this Xiaoxin”:

| Device class | Why |
|--------------|-----|
| **PineTab 2** / community Linux tablets | Built for mainline |
| **Librem 5** / **PinePhone** (phone form) | Plasma Mobile reference |
| **x86 2-in-1** | Official Ubuntu Studio ISO + this repo’s desktop tablet mode |
| Older Lenovo with **community** pmOS | e.g. some Chromebook tablets |

Then run `install-arm.sh` or `install-tablet-mode.sh` as appropriate.

---

## Path E — Contribute a port (advanced)

If you have an unsupported Xiaoxin and want native Linux long-term:

1. Collect kernel source from Lenovo (GPL releases)  
2. Join **#postmarketos** / device bring-up docs  
3. Start from a **same-SoC** device package if one exists (e.g. SD870 family)  
4. Goals for “Studio Tablet ready”: DRM display, touch, Wi‑Fi, USB gadget or wifi ssh, GPU accel  
5. Only then run this repo’s layer  

We document SoC families in `data/device-matrix.tsv` under `generic-*` rows.

---

## Decision flowchart

```
Identify codename (check-device-support.sh)
        │
        ├─ supported / testing ──► Path A (pmOS) ──► install-arm.sh
        │
        ├─ archived ──► Path A only if you accept bricks + fixups
        │                else Path C/D
        │
        └─ unsupported ──► Path C (proot/remote) or Path D (other hardware)
                           Path E if you will port
```

---

## What “working” means for Studio Tablet

Minimum for `install-arm.sh` to be useful:

| Feature | Why |
|---------|-----|
| Boots to Wayland session | Plasma Mobile needs it |
| Display + touch | Tablet UX |
| Storage writable | Install packages |
| Network | apt/apk, Waydroid images |
| GPU accel (nice) | Krita / video scrubbing |
| Audio (nice) | Audacity / DAW |

Without display+touch, stop — fix the **port**, not this repo.

---

## Scripts in this repo

| Script | Purpose |
|--------|---------|
| `scripts/check-device-support.sh` | Probe adb + matrix lookup |
| `scripts/pmbootstrap-hints.sh` | pmbootstrap init hints for known codenames |
| `scripts/android-linux-bridge.sh` | Termux / remote fallbacks when no port |
| `scripts/install-arm.sh` | **After** Linux boots |

---

## Related docs

- [ARM.md](ARM.md) — once Linux is up  
- [PLASMA-MOBILE.md](PLASMA-MOBILE.md) — shell  
- [WAYDROID.md](WAYDROID.md) — Android apps **on** Linux  
- [XIAOXIN.md](XIAOXIN.md) — model overview  
