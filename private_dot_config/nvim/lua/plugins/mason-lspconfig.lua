return {
    'williamboman/mason-lspconfig.nvim',
    enabled = false,
    config = function()
        require("mason-lspconfig").setup({
            automatic_enable = {
                exclude = { "clangd", },
            },
        })
    end,
}
