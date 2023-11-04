return {

    -- other evaluated colorschemes:
    --     2023-06: Iron-E/nvim-highlite: telescope background is nasty, searh and replace is not nice
    --     2023-06: olimorris/onedarkpro.nvim: Diffview is not supported
    --     2023-06: catppuccin/nvim: This is working fine, too "serile" for my taste in the light (latte) variant
    --     2023-06: neanias/everforest-nvim: Very nice theme, the differentiation in statusline between modes is not visible enough
    {
        -- 'Iron-E/nvim-soluarized'
        'stkr/nvim-soluarized',
        lazy = false,
        priority = math.huge, -- make sure to load this before all the other start plugins
        config = function()
            vim.o.termguicolors = true
            vim.o.background = 'light'
            vim.api.nvim_command 'colorscheme soluarized'
        end,
    },
}
