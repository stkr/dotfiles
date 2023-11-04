return
{
    'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
    version = "3.3.7",
    config = function()
        require("ibl").setup({
            indent = {
                char = '┊',
            },
            scope = {
                char = '│',
                highlight = "IblIndent",
            }
            -- whitespace = {
            --     remove_blankline_trail = false,
            -- },
        })
    end,
}
