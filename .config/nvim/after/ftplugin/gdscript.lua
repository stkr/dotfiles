vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = false

local function format_file()
    vim.cmd([[ 
        write
        silent ! gdformat % 
    ]])
end

-- buffer = 0 makes it a buffer-local keymap (only applies to current (==0) buffer).
vim.keymap.set('n', '<leader>rf', format_file, { desc = "Format file (gdformat)", buffer = 0 })
