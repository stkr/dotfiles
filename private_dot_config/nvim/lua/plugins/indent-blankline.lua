return
{
    'lukas-reineke/indent-blankline.nvim',
    enabled = true,
    main = "ibl",
    config = function()
        require("ibl").setup({
            indent = {
                char = '┊',
            },
            scope = {
                enabled = false,
            }
        })
    end,
}
