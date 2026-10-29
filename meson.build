project(
  'WezTerm-Zsh-Multiplexer-Terminal',
  version: '1.2-RCII',
  license: 'GPL-3.0-only',
)

home = run_command(
  'sh', '-c', 'printf %s "$HOME"',
  check: true,
).stdout().strip()

install_data(
  'src/.wezterm.lua',
  install_dir: home,
)

install_data(
  'src/notify-info.plugin.zsh',
  install_dir: join_paths(home, '.config', 'zsh', 'plugins'),
)

install_data(
  'src/rmux.conf',
  install_dir: join_paths(home, '.config', 'rmux'),
)
