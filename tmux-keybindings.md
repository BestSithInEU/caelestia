# Tmux Keybindings

**Prefix:** `Ctrl+Space` (default `Ctrl+b` is unbound)

> Bindings marked with **[custom]** are from your `.tmux.conf`. Everything else is a tmux default.

---

## General / Session Management

| Keybinding     | Action                                                        |
| -------------- | ------------------------------------------------------------- |
| `prefix` + `r` | Reload tmux config **[custom]**                               |
| `prefix` + `f` | Sesh session picker (fzf + zoxide + tmuxinator) **[custom]**  |
| `prefix` + `P` | Command palette (fzf popup with common commands) **[custom]** |
| `prefix` + `d` | Detach from session                                           |
| `prefix` + `s` | List/switch sessions                                          |
| `prefix` + `$` | Rename current session                                        |
| `prefix` + `(` | Switch to previous session                                    |
| `prefix` + `)` | Switch to next session                                        |
| `prefix` + `:` | Open command prompt                                           |
| `prefix` + `?` | List all keybindings                                          |
| `prefix` + `t` | Show clock                                                    |
| `prefix` + `~` | Show messages                                                 |
| `Shift+Enter`  | Newline in Claude Code (CSI u passthrough) **[custom]**       |

### Sesh Popup Controls

| Keybinding | Action                  |
| ---------- | ----------------------- |
| `Ctrl+a`   | Show all sources        |
| `Ctrl+t`   | Show tmux sessions only |
| `Ctrl+g`   | Show config dirs only   |
| `Ctrl+x`   | Show zoxide dirs only   |
| `Ctrl+f`   | Find directories        |
| `Ctrl+d`   | Kill selected session   |

## Windows

### Creating & Managing

| Keybinding     | Action                          |
| -------------- | ------------------------------- |
| `prefix` + `c` | Create new window               |
| `prefix` + `,` | Rename current window           |
| `prefix` + `&` | Kill current window (confirm)   |
| `prefix` + `.` | Move window (prompts for index) |

### Switching

| Keybinding         | Action                                                   |
| ------------------ | -------------------------------------------------------- |
| `Alt+1` – `Alt+9`  | Switch to window 1–9 **[custom]**                        |
| `Shift+Right`      | Next window **[custom]**                                 |
| `Shift+Left`       | Previous window **[custom]**                             |
| `Ctrl+Shift+Right` | Swap window position right **[custom]**                  |
| `Ctrl+Shift+Left`  | Swap window position left **[custom]**                   |
| `prefix` + `n`     | Next window                                              |
| `prefix` + `p`     | Previous window (overridden by paste — use `Shift+Left`) |
| `prefix` + `l`     | Last (most recently used) window                         |
| `prefix` + `w`     | Choose window from list                                  |

> Windows are auto-named by running process/directory via tmux-window-name (updates on pane focus and every 5s).

## Panes

### Splitting

| Keybinding      | Action                                               |
| --------------- | ---------------------------------------------------- |
| `prefix` + `\|` | Split horizontally (keeps current path) **[custom]** |
| `prefix` + `-`  | Split vertically (keeps current path) **[custom]**   |

> Defaults `prefix` + `"` and `prefix` + `%` are unbound.

### Navigation

| Keybinding     | Action                                  |
| -------------- | --------------------------------------- |
| `Alt+Left`     | Select pane left **[custom]**           |
| `Alt+Down`     | Select pane down **[custom]**           |
| `Alt+Up`       | Select pane up **[custom]**             |
| `Alt+Right`    | Select pane right **[custom]**          |
| `prefix` + `o` | Cycle to next pane                      |
| `prefix` + `;` | Toggle to last active pane              |
| `prefix` + `q` | Show pane numbers (type number to jump) |

### Resizing

| Keybinding         | Action                                              |
| ------------------ | --------------------------------------------------- |
| `prefix` + `Left`  | Resize pane left 5 units (repeatable) **[custom]**  |
| `prefix` + `Down`  | Resize pane down 5 units (repeatable) **[custom]**  |
| `prefix` + `Up`    | Resize pane up 5 units (repeatable) **[custom]**    |
| `prefix` + `Right` | Resize pane right 5 units (repeatable) **[custom]** |
| `prefix` + `z`     | Toggle pane zoom (fullscreen)                       |

### Layout & Management

| Keybinding         | Action                         |
| ------------------ | ------------------------------ |
| `prefix` + `Space` | Cycle through pane layouts     |
| `prefix` + `{`     | Swap pane with previous        |
| `prefix` + `}`     | Swap pane with next            |
| `prefix` + `x`     | Kill current pane (confirm)    |
| `prefix` + `!`     | Break pane into its own window |
| `prefix` + `m`     | Mark current pane              |
| `prefix` + `M`     | Clear marked pane              |

> Tilish provides i3-like tiling with `main-vertical` as default layout.

## Copy Mode (Emacs-style)

### Entering & Exiting

| Keybinding     | Action                       |
| -------------- | ---------------------------- |
| `prefix` + `e` | Enter copy mode **[custom]** |
| `prefix` + `p` | Paste buffer **[custom]**    |
| `q` / `Escape` | Exit copy mode               |

> Defaults `prefix` + `[` and `prefix` + `]` are unbound (Turkish-friendly).

### Navigation (in copy mode)

| Keybinding                 | Action                      |
| -------------------------- | --------------------------- |
| Arrow keys                 | Move cursor                 |
| `Ctrl+Left` / `Ctrl+Right` | Forward / backward one word |
| `Home` / `End`             | Start / end of line         |
| `Page Up` / `Page Down`    | Full page up / down         |
| `Ctrl+Up` / `Ctrl+Down`    | Scroll up / down            |
| `Ctrl+s`                   | Search forward              |
| `Ctrl+r`                   | Search backward             |
| `n`                        | Repeat last search          |

