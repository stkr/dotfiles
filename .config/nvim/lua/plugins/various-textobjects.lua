return
{
    "chrisgrieser/nvim-various-textobjs",
    config = function()
        require("various-textobjs").setup({
            lookForwardBig = 100,
            useDefaultKeymaps = true,
            -- L conflicts with end of buffer
            -- gc conflicts with toggling comment
            disabledKeymaps = { "L", "gc", },
        })
    end,
}
