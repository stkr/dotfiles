return
{
    'sindrets/diffview.nvim',
    dependencies = { "nvim-lua/plenary.nvim", },
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose",
        "DiffviewToggleFiles", "DiffviewFocusFiles",
        "DiffviewRefresh", "DiffviewLog",
    },
    opts = {
        view = {
            merge_tool = {
                layout = "diff3_mixed",
            },
        },
    },
}
