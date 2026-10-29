# WezTerm Zsh Multiplexer Terminal

A fast, keyboard-driven terminal setup for developers who want more than a command prompt. It brings together WezTerm, Zsh, Carapace, and the Rust-based Ntux multiplexer to create a focused, configurable development environment.

## The stack

- **WezTerm** — A GPU-accelerated, cross-platform terminal emulator configured with Lua. It offers extensive customization for users who want control over their terminal environment.
- **Zsh + Carapace** — Zsh provides a flexible shell, while Carapace adds modern command-line completions to help make interactive work more predictable.
- **Ntux** — A Rust-based terminal multiplexer chosen for a performance-focused, memory-safe workflow.
- **Hotkeys** — Consistent keyboard shortcuts make it possible to move between panes, windows, and tasks without interrupting your flow.

## Notifications with a three-second threshold

The Zsh notification plugin only sends a desktop notification when a command takes longer than three seconds.

This keeps quick, interactive commands like `cd`, `ls`, `pwd`, and `git status` from generating unnecessary alerts. Longer-running tasks—such as package upgrades, dependency installation, or large searches—can notify you when they finish, including their exit status.

The result is less notification noise and a better way to keep track of work running in another window.

## Workflow

The goal is to make the terminal a complete, keyboard-driven workspace:

- Use WezTerm as the configurable terminal environment.
- Use Zsh and Carapace for an efficient command-line experience.
- Use Ntux to organize terminal sessions and panes.
- Rely on hotkeys to navigate without breaking concentration.
- Get notifications only when a command runs long enough to need your attention.

## Philosophy

This setup combines performance-oriented tools with practical usability. With a well-practiced set of hotkeys and a carefully tuned configuration, the terminal can become the center of a developer’s workflow—not just a place to enter commands.
