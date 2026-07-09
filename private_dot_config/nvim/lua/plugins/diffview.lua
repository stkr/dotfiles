return
{
    "dlyongemallo/diffview-plus.nvim",
    version = "0.36",
    cmd = {
        "DiffviewOpen",
        "DiffviewDiffFiles",
        "DiffviewDiffDirs",
        "DiffviewMergeFiles",
        "DiffviewFileHistory",
        "DiffviewClose",
        "DiffviewToggle",
        "DiffviewToggleFiles",
        "DiffviewFocusFiles",
        "DiffviewRefresh",
        "DiffviewLog",
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
