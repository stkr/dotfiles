local autosave = {}

local present, utils = pcall(require, "utils")
if not present then
    vim.notify("Failed to require module [utils].")
    return
end

autosave.is_enabled = false

local augroup_name = "Autosave"

function autosave.enable(options)
    if autosave.is_enabled then
        return
    end

    local autosave_group = vim.api.nvim_create_augroup(augroup_name, { clear = true })
    vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", }, { command = "silent! wall", group = autosave_group })
    autosave.is_enabled = true
    if options == nil or not options['silent'] then
        utils.info("Autosave is enabled")
    end
end

function autosave.disable(options)
    if not autosave.is_enabled then
        return
    end
    vim.api.nvim_del_augroup_by_name(augroup_name)
    autosave.is_enabled = false
    if options == nil or not options['silent'] then
        utils.info("Autosave is disabled")
    end
end

function autosave.toggle(options)
    if autosave.is_enabled then
        autosave.disable(options)
    else
        autosave.enable(options)
    end
end

return autosave
