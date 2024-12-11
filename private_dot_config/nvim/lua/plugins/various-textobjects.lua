return
{
    "chrisgrieser/nvim-various-textobjs",
    commit = '069f11ecabd18a170da96ad112498374dda57a31',
    config = function()
        require("various-textobjs").setup({
            forwardLooking = {
                big = 100,
            },
            keymaps = {
                useDefaults = true,
                -- L conflicts with end of buffer
                -- gc conflicts with toggling comment
                -- n conflicts with next search result
                -- q, b conflicts with mini.ai
                disabledDefaults = { "L", "gc", "n", "iq", "ib", "aq", "ab", },
            },
        })
    end,
}
