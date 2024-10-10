return
{
    'folke/which-key.nvim',
    version = "3.x",
    opts = {
        presets = {
            g = false,
        },
        -- We define a bunch of groups/categories here which can/should be filled with keymaps.
        spec = {
            {
                mode = { "n", "v" },
                { "<leader>c",   group = "context", },
                { "<leader>cf",  group = "file" },
                { "<leader>d",   group = "diff" },
                { "<leader>e",   group = "edit/open" },
                { "<leader>en",  group = "notes" },
                { "<leader>enn", group = "new" },
                { "<leader>f",   group = "find" },
                { "<leader>fn",  group = "notes" },
                { "<leader>g",   group = "goto" },
                { "<leader>l",   group = "launch" },
                { "<leader>n",   group = "navigate" },
                { "<leader>r",   group = "refactor" },
                { "<leader>s",   group = "subst" },
                { "<leader>sh",  group = "hex" },
                { "<leader>ss",  group = "slashes" },
                { "<leader>sw",  group = "whitespace" },
                { "<leader>t",   group = "toggle" },
                { "<leader>w",   group = "windows" },
                { "<leader>y",   group = "yank" },
                { "<leader>yf",  group = "file" },
            },
        },
    },
}
