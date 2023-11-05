local utils = require("utils")

-- In this file we keep all the essential/small plugins that require
-- no configuration whatsoever and are pretty much used always.

return {

    { "nvim-lua/plenary.nvim", },

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
