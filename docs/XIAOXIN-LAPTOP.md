# Install Ubuntu on a Lenovo Xiaoxin Pro **laptop** (AMD64)

This is the **supported** path for Studio Tablet: Xiaoxin Pro **notebooks** use Intel/AMD CPUs and boot standard Ubuntu / Ubuntu Studio ISOs.

> **Not a tablet?** Xiaoxin **Pad** Pro tablets are usually **ARM** — they cannot use this guide. See [ARM-PORT.md](ARM-PORT.md) and [XIAOXIN.md](XIAOXIN.md).

---

## Overview

1. **Dual-boot only:** Windows checklist (BitLocker, Fast Startup, shrink) — below  
2. Prepare a bootable USB  
3. Adjust BIOS (Secure Boot, boot order)  
4. Install Ubuntu or Ubuntu Studio  
5. Apply the **Ubuntu Studio Tablet** layer from this repo  

---

## Dual-boot Windows checklist (Xiaoxin Pro laptop)

Do this **in Windows** before flashing or shrinking, if you want **Windows + Ubuntu** on the same disk.

### 1. Back up and note recovery options

- [ ] Back up documents, browser profiles, and license keys.  
- [ ] Create a **Lenovo recovery USB** or ensure you can reinstall Windows (Lenovo Vantage / Recovery) if something fails.  
- [ ] Optional: full disk image (Macrium, etc.) on an external drive.

### 2. BitLocker (very common on Xiaoxin / Windows 11)

Encrypted C: drives often **block shrinking** and confuse dual-boot if left active mid-install.

- [ ] Open **Settings → Privacy & security → Device encryption**  
  **or** search **Manage BitLocker** (Control Panel).  
- [ ] If BitLocker / device encryption is **On**:  
  - [ ] **Back up the recovery key** (Microsoft account, USB, or print).  
  - [ ] Prefer: **Suspend BitLocker** for this reboot cycle,  
    **or** fully **Turn off BitLocker** / decrypt and wait until status is *Not encrypted* (can take hours).  
- [ ] After Ubuntu is installed and dual-boot works, you may turn BitLocker back on in Windows (keep the recovery key).

> Without the recovery key, a BIOS/boot-order change can leave Windows unrecoverable. Save it first.

### 3. Disable Fast Startup (and prefer full shutdown)

Fast Startup leaves the NTFS volume in a “semi-hibernated” state so Linux may mount Windows read-only or see wrong free space.

- [ ] **Control Panel → Power Options → Choose what the power buttons do**  
- [ ] **Change settings that are currently unavailable**  
- [ ] Uncheck **Turn on fast startup** → Save  
- [ ] Optional but helpful:  
  - [ ] Uncheck **Hibernate** if you do not need it  
  - [ ] In Lenovo Vantage / Windows: turn off **Fast Boot** style options if present  
- [ ] Shut down with a **full shutdown** (not hybrid):  
  - Hold **Shift** while clicking **Shut down**, or run in admin CMD:  
    `shutdown /s /t 0`

Also disable **Fast Boot in BIOS** later if the option exists (separate from Windows Fast Startup).

### 4. Free space: shrink the Windows partition

Aim for **≥ 40 GB** free for Ubuntu Desktop, **≥ 60–80 GB** for Ubuntu Studio + projects.

- [ ] Open **Disk Management**: `Win + X` → **Disk Management**  
- [ ] Right-click the large **Windows (C:)** volume → **Shrink Volume**  
- [ ] Enter amount to shrink (MB). Example: `80000` ≈ 80 GB.  
- [ ] Confirm **Unallocated** space appears **after** C: (do not create a new NTFS volume in that space—leave it unallocated for the Ubuntu installer).  
- [ ] If Shrink offers only a tiny amount:  
  - [ ] Run Disk Cleanup + disable hibernation (`powercfg /h off` as admin)  
  - [ ] Temporarily disable page file / System Restore, reboot, shrink, then restore settings  
  - [ ] Ensure BitLocker is suspended/off  
  - [ ] Reboot once more and try shrink again  

Do **not** use third-party partition tools on BitLocker volumes unless you know the risks.

### 5. Firmware time (avoids dual-boot clock jumps)

- [ ] After both OS work: in Windows, either  
  - set Ubuntu to local RTC, or (common fix) in Ubuntu:  
    `timedatectl set-local-rtc 0` and keep both on **UTC**/network time,  
  - or apply the well-known Windows registry “RealTimeIsUniversal” fix if the clock skews after each boot.

### 6. Then continue the normal install

