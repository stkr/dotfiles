return
{
    'andrewferrier/debugprint.nvim',
    config = function() require("debugprint").setup() end,
    keys = {
        { "g?p", nil, mode = "n",          desc = "insert a 'plain' debugprint line" },
        { "g?P", nil, mode = "n",          desc = "insert a 'plain' debugprint line above current line" },
        { "g?v", nil, mode = { "n", "v" }, desc = "insert a variable debugprint line" },
        { "g?V", nil, mode = { "n", "v" }, desc = "insert a variable debugprint line above current line" },
        { "g?o", nil, mode = "n",          desc = "insert a variable debugprint line" },
        { "g?O", nil, mode = "n",          desc = "insert a variable debugprint line above current line" },
    },
    cmd = { "DeleteDebugPrints" },
}
