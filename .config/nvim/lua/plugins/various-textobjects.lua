return
{
    "chrisgrieser/nvim-various-textobjs",
    config = function()
        require("various-textobjs").setup({
            lookForwardBig = 100,
            useDefaultKeymaps = true,
            -- L conflicts with end of buffer
            -- gc conflicts with toggling comment
            -- n conflicts with next search result
            -- q, b conflicts with mini.ai
            disabledKeymaps = { "L", "gc", "n", "iq", "ib", "aq", "ab", },
        })
    end,
}
