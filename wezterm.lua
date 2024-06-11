-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- Functions
-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

function pad_title(tab_title, min_width)
  local length = #tab_title
  local pad = (min_width - length) // 2
  if pad > 0 then
    local format_str = string.format("%%%ds%%s%%%ds", pad, pad)
    return string.format(format_str, "", tab_title, "")
  else
    return tab_title
  end
end

-- Common Process Icons
local process_icons = {
  ['aria2c'] = wezterm.nerdfonts.fa_angle_double_down,
  ['bash'] = wezterm.nerdfonts.cod_terminal_bash,
  ['bat'] = wezterm.nerdfonts.md_bat,
  ['btm'] = wezterm.nerdfonts.md_chart_donut_variant,
  ['btop'] = wezterm.nerdfonts.md_monitor_dashboard,
  ['cargo'] = wezterm.nerdfonts.dev_rust,
  ['curl'] = wezterm.nerdfonts.md_download,
  ['docker'] = wezterm.nerdfonts.linux_docker,
  ['docker-compose'] = wezterm.nerdfonts.linux_docker,
  ['dotnet'] = wezterm.nerdfonts.md_language_csharp,
  ['fish'] = wezterm.nerdfonts.md_fish,
  ['gh'] = wezterm.nerdfonts.dev_github_badge,
  ['git'] = wezterm.nerdfonts.dev_git,
  ['go'] = wezterm.nerdfonts.md_language_go,
  ['htop'] = wezterm.nerdfonts.md_chart_donut_variant,
  ['http'] = wezterm.nerdfonts.cod_arrow_swap,
  ['java'] = wezterm.nerdfonts.dev_java,
  ['lazydocker'] = wezterm.nerdfonts.linux_docker,
  ['litecli'] = wezterm.nerdfonts.dev_sqllite,
  ['lua'] = wezterm.nerdfonts.seti_lua,
  ['kuberlr'] = wezterm.nerdfonts.linux_docker,
  ['kubectl'] = wezterm.nerdfonts.linux_docker,
  ['make'] = wezterm.nerdfonts.seti_makefile,
  ['mycli'] = wezterm.nerdfonts.dev_mysql,
  ['mysql'] = wezterm.nerdfonts.dev_mysql,
  ['node'] = wezterm.nerdfonts.dev_nodejs_small,
  ['npm'] = wezterm.nerdfonts.dev_npm,
  ['nvim'] = wezterm.nerdfonts.custom_vim,
  ['php'] = wezterm.nerdfonts.md_language_php,
  ['ping'] = wezterm.nerdfonts.md_lan_pending,
  ['ping6'] = wezterm.nerdfonts.md_lan_pending,
  ['podman-remote'] = wezterm.nerdfonts.linux_docker,
  ['psql'] = wezterm.nerdfonts.dev_postgresql,
  ['pwsh'] = wezterm.nerdfonts.seti_powershell,
  ['python'] = wezterm.nerdfonts.dev_python,
  ['redis-cli'] = wezterm.nerdfonts.dev_redis,
  ['ruby'] = wezterm.nerdfonts.cod_ruby,
  ['sqlite3'] = wezterm.nerdfonts.dev_sqllite,
  ['ssh'] = wezterm.nerdfonts.md_remote_desktop,
  ['stern'] = wezterm.nerdfonts.linux_docker,
  ['sudo'] = wezterm.nerdfonts.fa_hashtag,
  ['tmux'] = wezterm.nerdfonts.cod_terminal_tmux,
  ['vim'] = wezterm.nerdfonts.dev_vim,
  ['wezterm'] = wezterm.nerdfonts.cod_terminal,
  ['wezterm-gui'] = wezterm.nerdfonts.cod_terminal,
  ['wget'] = wezterm.nerdfonts.md_download_box,
  ['zsh'] = wezterm.nerdfonts.dev_terminal,
}

local function get_process_icon(tab)
  local process_name = tab.active_pane.foreground_process_name
  process_name = process_name:match("([^/\\]+)%.exe$") or process_name:match("([^/\\]+)$") or process_name
  process_name = process_name:match("(python)[%d%.]*$") or process_name
  local icon = process_icons[process_name] or wezterm.nerdfonts.seti_checkbox_unchecked

  return icon
end

local function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local has_unseen_output = false
  local is_zoomed = false

  for _, pane in ipairs(tab.panes) do
    if not tab.is_active and pane.has_unseen_output then
      has_unseen_output = true
    end
    if pane.is_zoomed then
      is_zoomed = true
    end
  end

  local process = get_process_icon(tab)
  local zoom_icon = is_zoomed and wezterm.nerdfonts.cod_zoom_in or "⌘" .. (tab.tab_index + 1)
  local tab_title = pad_title(tab_title(tab), 20)
  local title = string.format('%s  %s %s', process, tab_title, zoom_icon) -- Add placeholder for zoom_icon

  return wezterm.format({
    { Attribute = { Intensity = 'Bold' } },
    { Text = title }
  })
