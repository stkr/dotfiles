return
{
    'nvim-mini/mini.nvim',
    config = function()
        require("mini.basics").setup({
            mappings = {
                option_toggle_prefix = [[,t]]
            },
        })
        require("mini.surround").setup({
            mappings = {
                add = 'Sa',            -- Add surrounding in Normal and Visual modes
                delete = 'Sd',         -- Delete surrounding
                find = 'Sf',           -- Find surrounding (to the right)
                find_left = 'SF',      -- Find surrounding (to the left)
                highlight = 'Sh',      -- Highlight surrounding
                replace = 'Sr',        -- Replace surrounding
                update_n_lines = 'Sn', -- Update `n_lines`
                suffix_last = 'l',     -- Suffix to search with "prev" method
                suffix_next = 'n',     -- Suffix to search with "next" method
            },
        })
        require("mini.cursorword").setup({})
        require("mini.align").setup({})
        require("mini.ai").setup({
            search_method = "cover",
            mappings = {
                -- This is a bit clumsy way to disable those by assigning them
                -- a crazy unused binding.
                around_last = 'a#',
                inside_last = 'i#',
            },
            custom_textobjects = {
                l = function()
                    local current_line_nr = vim.api.nvim_win_get_cursor(0)[1]
                    local from = { line = current_line_nr, col = 1, }
                    local to = {
                        line = current_line_nr,
                        col = math.max(vim.fn.col('$') - 1, 1),
                    }
                    return { from = from, to = to, }
                end,
            },
        })
        require("mini.bracketed").setup({})
        require("mini.sessions").setup({
            autoread = false,
            file = ".session.vim",
        })
        require("mini.icons").setup({})
        require("mini.operators").setup({})
    end
}
