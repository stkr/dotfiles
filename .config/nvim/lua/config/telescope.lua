local present, telescope = pcall(require, "telescope")
if not present then
    vim.notify("Failed to require module [telescope].")
    return
end

local actions = require("telescope.actions")
local action_layout = require("telescope.actions.layout")


local callbacks = {}

-- Telescope
function callbacks.config()
    telescope.setup {
        defaults = {
            mappings = {
                i = {
                    ['<C-k>'] = actions.move_selection_previous,
                    ['<C-j>'] = actions.move_selection_next,
                    ['<C-l>'] = actions.cycle_history_next,
                    ['<C-h>'] = actions.cycle_history_prev,
                    ['<M-p>'] = action_layout.toggle_preview
                },
                n = {
                    ['<M-p>'] = action_layout.toggle_preview
                },
            },
            path_display = { 'smart' },
        },
        extensions = {
            ["ui-select"] = {
                require("telescope.themes").get_dropdown {}
            }
        },
    }

    -- Enable telescope fzf native
    telescope.load_extension('fzf')
    telescope.load_extension('ui-select')
end

return callbacks
