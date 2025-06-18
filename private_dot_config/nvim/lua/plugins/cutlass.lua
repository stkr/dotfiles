return
{
    "gbprod/cutlass.nvim",
    config = function()
        require("cutlass").setup({
            -- ns = jump/search
            -- nS = surround
            -- s, = which-key
            exclude = { "ns", "nS", "s," },
            cut_key = "x",
        })
    end,
}
