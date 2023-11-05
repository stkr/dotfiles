return
{
    "mfussenegger/nvim-dap",
    lazy = true,
    config = function()
        local utils = require("utils")
        utils.safe_require("dapui")
    end
}
