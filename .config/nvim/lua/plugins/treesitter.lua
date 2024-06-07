return
{
    'nvim-treesitter/nvim-treesitter',
    version = "0.9.2",
    config = function()
        require("nvim-treesitter.install").prefer_git = true,
        require('nvim-treesitter.configs').setup {
            ensure_installed = {"c", "python", "rust", "lua", "vim", "vimdoc", "query" },
            auto_install = false,
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
        }
    end,
    build = ":TSUpdate",
    dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
    },
}
