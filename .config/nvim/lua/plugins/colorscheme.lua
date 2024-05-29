return {

    -- other evaluated colorschemes:
    --     2024-06: Iron-E/nvim-soluarized: broken with nvim 0.10.0
    --     2023-06: Iron-E/nvim-highlite: telescope background is nasty, search and replace is not nice
    --     2023-06: olimorris/onedarkpro.nvim: Diffview is not supported
    --     2023-06: catppuccin/nvim: This is working fine, too "sterile" for my taste in the light (latte) variant
    --     2023-06: neanias/everforest-nvim: Very nice theme, the differentiation in statusline between modes is not visible enough
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = math.huge, -- make sure to load this before all the other start plugins
        config = function()
            require("catppuccin").setup({
                integrations = {
                    diffview = true,
                    notify = true,
                    telekasten = true,
                    lsp_trouble = true,
                    which_key = true,
                },
            })
            vim.o.termguicolors = true
            vim.api.nvim_command 'colorscheme catppuccin'
            vim.o.background = 'light'
        end,
    },
}
