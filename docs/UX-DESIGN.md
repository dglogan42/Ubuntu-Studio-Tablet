# Ubuntu Studio Tablet — UX design

## Metaphor

**Phone/tablet OS**, not “desktop with a touchscreen”.

- Home screen = **app grid** (not empty desktop + taskbar only).
- Each Studio tool = **one full-screen app**.
- Switching apps = **overview / recent**, not hunting for windows.
- Typing = **OSK + Chinese IME**, not requiring a keyboard.

## Shell model

Built on **KDE Plasma 6** (Ubuntu Studio’s DE) in **tablet-friendly configuration**:

1. **Bottom navigation bar** (Home · Overview · Keyboard) — 56–64 px touch height.
2. **Full-screen Application Dashboard / custom launcher** as default “home”.
3. **KWin rules** force maximize + no border for wrapped Studio apps.
4. **Virtual keyboard** (Maliit / Qt VKB) docked at bottom when focused.
5. **Gestures**: bottom edge → home; left edge → overview (where KWin supports).

Optional future: Plasma Mobile session package when available for this Ubuntu release.

## App-style contract

Every wrapped app provides:

| Property | Value |
|----------|--------|
| `.desktop` | `Terminal=false`, large icon, Chinese `Name[zh_CN]` |
| Launch | Via `/usr/lib/ubuntu-studio-tablet/bin/ust-launch` |
| WM behavior | Maximize, fullscreen-ish, single instance preferred |
| Category | Audio / Graphics / Video / Office / System |
| Touch | Prefer GTK/Qt apps with HiDPI + large UI scale |

## Categories (home folders)

- **创作 · Graphics** — Krita, GIMP, Inkscape, Darktable, Blender  
- **音频 · Audio** — Ardour, Audacity, Carla, Hydrogen, LMMS  
- **视频 · Video** — Kdenlive, OBS, Shotcut  
- **系统 · System** — Settings, Discover, Files, Terminal  
- **网络 · Web** — Browser, store  

## Visual language

- **Dark creative theme** (Studio heritage) with high-contrast icons.
- Rounded app icons on grid (squircle mask optional via icon theme).
- Accent: soft cyan / purple (Studio-adjacent), avoid Windows-blue defaults.
- Wallpaper: abstract dark studio / soft gradient (see `branding/`).

## Scaling defaults

| Setting | Tablet default |
|---------|----------------|
| Display scale | 150–200% (depends on DPI) |
| Font DPI | 120–144 |
| Cursor / touch | Large cursor optional; prefer finger-friendly |
| Panel height | ≥ 48 px |
| Scrollbar | Wide (Plasma “large” style) |

## Accessibility

- Sticky keys optional  
- High contrast toggle  
- Screen reader (Orca) installable but not default (performance on tablets)
