local wezterm = require 'wezterm'

-- It seems not to be easy to access the wezterm lua debug console
-- from here, so instead we print debug output to a file...
-- local first_log = true
-- local function config_log(msg)
--     local mode
--     if first_log then mode = "w" else mode = "a" end
--     first_log = false
--     local debug_file = io.open("/home/stefan/.tmp/wezterm.config.log", mode)
--     debug_file:write(msg)
--     debug_file:write("\n")
--     io.close(debug_file)
-- end
-- local function config_log(msg) end

-- In order to easily disinguish multiple open consoles, we do color the tab-bar, based 
-- on either an instance number (e.g., 1st console gets blue tabbar, second one green, etc.)
-- or on a particular highlight identifier. 
-- Both can be passed via environment variable WEZTERM_INSTANCE - the env var will 
-- index into the table given below.
local tab_bar_colors = {
    yellow = {
        background = '#b58900',
        active_tab = { bg_color = '#eee8d5', fg_color = '#586e75' },
        inactive_tab = { bg_color = '#b58900', fg_color = '#586e75' },
    },
    orange = {
        background = '#cb4b16',
        active_tab = { bg_color = '#eee8d5', fg_color = '#586e75' },
        inactive_tab = { bg_color = '#cb4b16', fg_color = '#586e75' },
    },
    red = {
        background = '#dc322f',
        active_tab = { bg_color = '#eee8d5', fg_color = '#586e75' },
        inactive_tab = { bg_color = '#dc322f', fg_color = '#586e75' },
    },
    magenta = {
        background = '#d33682',
        active_tab = { bg_color = '#eee8d5', fg_color = '#586e75' },
        inactive_tab = { bg_color = '#d33682', fg_color = '#586e75' },
    },
    violet = {
        background = '#d33682',
        active_tab = { bg_color = '#eee8d5', fg_color = '#586e75' },
        inactive_tab = { bg_color = '#d33682', fg_color = '#586e75' },
    },
    blue = {
        background = '#268bd2',
        active_tab = { bg_color = '#eee8d5', fg_color = '#586e75' },
        inactive_tab = { bg_color = '#268bd2', fg_color = '#586e75' },
    },
    cyan = {
        background = '#2aa198',
        active_tab = { bg_color = '#eee8d5', fg_color = '#586e75' },
        inactive_tab = { bg_color = '#2aa198', fg_color = '#586e75' },
    },
    green = {
        background = '#859900',
        active_tab = { bg_color = '#eee8d5', fg_color = '#586e75' },
        inactive_tab = { bg_color = '#859900', fg_color = '#586e75' },
    },
    default = {
        background = '#93a1a1',
        active_tab = { bg_color = '#eee8d5', fg_color = '#586e75' },
        inactive_tab = { bg_color = '#93a1a1', fg_color = '#586e75' },
    }
}

local instance_to_highlight = {
    [0] = 'yellow',
    [1] = 'orange',
    [2] = 'red',
    [3] = 'magenta',
    [4] = 'violet',
    [5] = 'blue',
    [6] = 'cyan',
    [7] = 'green',
}

local colorscheme = wezterm.color.get_builtin_schemes()['Solarized (light) (terminal.sexy)']

local highlight = os.getenv("WEZTERM_HIGHLIGHT")
if not highlight then
    local instance = tonumber(os.getenv("WEZTERM_INSTANCE"))
    if instance then
        highlight = instance_to_highlight[instance]
    else
        highlight = 'default'
    end
end

local selected_tab_bar_colors = tab_bar_colors[highlight]
if selected_tab_bar_colors then
    colorscheme['tab_bar'] = selected_tab_bar_colors
end

return {
    font = wezterm.font 'JetBrainsMono Nerd Font',
    font_size = 11.0,
    harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
    tab_bar_at_bottom = true,
    use_fancy_tab_bar = false,
    colors = colorscheme,
    window_padding = {
        left = '0px',
        right = '0px',
        top = '0px',
        bottom = '0px',
    },
}
