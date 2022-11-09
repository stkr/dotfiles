local present, diffview = pcall(require, "diffview")
if not present then
    vim.notify("Failed to require module [diffview].")
    return
end

local callbacks = {}

function callbacks.config()
    diffview.setup({
        view = {
            merge_tool = {
                layout = "diff3_mixed",
            },
        },
    })
end

return callbacks
