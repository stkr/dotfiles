return
{
    "renerocksai/telekasten.nvim",
    cmd = { "Telekasten", },
    module = { "telekasten", },
    config = function()
        local telekasten                    = require("telekasten")
        local utils                         = require("utils")

        local notes                         = vim.fn.expand("~/data/notes")
        local templates                     = vim.fn.expand("~/.config/telekasten/templates")

        local default_config                = {
            home                        = notes .. "/info",
            dailies                     = notes .. "/daily",
            weeklies                    = notes .. "/weekly",
            templates                   = templates,
            new_note_filename           = "uuid-title",
            uuid_type                   = "%Y-%m-%d",

            template_new_note           = templates .. '/default.md',
            template_new_daily          = templates .. '/daily.md',
            template_new_weekly         = templates .. '/weekly.md',
            plug_into_calendar          = false,
            journal_auto_open           = true,
            weeklies_create_nonexisting = false,
        }

        local private_config                = utils.deep_copy(default_config);
        private_config['home']              = notes .. "/private/persons"
        private_config['new_note_filename'] = "title"
        private_config['template_new_note'] = templates .. '/person.md'

        default_config['vaults']            = {
            private = private_config
        }

        telekasten.setup(default_config)
    end,
}