### Selection & Copying (in copy mode)

| Keybinding   | Action                              |
| ------------ | ----------------------------------- |
| `Ctrl+Space` | Begin selection                     |
| `Alt+w`      | Copy selection and cancel           |
| `Ctrl+w`     | Cut selection                       |
| `Enter`      | Copy selection and cancel (default) |

> tmux-yank copies to system clipboard via `wl-copy` (Wayland).

## Buffer Management

| Keybinding     | Action                           |
| -------------- | -------------------------------- |
| `prefix` + `=` | Choose buffer to paste from list |
| `prefix` + `#` | List all paste buffers           |

## Plugin Keybindings

### Sesh (session manager)

| Keybinding     | Action                            |
| -------------- | --------------------------------- |
| `prefix` + `f` | Open sesh fzf picker **[custom]** |

### Claude Code

| Keybinding          | Action                                          |
| ------------------- | ----------------------------------------------- |
| `prefix` + `Ctrl+c` | Open Claude Code in popup (80x80%) **[custom]** |

### tmux-fzf

| Keybinding     | Action             |
| -------------- | ------------------ |
| `prefix` + `F` | Open tmux-fzf menu |

### tmux-thumbs (vimium-style hints)

| Keybinding         | Action                                       |
| ------------------ | -------------------------------------------- |
| `prefix` + `Space` | Show text hints, select to copy to clipboard |

### Extrakto (fuzzy text extraction)

| Keybinding       | Action                                        |
| ---------------- | --------------------------------------------- |
| `prefix` + `Tab` | Fuzzy-find text in scrollback, select to copy |

### tmux-fzf-url

| Keybinding     | Action                                  |
| -------------- | --------------------------------------- |
| `prefix` + `u` | Pick and open URLs from terminal output |

### tmux-yank (in copy mode)

| Keybinding | Action                             |
| ---------- | ---------------------------------- |
| `y`        | Copy to system clipboard (wl-copy) |
| `Y`        | Copy and paste to command line     |

### tmux-resurrect

| Keybinding          | Action          |
| ------------------- | --------------- |
| `prefix` + `Ctrl+s` | Save session    |
| `prefix` + `Ctrl+r` | Restore session |

---

## Settings

| Setting                | Value                                                    |
| ---------------------- | -------------------------------------------------------- |
| Mouse                  | Enabled                                                  |
| History limit          | 50,000 lines                                             |
| Base index             | 1 (windows and panes)                                    |
| Clipboard              | On (wl-copy via Wayland)                                 |
| Escape time            | 0ms                                                      |
| Focus events           | On                                                       |
| Aggressive resize      | On                                                       |
| Display time           | 4,000ms                                                  |
| Renumber windows       | On                                                       |
| Extended keys          | On (CSI u format)                                        |
| Allow passthrough      | On                                                       |
| Status interval        | 5s                                                       |
| Continuum auto-restore | Off                                                      |
| Theme                  | Dracula + Caelestia colors (synced from Hyprland scheme) |
| Status bar             | Top                                                      |

## Plugins

| Plugin           | Purpose                                         |
| ---------------- | ----------------------------------------------- |
| tpm              | Plugin manager                                  |
| dracula/tmux     | Theme — status bar, powerline segments, widgets |
| tmux-yank        | System clipboard integration (wl-copy)          |
| tmux-resurrect   | Session save/restore                            |
| tmux-continuum   | Auto save/restore                               |
| tmux-fzf         | Fuzzy finder integration                        |
| extrakto         | Fuzzy text extraction from scrollback           |
| tmux-thumbs      | Vimium-style text hints to copy                 |
| tmux-fzf-url     | Open URLs from terminal output                  |
| tmux-autoreload  | Auto-reload config on save                      |
| tmux-tilish      | i3-like tiling layouts                          |
| tmux-window-name | Auto-name windows by process/directory          |

## Status Bar Layout (Dracula)

```
 session ── windows ──  git │ CPU │ GPU │ RAM │  playerctl │  weather │  time
```

**Left side:**

- Session name with powerline separator
- Window tabs (auto-named)

**Right side (dracula widgets):**

- **Git** — branch + dirty indicator (`*`)
- **CPU** — usage percentage
- **GPU** — usage percentage
- **RAM** — used/total
- **Playerctl** — currently playing track (hidden when paused)
- **Weather** — conditions + temperature + city (via Open-Meteo)
- **Time** — 24h format

### Theming

Colors are synced from your **caelestia** scheme (`~/.config/hypr/scheme/current.conf`). Dracula's named colors are mapped to caelestia values via `caelestia-colors.sh`. When you change your system theme:

```
prefix + r
```

This reloads the config and picks up the new colors.

## Pre-built Sessions (Tmuxinator)

Managed via sesh + tmuxinator. Configs live in `~/.config/tmuxinator/`.

### ThesisNew

| Window   | Layout          | Panes                                  |
| -------- | --------------- | -------------------------------------- |
| editor   | main-vertical   | nvim (left), terminal (right)          |
| training | main-horizontal | terminal (top), lnav logs (bottom)     |
| gpu      | even-horizontal | nvtop (left), watch nvidia-smi (right) |
| git      | fullscreen      | lazygit                                |

Launch: `sesh connect -T ThesisNew` or pick from sesh picker (`prefix + f`).

To create new project layouts, add `.yml` files to `~/Documents/Projects/caelestia/tmux/tmuxinator/`.
