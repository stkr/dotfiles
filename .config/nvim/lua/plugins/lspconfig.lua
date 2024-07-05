return
{
    'neovim/nvim-lspconfig',
    version = "0.1.8",
    dependencies = {
        'nvim-lua/lsp-status.nvim',
        'ray-x/lsp_signature.nvim',
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
    },
    config = function()
        local lspconfig = require("lspconfig")
        local lsp_utils = require("lsp_utils")

        -- ##################### generic server configuration ################
        --
        local servers = { 'tsserver', 'gdscript' }
        for _, lsp in ipairs(servers) do
            lspconfig[lsp].setup {
                on_attach = lsp_utils.on_attach,
                capabilities = lsp_utils.get_capabilities(),
            }
        end


        -- ##################### clangd ################
        --
        -- Clangd inserts a space or a dot in front of a completed item indicating wheter it
        -- would result in an included header or not. This messes up formatting and deduplication
        -- of the code completion. Therefore, we need to disable that behaviour via command-line
        -- option.
        lspconfig["clangd"].setup {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.get_capabilities(),
            cmd = {
                "clangd",
                "--header-insertion-decorators=false",
            }
        }


        -- ##################### pylsp ################
        --
        -- The idea is to have the language server installed in the same virtual
        -- environment as the proect itself. The venv is activated before nvim
        -- is launched from that shell.
        -- This allows to access the language servers as well as to run python
        -- code from within nvim with the same environment.
        lspconfig.pylsp.setup {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.get_capabilities(),
            settings = {
                pylsp = {
                    configurationSources = { "black" },
                    plugins = {
                        -- default code style linter disabled in favor of black.
                        pycodestyle = {
                            enabled = false,
                        },
                        -- code actions:
                        rope_autoimport = {
                            enabled = true,
                        },
                        -- reformatting:
                        black = {
                            enabled = true,
                            line_length = 100,
                            preview = true,
                        },
                        flake8 = {
                            enabled = true,
                        },
                    }
                }
            }
        }

        -- ##################### lua_ls ################
        --
        -- Example custom server
        -- Make runtime files discoverable to the server
        local runtime_path = vim.split(package.path, ';')
        table.insert(runtime_path, 'lua/?.lua')
        table.insert(runtime_path, 'lua/?/init.lua')

        lspconfig.lua_ls.setup({
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities,
            settings = {
                Lua = {
                    runtime = {
                        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                        version = 'LuaJIT',
                        -- Setup your lua path
                        path = runtime_path,
                    },
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = { 'vim' },
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files
                        library = vim.api.nvim_get_runtime_file('', true),
                        checkThirdParty = false,
                    },
                    -- Do not send telemetry data containing a randomized but unique identifier
                    telemetry = {
                        enable = false,
                    },
                },
            },
        })
    end,
}
