return
{
    'stevearc/conform.nvim',
    -- lazy = true,
    opts = {
        -- log_level = vim.log.levels.DEBUG,
        formatters_by_ft = {
            -- Use the "*" filetype to run formatters on all filetypes.
            ["*"] = { "trim_whitespace", "trim_newlines" },
            -- Use the "_" filetype to run formatters on filetypes that don't
            -- have other formatters configured.
            ["_"] = {  },
        },
        default_format_opts = {
            lsp_format = "fallback",
        },
        format_on_save = {
            -- I recommend these options. See :help conform.format for details.
            lsp_format = "fallback",
            timeout_ms = 500,
        },
    },
}
