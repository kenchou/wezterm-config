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
    if length < min_width then
        local pad = (min_width - length) // 2
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
  local process_name = tab.active_pane.foreground_process_name:match("([^/\\]+)%.exe$") or
      tab.active_pane.foreground_process_name:match("([^/\\]+)$")
  process_name = process_name:match("(python)[%d%.]*$") or process_name
  -- print(process_name .. ' <-- ' .. tab.active_pane.foreground_process_name)
  -- local icon = process_icons[process_name] or string.format('[%s]', process_name)
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


-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.initial_cols = 140
config.initial_rows = 42
config.window_background_opacity = 0.9

-- Color scheme:
config.color_scheme = 'Dark+'

-- Fonts
-- config.font_size = 12
config.font = wezterm.font_with_fallback {
  'SauceCodePro Nerd Font',
  'JetBrains Mono',
  'Hack Nerd Font',
}

-- config.use_fancy_tab_bar = true
-- config.show_new_tab_button_in_tab_bar = true

-- hotkey
config.keys = {
  -- ⌘+k, ⇧+⌘+k same as iTerm2
  {key = 'k', mods = 'SUPER', action = wezterm.action{ClearScrollback="ScrollbackAndViewport"},},
  {key = 'K', mods = 'SUPER', action = wezterm.action{ClearScrollback="ScrollbackOnly"},},
}


-- and finally, return the configuration to wezterm
return config
