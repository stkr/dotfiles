return
{
    -- Improved word navigation
    "chrisgrieser/nvim-spider",
    keys = {
        -- **Note** Note that for dot-repeat to work properly, you have to call this
        --   plugin’s motions as Ex-command. Calling `function()
        --   require("spider").motion("w") end` as third argument of the keymap do _not_
        --   support dot-repeatability.
        { "w",  "<cmd>lua require('spider').motion('w')<CR>",  mode = { "n", "o", "x" }, desc = "Spider-w" },
        { "e",  "<cmd>lua require('spider').motion('e')<CR>",  mode = { "n", "o", "x" }, desc = "Spider-e" },
        { "b",  "<cmd>lua require('spider').motion('b')<CR>",  mode = { "n", "o", "x" }, desc = "Spider-b" },
        { "ge", "<cmd>lua require('spider').motion('ge')<CR>", mode = { "n", "o", "x" }, desc = "Spider-ge" },
    },
}
