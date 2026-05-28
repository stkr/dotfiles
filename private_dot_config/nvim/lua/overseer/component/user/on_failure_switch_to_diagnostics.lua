local overseer = require("overseer")
local constants = require("overseer.constants")
local STATUS = constants.STATUS

---@type overseer.ComponentFileDefinition
return {
    desc = "Close the overseer window and display quickfix with diagnostics instead.",
    params = {},
    constructor = function(_)
        return {
            on_complete = function(_, task, status, _)
                if status == STATUS.FAILURE then
                    overseer.close()
                    overseer.run_action(task, 'set quickfix diagnostics')
                    -- open quickfix, but keep focus in current window.
                    local win = vim.api.nvim_get_current_win()
                    vim.cmd("copen")
                    vim.api.nvim_set_current_win(win)
                end
            end,
        }
    end,
}
