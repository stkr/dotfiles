return
{
    "gbprod/cutlass.nvim",
    config = function()
        require("cutlass").setup({
            exclude = { "ns", "nS" },
            cut_key = "x",
        })
    end,
}
