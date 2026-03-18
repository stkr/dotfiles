return
{
    "mfussenegger/nvim-dap",
    lazy = true,
    config = function()
        local dap = require("dap")

        dap.adapters.gdb = {
            type = "executable",
            command = "gdb",
            args = { "--quiet",
                "--interpreter=dap",
                "--command=/home/nxp29037/projects/s1xy/acme-gen3/s1xy/.gdbinit",
            }
        }
        dap.adapters.cppdbg = {

            id = 'cppdbg',
            type = 'executable',
            command =
            '/home/nxp29037/.vscode/extensions/ms-vscode.cpptools-1.31.2-linux-x64/debugAdapters/bin/OpenDebugAD7',
        }

        -- disable vscodes launch.json parsing
        dap.providers.configs["dap.launch.json"] = nil

        -- They all only apply in normal mode!
        local dap_keymaps = {
            ["<leader>tb"] = { func = dap.toggle_breakpoint, dict = { desc = "Toggle breakpoint" } },
            ["<F5>"] = { func = dap.continue, dict = { desc = "Continue debugging" } },
            ["<F10>"] = { func = dap.step_over, dict = { desc = "Step over" } },
            ["<F11>"] = { func = dap.step_into, dict = { desc = "Step into" } },
            ["<F12>"] = { func = dap.step_out, dict = { desc = "Step out" } },
        }
        local original_maps_n = {}
        dap.listeners.after.event_initialized['me.dap.keys'] = function()
            vim.notify("Enabled debugger keymaps")
            for key, value in pairs(dap_keymaps) do
                original_maps_n[key] = vim.fn.maparg(key, "n", false, true)
                vim.keymap.set("n", key, value.func, value.dict)
            end
        end
        local reset_keys = function()
            vim.notify("Disabled debugger keymaps")
            for _, value in pairs(original_maps_n) do
                -- this checks for a non-empyt table and only attempts to mapset in that case
                if next(value) ~= nil then
                    vim.fn.mapset(value)
                end
            end
        end
        dap.listeners.before.event_terminated['me.dap.keys'] = reset_keys
        dap.listeners.before.terminate['me.dap.keys'] = reset_keys

        local utils = require("utils")
        utils.safe_require("dapui")
    end
}
