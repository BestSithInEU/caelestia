# Tmux — How to Use

A practical guide for the caelestia tmux setup. Covers daily workflows, plugin usage, and tips.

---

## Getting Started

### First Launch

```bash
tmux
```

On first run, install all plugins:

```
prefix + I
```

> **Prefix** is `Ctrl+Space` throughout this guide.

### Starting a Named Session

```bash
tmux new -s project-name
```

Or use **sesh** (recommended):

```
prefix + f
```

This opens a fzf popup where you can:

- Browse existing tmux sessions
- Pick a **tmuxinator** layout (yellow icon) to launch a pre-built session
- Pick a **zoxide** directory to open as a new session
- Search your filesystem for project folders
- Kill sessions you no longer need

### Pre-built Sessions (Tmuxinator)

Some projects have pre-configured layouts with multiple windows and panes:

```bash
sesh connect -T ThesisNew
```

Or select from the sesh picker — tmuxinator sessions show with a yellow icon.

Available layouts are in `~/.config/tmuxinator/`. To create a new one:

```bash
cp ~/.config/tmuxinator/ThesisNew.yml ~/.config/tmuxinator/MyProject.yml
# Edit to match your project
```

---

## Core Workflow

### Panes (splits within a window)

**Create splits:**

- `prefix + |` — split side by side (horizontal)
- `prefix + -` — split top/bottom (vertical)

**Move between panes:**

- `Alt + Arrow keys` — jump to the pane in that direction (no prefix needed)

**Resize panes:**

- `prefix + Arrow keys` — grow/shrink by 5 units (hold the arrow to keep resizing)

**Zoom a pane:**

- `prefix + z` — toggle fullscreen on the current pane. Press again to restore.

**Close a pane:**

- `prefix + x` — kill the current pane (asks for confirmation)
- Or just type `exit` / `Ctrl+d` in the shell

### Windows (tabs along the top)

**Create:** `prefix + c`

**Switch:**

- `Alt + 1–9` — jump directly to window number (no prefix needed)
- `Shift + Left/Right` — cycle through windows (no prefix needed)

**Reorder:** `Ctrl+Shift + Left/Right` — move the current window left/right

**Rename:** `prefix + ,` then type a new name

**Close:** `prefix + &` or close all panes in the window

> Windows are auto-named by directory/process via tmux-window-name. Updates on pane focus and every 5 seconds.

### Sessions

**Switch sessions:**

- `prefix + f` — sesh picker (best option, uses zoxide + tmuxinator)
- `prefix + s` — built-in session list
- `prefix + (` / `)` — previous / next session

**Detach:** `prefix + d` — leaves the session running in the background

**Reattach:**

```bash
tmux attach -t session-name
# or just use sesh:
# prefix + f → pick the session
```

**Kill a session:**

- `prefix + P` → select `kill-session` from the command palette
- Or from sesh picker: `Ctrl+d` on the selected session

**Rename:** `prefix + $`

### Command Palette

`prefix + P` (capital P) opens a fzf popup with common tmux commands:

- kill-session, kill-window, kill-pane, kill-server
- new-window, new-session
- rename-window, rename-session
- swap-window, swap-pane, resize-pane
- list-keys, show-options
- And more

---

## Using Plugins

### Sesh — Smart Session Manager

`prefix + f` opens the session picker. Inside the popup:

| Key | Shows |
|-----|-------|
| `Ctrl+a` | Everything (all sources) |
| `Ctrl+t` | Tmux sessions only |
| `Ctrl+x` | Zoxide directories (frecency-ranked) |
| `Ctrl+g` | Config directories |
| `Ctrl+f` | Find directories in `~` |
| `Ctrl+d` | Kill the selected session |

Type to fuzzy-filter, `Enter` to connect. Tmuxinator sessions (yellow icon) launch with their pre-configured layout.

### Listing Sources

```bash
sesh list -i        # all sources (tmux + zoxide + tmuxinator)
sesh list -t        # tmux sessions only
sesh list -T        # tmuxinator configs only
sesh list -z        # zoxide directories only
```

### Claude Code

`prefix + Ctrl+c` opens Claude Code in an 80x80% popup overlay.

`Shift+Enter` works for multi-line input inside tmux.

### Thumbs — Copy Any Visible Text

`prefix + Space` — highlights all copyable text on screen with letter hints.

Type the hint letters to copy that text to your clipboard (`wl-copy`). Great for:

- File paths
- IP addresses
- Commit hashes
- Error codes
- URLs

### Extrakto — Search Your Scrollback

`prefix + Tab` — opens a fzf popup searching through your scrollback buffer.

Start typing to filter. Select a match to copy it to clipboard. Useful when output has scrolled past and you need to grab something from earlier.

### tmux-fzf-url — Open URLs

`prefix + u` — lists all URLs visible in the current pane.

Pick one to open it in your browser.

### tmux-fzf — Everything Else

`prefix + F` (capital F) — opens a menu to fuzzy-find and manage:

- Sessions
- Windows
- Panes
- Key bindings
- Commands
- Clipboard buffers

### Resurrect — Save/Restore Sessions

- `prefix + Ctrl+s` — **save** your entire tmux state (all sessions, windows, panes, and their working directories)
- `prefix + Ctrl+r` — **restore** a previously saved state

