return
{
    'ray-x/lsp_signature.nvim',
    version = "0.3.1",
    config = function()
        require('lsp_signature').setup({
            hint_prefix = "",
        })
    end,
}
