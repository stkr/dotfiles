return {
    "FabijanZulj/blame.nvim",
    lazy = false,
    config = function()
        local utils = require("utils")
        local palette = require("catppuccin.palettes").get_palette("latte")
        -- remove a few colors:
        palette['base'] = nil
        palette['subtext0'] = nil
        palette['subtext1'] = nil
        palette['surface0'] = nil
        palette['surface1'] = nil
        palette['surface2'] = nil
        palette['crust'] = nil
        palette['mantle'] = nil
        palette['overlay0'] = nil
        palette['overlay1'] = nil
        palette['overlay2'] = nil
        palette['yellow'] = nil
        local colors = utils.values(palette)
        require('blame').setup {
            colors = colors,
        }
    end,
}
