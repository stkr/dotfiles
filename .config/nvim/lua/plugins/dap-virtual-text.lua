return
{
    "theHamsta/nvim-dap-virtual-text",
    lazy = true,
    config = function()
        require("nvim-dap-virtual-text").setup({ virt_text_win_col = 80 })
    end,
}
