return
{
    "stevearc/overseer.nvim",
    version = "1.x",
    config = function()
        require('overseer').setup({
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
            templates = {
                "builtin",
                "user.run_script",
            },
            component_aliases = {
                -- Most tasks are initialized with the default components
                default = {
                    { "display_duration", detail_level = 2 },
                    "user.open_in_terminal_split",
                    "on_output_summarize",
                    "on_exit_set_status",
                },
            },
        })
    end,
}
