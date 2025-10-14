return
{
    'stevearc/conform.nvim',
    config = function()
        local opts = {
            -- log_level = vim.log.levels.DEBUG,
            formatters_by_ft = {
                -- Use the "*" filetype to run formatters on all filetypes.
                ["*"] = { "trim_whitespace", "trim_newlines" },
                -- Use the "_" filetype to run formatters on filetypes that don't
                -- have other formatters configured.
                ["_"] = {},
                ['json'] = { "jq" },
                ['bash'] = { "shfmt" },
                ['sh'] = { "shfmt" },
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
            format_on_save = function(bufnr)
                -- Disable with a global or buffer-local variable
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end
                return { timeout_ms = 500, lsp_format = "fallback" }
            end,
        }
        require("conform").setup(opts)
    end
}
