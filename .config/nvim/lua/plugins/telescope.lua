return
{
    'nvim-telescope/telescope.nvim',
    version = "0.1.8",
    dependencies = {
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
        },
        {
            "nvim-telescope/telescope-live-grep-args.nvim",
            version = "^1.0.0",
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
        local trouble = require("trouble")

        telescope.setup {
            defaults = {
                mappings = {
                    i = {
                        ['<C-k>'] = actions.move_selection_previous,
                        ['<C-j>'] = actions.move_selection_next,
                        ['<C-l>'] = actions.cycle_history_next,
                        ['<C-h>'] = actions.cycle_history_prev,
                        ['<M-p>'] = action_layout.toggle_preview,
                        ['<C-q>'] = function(prompt_bufnr) 
                                actions.send_to_qflist(prompt_bufnr)
                                trouble.open('quickfix')
                            end,
                        ['<C-f>'] = actions.to_fuzzy_refine,
                    },
                    n = {
                        ['<M-p>'] = action_layout.toggle_preview,
                        ['<C-q>'] = function(prompt_bufnr) 
                                actions.send_to_qflist(prompt_bufnr) 
                                trouble.open('quickfix')
                            end,
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
                    prompt_prefix = " ﬘ > ",
                    sort_lastused = true,
                },
                fd = {
                    prompt_prefix = "  > ",
                },
                live_grep = {
                    prompt_prefix = "  > ",
                },
                tags = {
                    prompt_prefix = " 笠> ",
                },
                lsp_document_symbols = {
                    symbol_width = 60,
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
                                    vim.cmd(string.format("%schistory", entry.nr))
                                    trouble.open('quickfix')
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