- [ ] Create Ubuntu USB ([Preparation](#preparation))  
- [ ] BIOS: disable **Secure Boot**, keep **UEFI** ([BIOS setup](#bios-setup-xiaoxin-pro-laptop))  
- [ ] F12 → USB → installer → **Install alongside Windows**  
  - or **Something else** and use the **unallocated** space (EFI partition is usually shared with Windows—do not format the existing EFI blindly)  
- [ ] After install: at GRUB you should see **Ubuntu** and **Windows Boot Manager**

### Quick dual-boot checklist (print / tick)

| Step | Done |
|------|------|
| Backup + BitLocker recovery key saved | ☐ |
| BitLocker suspended or fully off | ☐ |
| Fast Startup off + full shutdown | ☐ |
| C: shrunk; **unallocated** space ready | ☐ |
| Secure Boot off (BIOS); UEFI mode | ☐ |
| Ubuntu installed alongside; both OS in GRUB | ☐ |
| Studio Tablet layer installed (optional) | ☐ |

---

## Preparation

### 1. Download an ISO

| Goal | ISO | Link |
|------|-----|------|
| **Creative workstation + tablet UX (recommended)** | Ubuntu Studio 26.04 LTS amd64 | [cdimage — resolute release](https://cdimage.ubuntu.com/ubuntustudio/releases/resolute/release/) |
| General desktop first, Studio later | Ubuntu Desktop LTS amd64 | [ubuntu.com/download/desktop](https://ubuntu.com/download/desktop) |

- Studio ISO is **~6.7 GB** → use a **USB ≥ 8 GB** (4 GB is often too small for Studio).  
- Ubuntu Desktop LTS fits on **≥ 4 GB** USB more easily.

Optional (this repo, when you have disk space):

```bash
./scripts/download-base-iso.sh   # Ubuntu Studio 26.04 only
```

### 2. Flash the USB

Use one of:

- **Ventoy** (copy ISO onto USB; easy multi-ISO)  
- **Rufus** (Windows) — DD mode if ISO mode fails  
- **Balena Etcher**  
- Linux: `dd`, Startup Disk Creator, or `usb-creator-gtk`

Example (`sdX` = your USB, **not** the internal disk):

```bash
sudo dd if=ubuntustudio-26.04-desktop-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

### 3. Back up

Back up Windows/user files before dual-boot or erase-disk installs.

---

## BIOS setup (Xiaoxin Pro laptop)

1. **Shut down** completely.  
2. Power on and press **F2** repeatedly for BIOS.  
   - Or use the **Novo button** (pinhole on the side) → **BIOS Setup**.  
3. **Security** tab → **Secure Boot** → **Disabled**.  
4. Confirm USB boot is allowed; set boot order if needed.  
5. Save & exit (**F10**).

Notes:

- Some units use **F1** for Setup; boot menu is usually **F12**.  
- If the USB never appears, try another port (prefer USB-A / disable USB-C dock quirks), another stick, or Ventoy.  
- For dual-boot, leave **UEFI** mode (do not switch to legacy CSM unless you know you need it).

---

## Installation steps

1. Insert the bootable USB.  
2. Restart and tap **F12** for the one-time **boot menu**.  
3. Select the USB drive → Enter.  
4. At GRUB:  
   - **Try or Install Ubuntu Studio** / **Install Ubuntu** (wording depends on ISO).  
5. Follow the installer:  
   - Language  
   - Wi‑Fi (optional but useful for updates)  
   - Normal vs minimal (Studio: prefer full/normal for creative apps)  
6. **Installation type**  
   - **Erase disk and install** — clean single-boot Linux  
   - **Install alongside Windows** — dual-boot (**complete the [Windows checklist](#dual-boot-windows-checklist-xiaoxin-pro-laptop) first**)  
   - **Something else** — manually use the **unallocated** space you created by shrinking C:
7. Region, username, password.  
8. Wait for copy/install → **Restart** → **remove USB** when prompted.

First boot: complete any first-run wizard, install updates:

```bash
sudo apt update && sudo apt full-upgrade -y
```

---

## After Ubuntu: Studio Tablet layer

If you installed **Ubuntu Studio 26.04**:

```bash
cd /path/to/ubuntu-studio-tablet
sudo ./scripts/install-tablet-mode.sh
sudo ./scripts/setup-chinese.sh    # optional: zh_CN + fcitx5
```

Log out → session **Ubuntu Studio Tablet**.

If you installed **Ubuntu Desktop** only:

```bash
# Option A — add Studio stack then tablet mode
sudo apt install ubuntustudio-installer   # if available
# or use Ubuntu Studio Installer GUI from the store

# Option B — Plasma + creative apps manually, then:
sudo ./scripts/install-tablet-mode.sh
```

Tablet-style apps (fullscreen, Chinese labels) come from this repo’s `ust-*.desktop` wrappers — see [INSTALL.md](INSTALL.md).

---

## Touch / 2-in-1 convertibles

If the Xiaoxin Pro is a **flip / yoga-style** 2-in-1:

- Install `iio-sensor-proxy` (tablet mode package list includes it).  
- In Plasma: enable tablet / convertible behavior if offered.  
- Scale display to **150–200%** for HiDPI panels.  
- Pen (if any): test in Krita after install.

---

## Troubleshooting

| Problem | What to try |
|---------|-------------|
| No USB in F12 menu | Reflash ISO; Ventoy; other USB port; disable Fast Boot in Windows first |
| Secure Boot blocks install | Disable Secure Boot (and sometimes “Secure Boot Mode”) |
| Black screen after GRUB | Try “safe graphics” / nomodeset from GRUB `e` edit |
| Dual-boot missing Windows | Both OS UEFI; `sudo update-grub`; do not delete Windows EFI entries |
| Cannot shrink C: enough | BitLocker off; Fast Startup off; `powercfg /h off`; reboot; retry |
| Windows asks for BitLocker key after BIOS change | Enter saved recovery key; re-suspend or fix Secure Boot carefully |
| NTFS “unclean” / read-only in Linux | Disable Fast Startup; full shutdown Windows once |
| Wi‑Fi missing | Temporary USB Ethernet; then install OEM/kernel updates |
| Chinese input | `sudo ./scripts/setup-chinese.sh` |

---

## Related

- [XIAOXIN.md](XIAOXIN.md) — laptop vs Pad Pro (ARM)  
- [INSTALL.md](INSTALL.md) — tablet mode details  
- [UX-DESIGN.md](UX-DESIGN.md) — app-style UX  
