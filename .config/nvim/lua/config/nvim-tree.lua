local present, tree = pcall(require, "nvim-tree")
if not present then
    vim.notify("Failed to require module [nvim-tree].")
    return
end

local callbacks = {}

function callbacks.config()
    tree.setup({
        sync_root_with_cwd = true,
    })
end

return callbacks
