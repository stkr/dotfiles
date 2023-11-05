return
{
        'echasnovski/mini.nvim',
        version = "0.10.0",
        config = function()
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
            require("mini.ai").setup({ search_method = "cover" })
            require("mini.bracketed").setup({})
            require("mini.sessions").setup({
                autoread = true,
                file = ".session.vim",
            })
        end
    }