Do this before rebooting or when you want a checkpoint.

---

## Copy & Paste

### Quick Copy (without entering copy mode)

- **Thumbs:** `prefix + Space` → type hint letters → copied to clipboard
- **Extrakto:** `prefix + Tab` → fuzzy search → select → copied to clipboard
- **Mouse:** select text with mouse → automatically copied (tmux-yank)

### Copy Mode (for precise selection)

1. `prefix + e` — enter copy mode
2. Use **arrow keys** to navigate, `Page Up/Down` to scroll
3. `Ctrl+Space` — start selection
4. Move to extend the selection
5. `Alt+w` or `Enter` — copy and exit

Paste with `prefix + p`.

### Search in Copy Mode

1. `prefix + e` — enter copy mode
2. `Ctrl+s` — search forward (type your query, press `Enter`)
3. `Ctrl+r` — search backward
4. `n` — jump to next match

### Clipboard Integration

Everything copies to your Wayland clipboard via `wl-copy`. Paste anywhere with `Ctrl+v` (in GUI apps) or middle-click.

---

## Tiling Layouts (Tilish)

Tilish gives you i3-like automatic tiling inside tmux. Your panes arrange themselves based on the active layout.

**Cycle layouts:** `prefix + Space`

Available layouts:

- **main-vertical** (default) — one large pane on the left, others stacked on the right
- **main-horizontal** — one large pane on top, others below
- **tiled** — equal-sized grid
- **even-horizontal** — all panes side by side
- **even-vertical** — all panes stacked

---

## Status Bar (Dracula + Caelestia)

```
 session ── windows ──  git │ CPU │ GPU │ RAM │  playerctl │  weather │  time
```

**Left side:** Session name + window tabs (powerline separators)

**Right side (dracula widgets):**

- **Git** — branch name, `*` when dirty
- **CPU/GPU/RAM** — system resource usage
- **Playerctl** — currently playing track (hidden when paused/stopped)
- **Weather** — conditions + temperature + city (via Open-Meteo API, cached 10min)
- **Time** — 24h format

### Theming

Colors are dynamically mapped from your **caelestia** scheme. Dracula's named colors (white, gray, cyan, etc.) are overridden with caelestia values via `caelestia-colors.sh`. When you change your system theme:

```
prefix + r
```

This reloads the config and picks up the new colors.

---

## Tips & Tricks

### Mouse Support

- **Click** a pane to focus it
- **Drag** pane borders to resize
- **Scroll** to enter copy mode and scroll through history
- **Select text** to copy it automatically

### Quick Pane Arrangements

- Split a terminal and run a server on one side, logs on the other: `prefix + |` then start your processes
- Need a quick scratch terminal? `prefix + -` for a small bottom pane, `prefix + z` to zoom it when needed

### Working with Multiple Projects

1. `prefix + f` → `Ctrl+x` to browse your zoxide directories
2. Pick a project → sesh creates a named session
3. Set up your panes (editor, server, etc.)
4. `prefix + Ctrl+s` to save state
5. Switch between projects with `prefix + f`

### Using Tmuxinator for Complex Projects

If you always need the same layout for a project, create a tmuxinator config:

```yaml
# ~/.config/tmuxinator/MyProject.yml
name: MyProject
root: ~/Documents/MyProject

windows:
  - editor:
      layout: main-vertical
      panes:
        - nvim .
        - null
  - server:
      panes:
        - npm run dev
  - git:
      panes:
        - lazygit
```

Then launch via sesh: `sesh connect -T MyProject`

### Detach and Resume

Working on a remote server? SSH in, attach to tmux, do your work, detach (`prefix + d`), disconnect. SSH back in later:

```bash
tmux attach
```

Everything is exactly as you left it.

### Config Auto-Reload

The `tmux-autoreload` plugin watches `~/.tmux.conf`. Any time you save changes, tmux picks them up automatically — no need to manually reload.

### Clean Up Zoxide Entries

If sesh shows noisy zoxide paths (like `.venv/bin`):

```fish
zoxide query -l | grep -E '\.venv|\.cache' | xargs -I{} zoxide remove {}
```

---

## Quick Reference Card

| Action | Keys |
|---|---|
| **Split horizontal** | `prefix + \|` |
| **Split vertical** | `prefix + -` |
| **Move between panes** | `Alt + Arrows` |
| **Resize panes** | `prefix + Arrows` |
| **Zoom pane** | `prefix + z` |
| **New window** | `prefix + c` |
| **Switch window** | `Alt + 1-9` or `Shift + Left/Right` |
| **Reorder window** | `Ctrl+Shift + Left/Right` |
| **Session picker** | `prefix + f` |
| **Command palette** | `prefix + P` |
| **Claude Code popup** | `prefix + Ctrl+c` |
| **Copy text (hints)** | `prefix + Space` |
| **Search scrollback** | `prefix + Tab` |
| **Open URLs** | `prefix + u` |
| **Enter copy mode** | `prefix + e` |
| **Paste** | `prefix + p` |
| **Save session** | `prefix + Ctrl+s` |
| **Restore session** | `prefix + Ctrl+r` |
| **Reload config** | `prefix + r` |
| **Detach** | `prefix + d` |
| **Kill pane** | `prefix + x` |
| **Fuzzy menu** | `prefix + F` |
