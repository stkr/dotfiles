return {
    name = "run script",
    builder = function()
        local file = vim.fn.expand("%:p")
        local cmd = { file }
        if vim.bo.filetype == "python" then
            cmd = { "python3", file }
        end
        if vim.bo.filetype == "go" then
            cmd = { "go", "run", file }
        end
        return {
            cmd = cmd,
            components = {
                "default",
                "unique",
                -- { "on_output_quickfix", open = true },
                -- "on_result_diagnostics",
                -- "default",
            },
            -- strategy = {
            --     "toggleterm",
            --     direction = "horizontal",
            --     open_on_start = true,
            --     close_on_exit = false,
            --     quit_on_exit = "never",
            --     hidden = false,
            --     on_create = function()
            --         vim.notify("toggleterm opened")
            --     end,
            -- },

        }
    end,
    condition = {
        filetype = { "sh", "python", "go" },
    },
}
