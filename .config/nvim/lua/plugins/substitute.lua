return
{
    "gbprod/substitute.nvim",
    enabled = true,
    opts = {
        -- would be nice, but is buggy for dotrepeat (always jumps back to the first replacement)
        preserve_cursor_position = false,
    },
    keys = {
        { "gr", function() require('substitute').operator() end, mode = "n", noremap = true },
        { "gr", function() require('substitute').visual() end,   mode = "x", noremap = true },
    },
}
