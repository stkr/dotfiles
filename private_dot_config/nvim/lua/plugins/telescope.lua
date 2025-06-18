local yank_selection_value = function(prompt_bufnr)
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local utils = require("telescope.utils")
    local selection = action_state.get_selected_entry()
    if selection == nil then
        utils.__warn_no_selection "actions.yank_selection"
        return
    end
    actions.close(prompt_bufnr)
    vim.fn.setreg("*", selection.value)
end

return
{
    'nvim-telescope/telescope.nvim',
    dependencies = {
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
        },
        {
            "nvim-telescope/telescope-live-grep-args.nvim",
        },
        {
            'nvim-telescope/telescope-ui-select.nvim',
        },
    },
    cmd = { "Telescope" },
    module = 'telescope',
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local action_layout = require("telescope.actions.layout")
        local action_state = require("telescope.actions.state")

        telescope.setup {
            defaults = {
                mappings = {
                    i = {
                        ['<C-k>'] = actions.move_selection_previous,
                        ['<C-j>'] = actions.move_selection_next,
                        ['<C-l>'] = actions.cycle_history_next,
                        ['<C-h>'] = actions.cycle_history_prev,
                        ['<C-f>'] = actions.to_fuzzy_refine,
                        ['<M-p>'] = action_layout.toggle_preview
                    },
                    n = {
                        ['<M-p>'] = action_layout.toggle_preview
                    },
                },
                path_display = { 'tail' },
            },
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown {}
                },
                frecency = {
                    show_scores = true,
                    show_unindexed = false,
                    ignore_patterns = { "*.git/*", "*/tmp/*" },
                },
            },
            pickers = {
                buffers = {
                    prompt_prefix = " 󱀲 ",
                    sort_lastused = true,
                },
                fd = {
                    prompt_prefix = " 󱏒 ",
                },
                live_grep = {
                    prompt_prefix = "  > ",
                },
                tags = {
                    prompt_prefix = "  ",
                },
                lsp_document_symbols = {
                    symbol_width = 60,
                },

                -- For git_commits and git_bcommits upon <CR> we yank the commit
                -- hash instead of ckecking out the commit.
                git_bcommits = {
                    mappings = {
                        n = {
                            ["<CR>"] = yank_selection_value
                        },
                        i = {
                            ["<CR>"] = yank_selection_value
                        },
                    },
                },
                git_commits = {
                    mappings = {
                        n = {
                            ["<CR>"] = yank_selection_value
                        },
                        i = {
                            ["<CR>"] = yank_selection_value
                        },
                    },
                },
                quickfixhistory = {
                    mappings = {
                        -- In quickfixhistory use <CR> to reload that particular entry of
                        -- the quickfixhistory. The default seems to be to use
                        -- telecsope (again) to pick from within that particular
                        -- quickfixlist - this seems overkill.
                        i = {
                            ["<CR>"] = function(prompt_buf)
                                local entry = action_state.get_selected_entry()
                                if entry then
                                    actions.close(prompt_buf)
                                    vim.cmd(string.format("%schistory | copen", entry.nr))
                                end
                            end
                        }
                    }
                },
            },
        }

        -- Enable telescope fzf native
        telescope.load_extension('fzf')
        telescope.load_extension('ui-select')
        telescope.load_extension("notify")
        telescope.load_extension("live_grep_args")
    end,
}
