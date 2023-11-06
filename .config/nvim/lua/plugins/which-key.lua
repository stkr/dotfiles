return
{
    'folke/which-key.nvim',
    keys = { "<leader>", nil, { "n", "v" }, desc = "Open which-key" },
    opts = {
        -- We define a bunc of groups/categories here which can/should be filled with keymaps.
        groups = {
            mode = { "n", "v" },
            ["<leader>c"] = { name = "context" },
            ["<leader>cf"] = { name = "file" },
            ["<leader>d"] = { name = "diff" },
            ["<leader>e"] = { name = "edit/open" },
            ["<leader>en"] = { name = "notes" },
            ["<leader>enn"] = { name = "new" },
            ["<leader>f"] = { name = "find" },
            ["<leader>fn"] = { name = "notes" },
            ["<leader>g"] = { name = "goto" },
            ["<leader>l"] = { name = "launch" },
            ["<leader>n"] = { name = "navigate" },
            ["<leader>r"] = { name = "refactor" },
            ["<leader>s"] = { name = "subst" },
            ["<leader>ss"] = { name = "slashes" },
            ["<leader>sh"] = { name = "hex" },
            ["<leader>sw"] = { name = "whitespace" },
            ["<leader>t"] = { name = "toggle" },
            ["<leader>y"] = { name = "yank" },
            ["<leader>yf"] = { name = "file" },
        },
    },
    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)
        wk.register(opts.groups)
    end,
}
