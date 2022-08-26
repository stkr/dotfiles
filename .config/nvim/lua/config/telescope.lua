local present, telescope = pcall(require, "telescope")
if not present then
    vim.notify("Failed to require module [telescope].")
    return
end

local actions = require("telescope.actions")
local action_layout = require("telescope.actions.layout")
local action_state = require("telescope.actions.state")


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

        pickers = {
            buffers = {
                prompt_prefix = " ﬘ > ",
            },
            fd = {
                prompt_prefix = "  > ",
            },
            live_grep = {
                prompt_prefix = "  > ",
            },
            tags = {
                prompt_prefix = " 笠> ",
            },
            quickfixhistory = {
                mappings = {
                    -- In quickfixhistory use <CR> to reload that particular entry of 
                    -- the quickfixhistory. The default seems to be to use 
                    -- telecsope (again) to pick from within that particular 
                    -- quickfixlist - this seems overkill.
                    i = {
                      ["<CR>"] = function(prompt_buf)
                        local entry = action_state.get_selected_entry()
                        if entry then
                            actions.close(prompt_buf)
                            vim.cmd(string.format("%schistory | copen", entry.nr))
                        end
                      end
                    }
                }
            },
        },
    }

    -- Enable telescope fzf native
    telescope.load_extension('fzf')
    telescope.load_extension('ui-select')
end

return callbacks
