local map = require("core.utils").map

-- The function is called `t` for `termcodes`.
-- You don't have to call it that, but I find the terseness convenient
local function t(str)
    -- Adjust boolean arguments as needed
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- wildmenu navigation
-- I have no f** ing idea how to do that with nvchad's map()
vim.api.nvim_set_keymap("c", "<c-j>", "<c-n>", { expr = false, noremap = true })
vim.api.nvim_set_keymap("c", "<c-k>", "<c-p>", { expr = false, noremap = true })


