# WezTerm Zsh Multiplexer Terminal

A keyboard-driven terminal environment for developers who want more than a command prompt. This project brings together WezTerm, Zsh, Carapace, and RMUX in one configurable workflow.

Use hotkeys to move between panes and windows, get command-line completions in Zsh, and receive desktop notifications when commands take longer than three seconds. Quick commands such as `cd`, `ls`, `pwd`, and `git status` do not trigger notifications.

## Features

- **WezTerm** — A GPU-accelerated, cross-platform terminal emulator configured with Lua.
- **Zsh and Carapace** — A flexible shell with modern command-line completions.
- **RMUX** — A Rust-based terminal multiplexer for managing sessions and panes.
- **Keyboard-driven workflow** — Hotkeys for moving between panes, windows, and tasks.
- **Long-running command notifications** — The Zsh plugin can notify you when a command takes more than three seconds, including its exit status.

## Quick links

| Section | Description |
|:---:|:---:|
| [Requirements](#requirements) | Software to install before setup |
| [Install Carapace](#install-carapace) | Install and enable shell completions |
| [Installation](#installation) | Clone, configure, and install the project |
| [Hotkeys](#hotkeys) | WezTerm and RMUX keyboard shortcuts |
| [Configuration files](#configuration-files) | Where the files are installed |
| [Enable the Zsh plugin](#enable-the-zsh-plugin) | Add the plugin to `~/.zshrc` |

## Requirements

Install these tools before setting up the project:

- Git
- Meson
- Ninja
- WezTerm
- Zsh
- Carapace
- RMUX

## Install Carapace

Install Carapace using your platform’s package manager. For example:

```sh
# Ubuntu / Debian
sudo apt install carapace-bin

# macOS (Homebrew)
brew install carapace

# Arch Linux (AUR)
yay -S carapace-bin
```

Enable Carapace in Zsh by adding these lines to `~/.zshrc`:

```sh
autoload -U compinit && compinit
source <(carapace _carapace)
```

Reload your Zsh configuration:

```sh
source "$HOME/.zshrc"
```

## Installation

Clone the repository and configure the build as your **regular user**:

```sh
git clone https://github.com/NAZY-OS/WezTerm-Zsh-Multiplexer-Terminal/
cd WezTerm-Zsh-Multiplexer-Terminal
meson setup build
```

Choose one of the following installation options.

### Install with root ownership

To install the files as `root:root`, run both `meson install` and `chown` as a **superuser**. Replace `/home/your-user` with the home directory of the user who cloned the repository and ran `meson setup`.

Switch to a superuser shell while keeping the current working directory, then run:

```sh
meson install -C build

USER_HOME=/home/your-user
chown root:root \
  "$USER_HOME/.wezterm.lua" \
  "$USER_HOME/.config/zsh/plugins/notify-info.plugin.zsh" \
  "$USER_HOME/.config/rmux/rmux.conf"
```

Do not run `meson setup` as a superuser. It needs to use the regular user’s home directory as the installation target.

### Install as your regular user

If you do not have root access or do not want the files owned by root, run:

```sh
meson install -C build
```

The files will belong to your user and can be edited without root privileges. Skip the `chown` command.

## Hotkeys

### WezTerm

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+T` | Open a new tab running RMUX |
| `Ctrl+Shift+N` | Open a new window running RMUX |
| `Ctrl+H` | Show the 40 most recent shell history entries, newest first |
| `Shift+Right` | Switch to the next tab |
| `Shift+Left` | Switch to the previous tab |
| `Ctrl+Shift+W` | Close the current tab |
| `Ctrl+Shift+=` | Increase the font size |
| `Ctrl+-` | Decrease the font size |
| `Ctrl+0` | Reset the font size |

### RMUX

The RMUX prefix is **Ctrl+E**. Press and release the prefix, then press the next key.

| Shortcut | Action |
|---|---|
| `Ctrl+E`, then `Ctrl+E` | Send the prefix key to the shell |
| `Ctrl+E`, then `h` | Split the pane side by side |
| `Ctrl+E`, then `v` | Split the pane top to bottom |
| `Ctrl+E`, then `w` | Move to the pane above |
| `Ctrl+E`, then `a` | Move to the pane on the left |
| `Ctrl+E`, then `s` | Move to the pane below |
| `Ctrl+E`, then `d` | Move to the pane on the right |
| `Ctrl+E`, then `H` | Resize the pane left |
| `Ctrl+E`, then `J` | Resize the pane down |
| `Ctrl+E`, then `K` | Resize the pane up |
| `Ctrl+E`, then `L` | Resize the pane right |
| `Ctrl+E`, then `z` | Zoom or unzoom the active pane |
| `Ctrl+E`, then `o` | Create a new window in the current directory |
| `Ctrl+E`, then `j` | Switch to the previous window |
| `Ctrl+E`, then `k` | Switch to the next window |
| `Ctrl+E`, then `l` | Return to the last active window |
| `Ctrl+E`, then `e` | Enter copy mode |
| `Ctrl+E`, then `t` | Open a separate WezTerm window |
| `Ctrl+E`, then `r` | Reload the RMUX configuration |

### Scrolling and copy mode

To scroll through pane history, enter copy mode: press and release **Ctrl+E**, then press **e**. Use the arrow keys or **Page Up/Page Down** to move through the history. Press **q** to leave copy mode.

Mouse-wheel scrolling is enabled by `set -g mouse on` in the RMUX configuration. If your trackpad gesture moves through shell history instead of pane history, use copy mode and the keyboard controls above.

In copy mode, press **v** to start selecting text, then **y** to copy the selection and leave copy mode.

**Configuration note:** The active split shortcuts are `h` for side-by-side and `v` for top-to-bottom. Make sure the help message in `rmux.conf` matches these bindings if you edit it.

## Configuration files

| File | Installation location |
|---|---|
| WezTerm configuration | `~/.wezterm.lua` |
| Zsh notification plugin | `~/.config/zsh/plugins/notify-info.plugin.zsh` |
| RMUX configuration | `~/.config/rmux/rmux.conf` |

## Enable the Zsh plugin

Run this command **once** as your regular user. It appends the plugin-loading line to `~/.zshrc`:

```sh
echo 'source "$HOME/.config/zsh/plugins/notify-info.plugin.zsh"' >> "$HOME/.zshrc"
```

Open a new shell or reload your Zsh configuration:

```sh
source "$HOME/.zshrc"
```

## License

This project is licensed under the GNU General Public License v3.0 only. See the `LICENSE` file for details.
