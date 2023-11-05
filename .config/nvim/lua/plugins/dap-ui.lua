return
{
    "rcarriga/nvim-dap-ui",
    lazy = true,
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
        local utils = require("utils")
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
}
