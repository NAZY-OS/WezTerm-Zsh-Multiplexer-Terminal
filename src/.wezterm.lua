local wezterm = require 'wezterm'
local act = wezterm.action

local config = {}

-- Start a new RMUX session without specifying a session name.
config.default_prog = {
  '/usr/bin/rmux',
  'new-session',
}

-- Set the initial window size and font.
config.initial_cols = 120
config.initial_rows = 35
config.font_size = 12.5

-- Keep the tab bar visible, even when there is only one tab.
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false

-- Set the space between terminal content and the window edges.
config.window_padding = {
  left = 8,
  right = 8,
  top = 6,
  bottom = 6,
}

-- Keyboard shortcuts.
config.keys = {
  -- Open a new tab running RMUX.
  {
    key = 't',
    mods = 'CTRL|SHIFT',
    action = act.SpawnCommandInNewTab {
      args = { '/usr/bin/rmux', 'new-session' },
    },
  },

  -- Open a new window running RMUX.
  {
    key = 'n',
    mods = 'CTRL|SHIFT',
    action = act.SpawnCommandInNewWindow {
      args = { '/usr/bin/rmux', 'new-session' },
    },
  },

  -- Show the 40 most recent shell history entries, newest first.
  -- Use this at a shell prompt inside RMUX.
  {
    key = 'h',
    mods = 'CTRL',
    action = act.SendString('history | tail -n 40 | tac\n'),
  },

  -- Switch to the next or previous tab, like KDE Konsole.
  { key = 'RightArrow', mods = 'SHIFT', action = act.ActivateTabRelative(1) },
  { key = 'LeftArrow', mods = 'SHIFT', action = act.ActivateTabRelative(-1) },

  -- Close the current tab.
  {
    key = 'w',
    mods = 'CTRL|SHIFT',
    action = act.CloseCurrentTab { confirm = true },
  },

  -- Increase, decrease, or reset the font size.
  { key = '=', mods = 'CTRL|SHIFT', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },
}

-- Hotkey reference:
-- Ctrl+Shift+T         Open a new RMUX tab
-- Ctrl+Shift+N         Open a new RMUX window
-- Ctrl+H               Show the last 40 shell history entries, newest first
-- Shift+Right          Switch to the next tab
-- Shift+Left           Switch to the previous tab
-- Ctrl+Shift+W         Close the current tab
-- Ctrl+Shift++         Increase the font size
-- Ctrl+-               Decrease the font size
-- Ctrl+0               Reset the font size

return config
