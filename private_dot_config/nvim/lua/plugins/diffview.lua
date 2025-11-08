return
{
    'sindrets/diffview.nvim',
    dependencies = { "nvim-lua/plenary.nvim", },
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose",
        "DiffviewToggleFiles", "DiffviewFocusFiles",
        "DiffviewRefresh", "DiffviewLog",
    },
    opts = {
        hooks = {
            diff_buf_read = function(bufnr)
                vim.opt_local.wrap = false
            end,
        },
        view = {
            merge_tool = {
                layout = "diff3_mixed",
            },
        },
    },
}
