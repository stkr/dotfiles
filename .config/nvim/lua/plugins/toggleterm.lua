return
{
    "akinsho/toggleterm.nvim",
    enabled = true,
    opts = {},

    -- In order to configure a command to run in a toggleable terminal, define
    -- a terminal + a keymap like so:

    -- local Terminal = require("toggleterm.terminal").Terminal
    -- local build_term = Terminal:new({
    --     cmd = "./b -RS943 -ra1 -m-j8",
    --     display_name = "build",
    --     start_in_insert = false,
    --     close_on_exit = false,
    --     auto_scroll = true,
    --     count = 5,
    -- })
    --
    -- vim.keymap.set('n', '<leader>t5', function() build_term:toggle() end, {desc = "Build..."})
}
