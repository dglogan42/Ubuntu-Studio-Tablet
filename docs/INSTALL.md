# Install guide — Ubuntu Studio Tablet

## Option 0 — ARM tablet (Plasma Mobile) — recommended for Xiaoxin-class devices

See **[ARM.md](ARM.md)** for device caveats.

```bash
./scripts/detect-platform.sh
sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative --with-waydroid
```

| Flag | Meaning |
|------|---------|
| `--ui plasma-mobile` | Phone/tablet shell (default) |
| `--ui plasma-desktop` | Desktop Plasma + tablet configs |
| `--with-creative` | Best-effort Krita/GIMP/Audacity/… |
| `--with-waydroid` | Android apps |
| `--layer-only` | Only configs + `.desktop` + launchers |
| `--no-chinese` | Skip locale/IME |

postmarketOS Chinese: `sudo ./scripts/setup-chinese-apk.sh`  
Ubuntu Chinese: `sudo ./scripts/setup-chinese.sh`

---

## Option 1 — Xiaoxin Pro laptop / AMD64 Ubuntu Studio (fastest supported)

**New machine?** Full USB + BIOS + installer steps: **[XIAOXIN-LAPTOP.md](XIAOXIN-LAPTOP.md)**  
(prepare USB → F2 disable Secure Boot → F12 boot USB → Install → then continue below).

**Dual-boot with Windows?** Same doc — section *Dual-boot Windows checklist* (BitLocker, Fast Startup, shrink partition).

1. Install [Ubuntu Studio 26.04 LTS](https://cdimage.ubuntu.com/ubuntustudio/releases/resolute/release/) (AMD64) — or Ubuntu Desktop LTS then add Studio.
2. Copy this repo onto the machine (USB, git, scp).
3. Run:

```bash
cd ubuntu-studio-tablet
chmod +x scripts/*.sh scripts/ust-*
sudo ./scripts/install-tablet-mode.sh
sudo ./scripts/setup-chinese.sh   # for Chinese tablets / zh_CN
```

4. Log out → login screen → session **Ubuntu Studio Tablet**.
5. Open apps from the launcher; they start maximized / borderless like native apps.

### Scale UI for high-DPI tablets

```bash
# Example 150% — put in ~/.config/plasma-localerc or display settings
# Or System Settings → Display → Global scale
```

Also edit `/etc/environment.d/90-ubuntu-studio-tablet.conf` and set:

```
QT_SCALE_FACTOR=1.25
```

## Option 2 — Custom ISO remaster

Needs **~20 GB free**, root, `squashfs-tools`, `xorriso`:

```bash
./scripts/download-base-iso.sh
sudo ./scripts/remaster-iso.sh
# write iso/ubuntu-studio-tablet-26.04-amd64.iso to USB
```

If `xorriso` boot flags fail on your host, use **CUBIC** (GUI):

1. Open the official Studio ISO in CUBIC.
2. Copy `ubuntu-studio-tablet/` into the chroot as `/opt/ubuntu-studio-tablet`.
3. In chroot terminal: `bash /opt/ubuntu-studio-tablet/scripts/install-tablet-mode.sh`.
4. Generate ISO with CUBIC.

## Option 3 — Preview the home grid UX

```bash
xdg-open apps/home-grid.html
# or
python3 -m http.server -d apps 8765
# browse http://127.0.0.1:8765/home-grid.html
```

## Verify project integrity

```bash
./scripts/validate.sh
```

## Uninstall (partial)

```bash
sudo rm -rf /usr/lib/ubuntu-studio-tablet /usr/share/ubuntu-studio-tablet
sudo rm -f /usr/share/applications/ust-*.desktop
sudo rm -f /usr/share/wayland-sessions/ubuntu-studio-tablet.desktop
sudo rm -f /usr/share/xsessions/ubuntu-studio-tablet.desktop
sudo rm -f /etc/xdg/autostart/ust-tablet-session.desktop
# Restore Plasma configs from ~/.config/*.pre-ust.bak if present
```

## Audio note (Studio)

Tablet mode does **not** remove JACK/PipeWire low-latency setup. For live audio on a tablet, use a USB interface; internal speakers/mics vary by device.
