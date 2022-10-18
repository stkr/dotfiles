local present, telekasten = pcall(require, "telekasten")
if not present then
    vim.notify("Failed to require module [telekasten].")
    return
end

local utils = require("utils")

local callbacks = {}

local notes = vim.fn.expand("~/data/notes")
local templates = vim.fn.expand(notes .. "/.telekasten/templates")

local default_config = {
    home              = notes .. "/info",
    dailies           = notes .. "/daily",
    weeklies          = notes .. "/weekly",
    templates         = templates,
    new_note_filename = "uuid-title",
    uuid_type         = "%Y-%m-%d",

    template_new_note           = templates .. '/default.md',
    template_new_daily          = templates .. '/daily.md',
    template_new_weekly         = templates .. '/weekly.md',
    plug_into_calendar          = false,
    journal_auto_open           = true,
    weeklies_create_nonexisting = false,
}

local persons_config                = utils.deep_copy(default_config);
persons_config['home']              = notes .. "/persons"
persons_config['new_note_filename'] = "title"
persons_config['template_new_note'] = templates .. '/person.md'

default_config['vaults'] = {
    persons = persons_config
}

function callbacks.config()
    telekasten.setup(default_config)
end

return callbacks
