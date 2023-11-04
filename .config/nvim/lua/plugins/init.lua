local utils = require("utils")

-- In this file we keep all the essential/small plugins that require 
-- no configuration whatsoever and are pretty much used always.

return {

    { "nvim-lua/plenary.nvim", },


    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
            "sindrets/diffview.nvim",
        },
        config = true
    },

    {
        'folke/which-key.nvim',
        config = function() require("config.which-key").config() end,
    },
    {
        "svart",
        url = 'https://gitlab.com/madyanov/svart.nvim',
        config = function()
            require("svart").configure({
                label_atoms = "asdghklqwertyuiopzxcvbnmfj",
                search_update_register = false,
            })
        end,
        cmd = { "Svart" },
    },

    {
        "ethanholz/nvim-lastplace",
        opts = {
            lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
            lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
            lastplace_open_folds = true
        }
    },

    {
        "gbprod/cutlass.nvim",
        config = function()
            require("cutlass").setup({
                exclude = { "ns", "nS" },
                cut_key = "x",
            })
        end,
    },

    { "vim-scripts/ReplaceWithRegister", },

    {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    },

    {
        "gbprod/stay-in-place.nvim",
        config = function()
            require("stay-in-place").setup()
        end
    },

    { 'tpope/vim-abolish', },
    { 'tpope/vim-obsession', },

    {
        'RaafatTurki/hex.nvim',
        config = function()
            require("hex").setup()
        end,
        cmd = { "HexDump", "HexToggle", "HexAssemble", },

    },

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
                        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
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
                        set_jumps = true, -- whether to set jumps in the jumplist
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
    },

    {
        'neovim/nvim-lspconfig',
        dependencies = {
            {
                'nvim-lua/lsp-status.nvim',
                config = function()
                    local lsp_status = require("lsp-status")
                    lsp_status.config({
                        current_function = false,
                        show_filename = false,
                        diagnostics = false,
                        update_interval = 100,
                        status_symbol = nil,
                    })
                    lsp_status.register_progress()
                end
            },
            {
                'ray-x/lsp_signature.nvim',
            },

        },
    },


    -- autocompletion
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {

            {
                "L3MON4D3/LuaSnip",
                dependencies = { { "rafamadriz/friendly-snippets", }, },
            },

            { "saadparwaiz1/cmp_luasnip", },
            { "hrsh7th/cmp-nvim-lsp", },
            { "hrsh7th/cmp-buffer", },
            { "hrsh7th/cmp-path", },
        },
        config = function() require("config.nvim-cmp").config() end,
    },

    {
        "ray-x/lsp_signature.nvim",
        event = "VeryLazy",
        opts = { hint_prefix = "", },
        config = function(_, opts) require 'lsp_signature'.setup(opts) end
    },

    {
        'nvim-telescope/telescope.nvim',
        cmd = { "Telescope" },
        module = 'telescope',
        config = function() require("config.telescope").config() end,
        dependencies = {
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = function()
                    local build_cmd =
                        "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && " ..
                        "cmake --build build --config Release && " ..
                        "cmake --install build --prefix build"
                    os.execute(build_cmd)
                end,
            },
            {
                "nvim-telescope/telescope-frecency.nvim",
                dependencies = { { "kkharji/sqlite.lua" }, }
            },
            {
                'nvim-telescope/telescope-ui-select.nvim',
            },
        },
    },

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
    },

    {
        "chrisgrieser/nvim-various-textobjs",
        config = function()
            require("various-textobjs").setup({ useDefaultKeymaps = true })
        end,
    },

    {
        "chrisgrieser/nvim-spider",
        lazy = true
    },

    {
        'andrewferrier/debugprint.nvim',
        config = function() require("debugprint").setup() end,
    },

    {
        "renerocksai/telekasten.nvim",
        cmd = { "Telekasten", },
        module = { "telekasten", },
        config = function() require("config.telekasten").config() end,
    },

    {
        'sindrets/diffview.nvim',
        dependencies = { "nvim-lua/plenary.nvim", },
        cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose",
            "DiffviewToggleFiles", "DiffviewFocusFiles",
            "DiffviewRefresh", "DiffviewLog",
        },
        config = function() require("config.diffview").config() end,
    },

    {
        'nvim-tree/nvim-tree.lua',
        dependencies = {
            'nvim-tree/nvim-web-devicons', -- optional, for file icons
        },
        cmd = { "NvimTreeOpen", "NvimTreeClose", "NvimTreeToggle", "NvimTreeFocus", "NvimTreeRefresh",
            "NvimTreeFindFile",
            "NvimTreeFindFileToggle", "NvimTreeClipboard", "NvimTreeResize", "NvimTreeCollapse",
            "NvimTreeCollapseKeepBuffers", },
        config = function() require("config.nvim-tree").config() end,
    },

    -- Rust specifics
    -- {
    --     "rust-lang/rust.vim",
    --     ft = "rust",
    --     init = function()
    --     end,
    -- },
    {
        "MunifTanjim/rust-tools.nvim",
        dependencies = "neovim/nvim-lspconfig",
        ft = "rust",
        config = function()
            local lsp_utils = utils.safe_require("lsp_utils")
            if lsp_utils == nil then
                utils.err("Unable to load lsp_utils, lsp support is broken")
                return {}
            end
            local opts = {
                tools = {
                    inlay_hints = {
                        highlight = "InlayHint",
                        max_len_align = true,
                        max_len_align_padding = 4,
                    },
                    hover_actions = {
                        auto_focus = true,
                    },
                },
                server = {
                    on_attach = lsp_utils.on_attach,
                    capabilities = lsp_utils.get_capabilities(),
                },
                -- LLDB (for rust) prints (summary) representations for structs rather
                -- clumsily as the type + the memory location. To get to the struct
                -- fields, one would need to open the struct.
                -- However, LLDB allows changing the representation / format of
                -- variables (see https://lldb.llvm.org/use/variable.html).
                -- This can be (persistently) achieved by including a .lldbinit
                -- file containing statements to change that represenation.
                -- Note that LLDB per default does NOT load the .lldbinit files in
                -- the CWD due to security reasons. LLDB itself would have the
                -- command line switch --local-lldbinit to allow loading local
                -- .lldbinit files. However, since there is lldb-vscode in between
                -- which seems not to be able to supply additional command line
                -- options to LLDB, this approach does not work. However, since it
                -- is LLDB under the hood which finally is running, LLDB
                -- evaluates ~/.lldbinit. So as a workaround, it is possible
                -- to copy the (project specific) LLDB type summaries to ~/.lldbinit.
                -- dap = {
                --     adapter = {
                --         command = "lldb-vscode",
                --         args = { "--local-lldbinit" },
                --     },
                -- },
            }
            local rust_tools = require("rust-tools")
            rust_tools.setup(opts)
            vim.keymap.set('n', '<F8>', rust_tools.runnables.runnables)
            vim.keymap.set('n', '<F20>', rust_tools.debuggables.debuggables) -- <S-F8>
        end,
    },

    {
        "mfussenegger/nvim-dap",
        lazy = true,
        config = function()
            utils.safe_require("dapui")
        end
    },

    {
        "rcarriga/nvim-dap-ui",
        lazy = true,
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            local dap, dapui = require("dap"), require("dapui")

            -- The default output for variables includes
            -- the type name. For rust structs, this is including the canonical name
            -- of the struct (incl. crate name, module names, etc.), leaving no
            -- space in the window to display the actual value.
            -- By using max_type_length = 0, we get rid of the type field
            -- in the variables view entirely (is is of questionable use anyway).
            -- Note that also the dap-virtual-text as well as evaluating a variable
            -- in the repl do not show type information.
            dapui.setup({ render = { max_type_length = 0, }, })

            dap.listeners.after.event_initialized["dapui_config"] = function()
                -- Some filetype specific plugins may have type overlays as virtual text themselves.
                -- Remove those in favor of the virtual text for debugging.
                if vim.bo.filetype == "rust" then
                    local rust_tools = utils.safe_require("rust-tools")
                    if rust_tools then
                        rust_tools.inlay_hints.disable()
                    end
                end
                utils.safe_require("nvim-dap-virtual-text")
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
                local rust_tools = utils.safe_require("rust-tools")
                if rust_tools then
                    rust_tools.inlay_hints.unset()
                end
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
        end,
    },

    {
        "theHamsta/nvim-dap-virtual-text",
        lazy = true,
        config = function()
            require("nvim-dap-virtual-text").setup({ virt_text_win_col = 80 })
        end,
    },
}
