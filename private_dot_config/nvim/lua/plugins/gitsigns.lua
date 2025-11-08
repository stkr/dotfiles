return {
    "lewis6991/gitsigns.nvim",
    config = function()
        local gs = require('gitsigns')
        local utils = require("utils")
        gs.setup({
            on_attach = function(bufnr)
                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map('n', ']c', function()
                    if vim.wo.diff then return ']c' end
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                end, { expr = true })

                map('n', '[c', function()
                    if vim.wo.diff then return '[c' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                end, { expr = true })

                -- Actions
                map('n', '<leader>dn', utils.dotrepeat_create_func(
                    function()
                        gs.next_hunk({ preview = true })
                    end), { desc = "Go to next git diff hunk" })

                map('n', '<leader>dN', utils.dotrepeat_create_func(
                    function()
                        gs.prev_hunk({ preview = true })
                    end), { desc = "Go to previous git diff hunk" })

                map('n', '<leader>ds', utils.dotrepeat_create_func(
                    function()
                        gs.stage_hunk()
                        gs.next_hunk({ preview = true })
                    end), { desc = "Go to next git diff hunk" })

                map('v', '<leader>ds', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
                map('v', '<leader>dr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
                map('n', '<leader>dp', gs.preview_hunk)

                -- Text object
                map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
            end
        })
    end,
}
