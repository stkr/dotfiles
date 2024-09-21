local utils = require("utils")

return {
  desc = "Open output in terminal split window",
  constructor = function(params)
    return {
      bufnr = nil,
      on_start = function(self, task)
        self.bufnr = task:get_bufnr()

        local original_win = vim.api.nvim_get_current_win()
        local target_win = utils.get_default_terminal_window()

        vim.api.nvim_win_set_buf(target_win, self.bufnr)
        require("overseer.util").scroll_to_end(target_win)

        -- Move the cursor back to the original window.
        vim.api.nvim_set_current_win(original_win)
      end,
      on_exit = function(self, _, code)
        -- local close = params.close_on_exit == "always"
        -- close = close or (params.close_on_exit == "success" and code == 0)
        -- if close then
        --   oui.close_window(self.bufnr)
        -- end
      end,
      on_reset = function(self)
        -- oui.close_window(self.bufnr)
      end,
    }
  end,
}
