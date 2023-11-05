return
{
    "MunifTanjim/rust-tools.nvim",
    dependencies = "neovim/nvim-lspconfig",
    ft = "rust",
    keys = {
        { '<F8>',  function() require("rust-tools").runnables.runnables() end,     desc = "run executable or test", },
        { '<F20>', function() require("rust-tools").debuggables.debuggables() end, desc = "debug executable or test", }, -- <S-F8>
    },
    config = function()
        local utils = require("utils")
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
    end,
}
