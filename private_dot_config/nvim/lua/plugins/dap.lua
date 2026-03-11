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
                    "--command=/home/nxp29037/projects/s1xy/debug/.gdbinit.bak",
            }
        }
        dap.adapters.cppdbg = {

          id = 'cppdbg',
          type = 'executable',
          command = '/home/nxp29037/.vscode/extensions/ms-vscode.cpptools-1.30.5-linux-x64/debugAdapters/bin/OpenDebugAD7',
        }

        local utils = require("utils")
        utils.safe_require("dapui")
    end
}
