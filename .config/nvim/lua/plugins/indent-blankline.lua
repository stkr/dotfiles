return
{
    'lukas-reineke/indent-blankline.nvim',
    enabled = true,
    main = "ibl",
    version = "3.7.1",
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
