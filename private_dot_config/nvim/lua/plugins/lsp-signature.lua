return
{
    'ray-x/lsp_signature.nvim',
    enabled = true,
    config = function()
        require('lsp_signature').setup({
            hint_prefix = "",
        })
    end,
}
