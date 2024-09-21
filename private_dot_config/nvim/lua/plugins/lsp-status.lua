return
{
    'nvim-lua/lsp-status.nvim',
    config = function()
        local lsp_status = require("lsp-status")
        lsp_status.config({
            current_function = false,
            show_filename = false,
            diagnostics = false,
            update_interval = 100,
            status_symbol = nil,
        })
        lsp_status.register_progress()
    end
}