end)

wezterm.on('update-right-status', function(window, pane)
  -- "Wed Mar 3 08:14"
  local date = wezterm.strftime '%a %b %-d %H:%M '

  window:set_right_status(wezterm.format {
    { Text = wezterm.nerdfonts.fa_clock_o .. '  ' .. date },
  })
end)


-- wezterm.on('gui-startup', function()
--  local tab, pane, window = wezterm.mux.spawn_window({})
--  window:gui_window():maximize()
-- end)

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.initial_cols = 140
config.initial_rows = 42
config.window_background_opacity = 0.9
config.macos_window_background_blur = 6

-- disable title bar. 更美观的极简风
config.window_decorations = "RESIZE|INTEGRATED_BUTTONS"

-- config.use_fancy_tab_bar = true
-- config.show_new_tab_button_in_tab_bar = true
config.enable_scroll_bar = true
config.min_scroll_bar_height = "2cell"

-- The color scheme you want to use
-- Color scheme: Dark+, Hardcore, Catppuccin Mocha, Galaxy
local scheme = 'Dark+'

config.color_scheme = scheme

-- Obtain the definition of that color scheme
local scheme_def = wezterm.color.get_builtin_schemes()[scheme]

config.colors = {
  -- Since: 20220319-142410-0fcdea07
  -- When the IME, a dead key or a leader key are being processed and are effectively
  -- holding input pending the result of input composition, change the cursor
  -- to this color to give a visual cue about the compose state.
  compose_cursor = 'orange',
  -- The color of the scrollbar "thumb"; the portion that represents the current viewport
  scrollbar_thumb = scheme_def.foreground,
  -- The color of the split lines between panes
  split = '#666666',
  tab_bar = {
    active_tab = {
      -- bg_color = scheme_def.background,
      -- fg_color = scheme_def.foreground,
      bg_color = '#ffffff',
      fg_color = '#000000',
    },
    -- The color of the inactive tab bar edge/divider
    inactive_tab_edge = '#575757',
  },
}

-- Native (Fancy) Tab Bar appearance
config.window_frame = {
  -- The size of the font in the tab bar.
  -- Default to 10.0 on Windows but 12.0 on other systems
  font_size = 12.5,

  -- The overall background color of the tab bar when
  -- the window is focused
  active_titlebar_bg = '#333333',
}

-- Fonts
-- config.font_size = 12
config.font = wezterm.font_with_fallback {
  'SauceCodePro Nerd Font',
  'NotoSans Nerd Font',
  'JetBrains Mono',
  'Heiti SC',
  'Hack Nerd Font',
}

config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.6,
}

-- hotkey
-- SUPER, CMD, WIN - these are all equivalent:
--   on macOS the Command key (⌘),
--   on Windows the Windows key,
--   on Linux this can also be the Super or Hyper key.
-- ALT, OPT, META - these are all equivalent:
--   on macOS the Option key (⌥),
--   on other systems the Alt or Meta key.
config.keys = {
  -- Configure the same hotkeys as in iTerm2
  -- ⌘+k, ⌘+⇧+k clean scrollback
  { key = 'k', mods = 'CMD', action = wezterm.action.ClearScrollback 'ScrollbackAndViewport' },
  { key = 'K', mods = 'CMD|SHIFT', action = wezterm.action.ClearScrollback 'ScrollbackOnly' },
  -- ⌘+w clone current pane
  { key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentPane { confirm = true }},
  -- ⌘+d, ⌘+⇧+d split pane
  { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }},
  { key = 'D', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }},
  -- ⌘+⌃+f toggle fullscreen
  { key = 'f', mods = 'CMD|CTRL', action = wezterm.action.ToggleFullScreen },
  -- ⌘+[Home]/[End] scroll to top/bottom
  { key = 'Home', mods = 'CMD|CTRL', action = wezterm.action.ScrollToTop },
  { key = 'End', mods = 'CMD|CTRL', action = wezterm.action.ScrollToBottom },
  -- ^+w 搜索模式快速删除搜索词
  { key = 'Backspace', mods = 'ALT', action = wezterm.action.CopyMode 'ClearPattern' },
  -- End of iTerm2 keys map
  -- ^+⇧+h
  { key = 'H', mods = 'CTRL|SHIFT', action = wezterm.action.Search { Regex = '\\b[a-f0-9]{6,}\\b' }},
}

config.mouse_bindings = {
  -- like iTerm2: 禁用单击打开链接，使用 CTRL+Click 打开
  -- Disable the default click behavior
  {
    event = { Up = { streak = 1, button = "Left"} },
    mods = "NONE",
    action = wezterm.action.DisableDefaultAssignment,
  },
  -- Bind 'Up' event of CTRL-Click to open hyperlinks
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
  -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = wezterm.action.Nop,
  },
}

-- and finally, return the configuration to wezterm
return config
