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
            disabledKeymaps = { "L", "gc", "n", },
        })
    end,
}
