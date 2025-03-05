return
{
    'nvim-treesitter/nvim-treesitter',
    version = "0.9.2",
    config = function()
        require("nvim-treesitter.install").prefer_git = true
        require('nvim-treesitter.configs').setup {
            ensure_installed = { "bash", "c", "c_sharp", "cmake", "cpp", "css", "csv", "devicetree",
                "dockerfile", "dot", "doxygen", "dtd", "fish", "gdscript", "git_config", "git_rebase",
                "gitattributes", "gitcommit", "gitignore", "godot_resource", "gpg", "html", "http",
                "java", "javascript", "json5", "kconfig", "kotlin", "lua", "luap", "make", "markdown",
                "markdown_inline", "matlab", "ninja", "objdump", "pem", "perl", "proto", "python",
                "regex", "rst", "ruby", "rust", "sql", "ssh_config", "toml", "verilog",
                "vim", "vimdoc", "xml", "yaml", },
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
                disable = {
                    -- https://www.reddit.com/r/neovim/comments/1agynre/how_to_make_markdown_list_items_indent_behind_the/
                    "markdown",     -- indentation at bullet points is worse than native neovim indentation
                },
            },
        }
    end,
    build = ":TSUpdate",
    dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
    },
}
