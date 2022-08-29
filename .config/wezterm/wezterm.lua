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

local colorscheme = wezterm.color.get_builtin_schemes()['Solarized (light) (terminal.sexy)']
colorscheme['tab_bar'] = {
    active_tab = { bg_color = colorscheme[''], fg_color = 'green' },
    inactive_tab = { bg_color = 'red', fg_color = 'green' },
}

return {
    font = wezterm.font 'JetBrainsMono Nerd Font',
    font_size = 11.0,
    harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
    tab_bar_at_bottom = true,
    use_fancy_tab_bar = false,
    colors = colorscheme,
}
