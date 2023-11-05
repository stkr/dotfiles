return
{
    'nvim-tree/nvim-tree.lua',
    dependencies = {
        'nvim-tree/nvim-web-devicons',     -- optional, for file icons
    },
    cmd = { "NvimTreeOpen", "NvimTreeClose", "NvimTreeToggle", "NvimTreeFocus", "NvimTreeRefresh",
        "NvimTreeFindFile",
        "NvimTreeFindFileToggle", "NvimTreeClipboard", "NvimTreeResize", "NvimTreeCollapse",
        "NvimTreeCollapseKeepBuffers", },
    config = function()
        local function on_attach_callback(bufnr)
            local api = require("nvim-tree.api")

            local function opts(desc)
                return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
            end

            -- default mappings
            api.config.mappings.default_on_attach(bufnr)

            -- custom mappings
            vim.keymap.set("n", "l", api.node.open.edit, opts("Edit Or Open"))
            vim.keymap.set("n", "h", api.tree.close, opts("Close"))
            vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))
        end

        local tree = require("nvim-tree")
        tree.setup({
            actions = {
                open_file = {
                    resize_window = false,
                },
            },
            live_filter = {
                prefix = "[S]: ",
                always_show_folders = false,
            },
            on_attach = on_attach_callback,
            sync_root_with_cwd = true,
            view = {
                preserve_window_proportions = true,
            },
        })
    end,
}
