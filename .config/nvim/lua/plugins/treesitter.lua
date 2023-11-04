return
{
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
        { 'nvim-treesitter/nvim-treesitter-textobjects' },
    },
    config = function()
        -- Treesitter configuration
        -- Parsers must be installed manually via :TSInstall
        require('nvim-treesitter.configs').setup {
            highlight = {
                enable = true,
                disable = function(lang, buf)
                    local max_filesize = 500 * 1024
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        return true
                    end
                end,
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = nil,
                    node_incremental = nil,
                    scope_incremental = 'ga',
                    node_decremental = nil,
                },
            },
            indent = {
                enable = true,
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,     -- Automatically jump forward to textobj, similar to targets.vim
                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ['af'] = '@function.outer',
                        ['if'] = '@function.inner',
                        ['ac'] = '@class.outer',
                        ['ic'] = '@class.inner',
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,     -- whether to set jumps in the jumplist
                    goto_next_start = {
                        [']m'] = '@function.outer',
                        [']]'] = '@class.outer',
                    },
                    goto_next_end = {
                        [']M'] = '@function.outer',
                        [']['] = '@class.outer',
                    },
                    goto_previous_start = {
                        ['[m'] = '@function.outer',
                        ['[['] = '@class.outer',
                    },
                    goto_previous_end = {
                        ['[M'] = '@function.outer',
                        ['[]'] = '@class.outer',
                    },
                },
            },
        }
    end
}
