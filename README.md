# WezTerm Zsh Multiplexer Terminal

A keyboard-driven terminal environment for developers who want more than a command prompt. This project brings together WezTerm, Zsh, Carapace, and a Rust-based terminal multiplexer in one configurable workflow.

The setup is designed to make everyday terminal work more focused: use hotkeys to move between panes and sessions, get command-line completions while working in Zsh, and receive a desktop notification when a command takes longer than three seconds. Quick commands such as `cd`, `ls`, `pwd`, and `git status` do not trigger notifications.

## Features

- **WezTerm** — A GPU-accelerated, cross-platform terminal emulator configured with Lua.
- **Zsh and Carapace** — A flexible shell with modern command-line completions.
- **Ntux** — A Rust-based terminal multiplexer for managing sessions and panes.
- **Keyboard-driven workflow** — Hotkeys for moving between panes, windows, and tasks.
- **Long-running command notifications** — The Zsh plugin can notify you when a command takes more than three seconds, including its exit status.

Together, these tools make the terminal a configurable workspace for interactive work and longer-running tasks.

## Quick links

| Section | Description |
|---|---|
| [Requirements](#requirements) | Software to install before setup |
| [Installation](#installation) | Clone, configure, and install the project |
| [Configuration files](#configuration-files) | Where the files are installed |
| [Enable the Zsh plugin](#enable-the-zsh-plugin) | Add the plugin to `~/.zshrc` |
| [License](#license) | License information |

## Requirements

Install these tools before setting up the project:

- Git
- Meson
- Ninja
- WezTerm
- Zsh
- Carapace
- Ntux

## Installation

Clone the repository and configure the build as your **regular user**:

```sh
git clone https://github.com/NAZY-OS/WezTerm-Zsh-Multiplexer-Terminal/
cd WezTerm-Zsh-Multiplexer-Terminal
meson setup build
```

Choose one of the following installation options.

### Install with root ownership

To install the files as `root:root`, run both `meson install` and `chown` as a **superuser**. Before running the commands, replace `/home/your-user` with the home directory of the user who cloned the repository and ran `meson setup`.

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

If you do not have root access or do not want the files owned by root, run the installation as your **regular user**:

```sh
meson install -C build
```

The files will belong to your user and can be edited without root privileges. Skip the `chown` command.

## Configuration files

| File | Installation location |
|---|---|
| WezTerm configuration | `~/.wezterm.lua` |
| Zsh notification plugin | `~/.config/zsh/plugins/notify-info.plugin.zsh` |
| Multiplexer configuration | `~/.config/rmux/rmux.conf` |

## Enable the Zsh plugin

Run this command **once** as your regular user. It appends the plugin-loading line to `~/.zshrc`:

```sh
echo 'source "$HOME/.config/zsh/plugins/notify-info.plugin.zsh"' >> "$HOME/.zshrc"
```

Then open a new shell or reload your Zsh configuration:

```sh
source "$HOME/.zshrc"
```

## License

This project is licensed under the GNU General Public License v3.0 only. See the `LICENSE` file for details.
