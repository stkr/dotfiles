return
{
    "gbprod/cutlass.nvim",
    enabled = false, -- this plugin breaks which-key in visual mode apparently, need to find out more...
    config = function()
        require("cutlass").setup({
            exclude = { "ns", "nS" },
            cut_key = "x",
        })
    end,
}
