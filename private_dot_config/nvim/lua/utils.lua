local utils = {}

function utils.safe_require(module_name)
    local loaded, module = pcall(require, module_name)
    if loaded then
        return module
    end
    return nil
end

function utils.is_plugin_registered(plugin_name)
    local plugins_collection = {}
    local lazy_config = require("lazy.core.config")
    local lazy_spec = lazy_config.spec
    for _, plugin in pairs(lazy_spec.plugins) do
        if plugin.name == plugin_name then
            return true
        end
    end
    return false
end

function utils.get_plugin_config_module(plugin_name)
    -- Deal with plugins that have weird characters in their name (often a '.').
    -- For these we only use the first letters
    local first_part = string.gmatch(plugin_name, "[a-zA-Z0-9%-_]+")()
    local plugin_config_name = "config." .. first_part
    local present, module = pcall(require, plugin_config_name)
    if not present then
        vim.notify("Failed to require plugin config module [" .. plugin_config_name .. "]")
        return
    end
    return module
end

function utils.is_text_before_cursor()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- Inspired by
-- https://github.com/ibhagwan/nvim-lua/blob/main/lua/utils.lua
-- local notify = utils.safe_require("notify")
-- Attention, loading plugins from here won't work. utils is required from init.lua
-- even BEFORE any plugins are loaded.

local function echo_multiline(msg)
    for _, s in ipairs(vim.fn.split(msg, "\n")) do
        vim.cmd("echom '" .. s:gsub("'", "''") .. "'")
    end
end

function utils.trace(msg)
    local notify = utils.safe_require("notify")
    if notify ~= nil then
        notify(msg, "TRACE", { render = "minimal" })
    else
        echo_multiline(msg)
    end
end

function utils.debug(msg)
    local notify = utils.safe_require("notify")
    if notify ~= nil then
        notify(msg, "DEBUG", { render = "minimal" })
    else
        echo_multiline(msg)
    end
end

function utils.info(msg)
    local notify = utils.safe_require("notify")
    if notify ~= nil then
        notify(msg, "INFO", { render = "minimal" })
    else
        vim.cmd('echohl Directory')
        echo_multiline(msg)
        vim.cmd('echohl None')
    end
end

function utils.warn(msg)
    local notify = utils.safe_require("notify")
    if notify ~= nil then
        notify(msg, "WARN", { render = "minimal" })
    else
        vim.cmd('echohl WarningMsg')
        echo_multiline(msg)
        vim.cmd('echohl None')
    end
end

function utils.err(msg)
    local notify = utils.safe_require("notify")
    if notify ~= nil then
        notify(msg, "ERROR", { render = "minimal" })
    else
        vim.cmd('echohl ErrorMsg')
        echo_multiline(msg)
        vim.cmd('echohl None')
    end
end

function utils.sudo_exec(cmd, print_output)
    vim.fn.inputsave()
    local password = vim.fn.inputsecret("Password: ")
    vim.fn.inputrestore()
    if not password or #password == 0 then
        utils.warn("Invalid password, sudo aborted")
        return false
    end
    local out = vim.fn.system(string.format("sudo -p '' -S %s", cmd), password)
    if vim.v.shell_error ~= 0 then
        print("\r\n")
        utils.err(out)
        return false
    end
    if print_output then print("\r\n", out) end
    return true
end

function utils.sudo_write(tmpfile, filepath)
    if not tmpfile then tmpfile = vim.fn.tempname() end
    if not filepath then filepath = vim.fn.expand("%") end
    if not filepath or #filepath == 0 then
        utils.err("E32: No file name")
        return
    end
    -- `bs=1048576` is equivalent to `bs=1M` for GNU dd or `bs=1m` for BSD dd
    -- Both `bs=1M` and `bs=1m` are non-POSIX
    local cmd = string.format("dd if=%s of=%s bs=1048576",
        vim.fn.shellescape(tmpfile),
        vim.fn.shellescape(filepath))
    -- no need to check error as this fails the entire function
    vim.api.nvim_exec(string.format("write! %s", tmpfile), true)
    if utils.sudo_exec(cmd) then
        utils.info(string.format('\r\n"%s" written', filepath))
        vim.cmd("e!")
    end
    vim.fn.delete(tmpfile)
end

function utils.callback_on_selection(func)
    -- Exit visual mode. This is required to update the < and > marks.
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', false, true, true), 'nx', false)
    local pos_start = vim.fn.getpos("'<")
    local pos_end = vim.fn.getpos("'>")
    local regtype = vim.fn.visualmode()
    if regtype:byte() == 22 then
        regtype = regtype .. math.abs(pos_end[3] - pos_start[3])
    end
    -- getpos is (1,1) indexed, from here on we continue (0,0) indexed.
    local region = vim.region(0,
        { pos_start[2] - 1, pos_start[3] - 1 },
        { pos_end[2] - 1, pos_end[3] - 1 },
        regtype, true)
    for line_nr, colums in pairs(region) do
        func(line_nr, colums)
    end
end

function utils.callback_on_line(func)
    local line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1
    func(line_nr, { 0, -1 })
end

function utils.current_line_subst_callback(func)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    -- get_cursor is "mark-like" indexed (1-based lines, 0-based columns).
    -- lua in general is using 1-based indexing, so we keep row & col
    -- consistent to use 1-based indexing.
    col = col + 1
    -- nvim_buf_get_lines uses 0-based indexing. We need to
    -- compensate for that difference.
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local s, e, replacement = func(line, col)
    if replacement ~= nil then
        line = line:sub(1, s - 1) .. replacement .. line:sub(e + 1, line:len())
        vim.api.nvim_buf_set_lines(0, row - 1, row, false, { line })
    end
end

local dotrepeat_func = utils.dotrepeat_nop

function utils.dotrepeat_nop()
end

function utils.dotrepeat_set_func(func)
    vim.go.operatorfunc = "v:lua.require'utils'.dotrepeat_nop"
    vim.cmd("normal! g@l")
    vim.go.operatorfunc = "v:lua.require'utils'.dotrepeat_exec"
    dotrepeat_func = func
end

function utils.dotrepeat_exec()
    dotrepeat_func()
end

function utils.dotrepeat_exec_and_set_func(func)
    utils.debug("dotrepeat_exec_and_set_func")
    func()
    utils.dotrepeat_set_func(func)
end

function utils.dotrepeat_create_func(cmd)
    return function()
        utils.debug("dotrepeat_create_func")
        -- if we get a string, assume it's a vim command
        if type(cmd) == "string" then
            utils.debug("string")
            utils.dotrepeat_exec_and_set_func(
                function()
                    utils.debug("exec_single_cmd")
                    vim.cmd(cmd)
                end)
            -- if we get a function, immediately exec and set up repeat
        elseif type(cmd) == "function" then
            utils.dotrepeat_exec_and_set_func(cmd)
            -- if we get a list, assume its a list of vim commands
        elseif type(cmd) == "table" then
            utils.dotrepeat_exec_and_set_func(
                function()
                    utils.debug("exec_multiple_cmds")
                    for _, c in ipairs(cmd) do
                        vim.cmd(c)
                    end
                end)
        end
    end
end

function utils.dotrepeat_create_callback_on_line_func(func)
    return function()
        utils.dotrepeat_exec_and_set_func(
            function()
                utils.callback_on_line(func)
            end)
    end
end

function utils.dotrepeat_create_callback_on_selection_func(func)
    return function()
        utils.dotrepeat_exec_and_set_func(
            function()
                utils.callback_on_selection(func)
            end)
    end
end

function utils.deep_copy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = utils.deep_copy(v)
        end
        copy[k] = v
    end
    return copy
end

function utils.get_python_path(workspace)
    local util = require('lspconfig/util')
    local path = util.path
    local python_path = nil

    -- Use activated virtualenv.
    if python_path == nil and vim.env.VIRTUAL_ENV then
        python_path = path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
    end

    -- Find and use virtualenv in workspace directory.
    if python_path == nil then
        for _, pattern in ipairs({ '*', '.*' }) do
            local match = vim.fn.glob(path.join(workspace, pattern, 'pyvenv.cfg'))
            if match ~= '' then
                python_path = path.join(path.dirname(match), 'bin', 'python')
                break
            end
        end
    end

    -- Fallback to system Python.
    if python_path == nil then
        python_path = vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
    end

    utils.info("Detected python path [" .. python_path .. "]")
    return python_path
end

function utils.get_buffer_by_name(name)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local buffer_name = vim.api.nvim_buf_get_name(buf)
        if string.find(buffer_name, name) then
            vim.notify("found buffer: [" .. buffer_name .. "]")
            return buf
        end
    end
    return nil
end

utils.terminal_split_window_id = nil

function utils.get_default_terminal_window()
    -- We do keep a single window for terminal commands and reuse that. This is
    -- to avoid cluttering the whole screen with terminal windows.
    local target_win = 0

    -- Attempt to retrieve the window.
    if utils.terminal_split_window_id ~= nil then
        -- The window is valid if it is visible (i.e. has a winnr) in the
        -- current tab. Thic can be checked with win_id2win.
        local valid_win = vim.fn.win_id2win(utils.terminal_split_window_id) ~= 0
        if valid_win then
            target_win = utils.terminal_split_window_id
        end
    end

    -- Still no window found - it may have been closed meanwhile. Create a new
    -- one instead.
    if target_win == 0 then
        vim.api.nvim_command('botright split')
        target_win = vim.api.nvim_tabpage_get_win(0)
        local window_id = vim.fn.win_getid()
        utils.terminal_split_window_id = window_id
        vim.api.nvim_win_set_height(0, 10)
    end

    return target_win
end

function utils.run_in_terminal_split(cmd, opts)

    -- Save the handle of the currently active window in order to be able to
    -- restore the focus to that window at the end.
    local original_win = vim.api.nvim_get_current_win()
    local target_win = utils.get_default_terminal_window()

    -- Create a new buffer for running the terminal command in.
    local target_buf = vim.api.nvim_create_buf(true, false)

    -- Display the buffer in the target window. The target_buf is displayed in
    -- that window per default. It is of-course possible to manually display it
    -- in a different window later. Note, this makes the new buffer the
    -- "current" buffer. Some vim api functions rely on that and have no option
    -- to pass a buffer.
    vim.api.nvim_set_current_win(target_win)
    vim.api.nvim_win_set_buf(target_win, target_buf)


    if opts == nil then
        vim.notify("ops is nil")
        opts = {}
    end
    if opts['height'] == nil then
        opts['height'] = 10
    end
    if opts['on_exit'] == nil then
        opts['on_exit'] = function(_, _, _)
            vim.notify("on_exit_callback executed")
            vim.cmd("copen")
            vim.cmd("cgetbuffer " .. target_buf)
        end
    end
    if opts['name'] == nil then
        opts['name'] = cmd
    end


    -- Run cmd in the current buffer
    vim.fn.termopen(cmd, opts)

    -- Move the cursor to the end of the buffer. This is required to enable the
    -- "autoscrolling" behavior.
    local target_line = vim.tbl_count(vim.api.nvim_buf_get_lines(0, 0, -1, true))
    vim.api.nvim_win_set_cursor(target_win, { target_line, 0 })

    -- Now, we may still have an old buffer from a previous run of the same
    -- command around. To maintain the sanity of the user, delete that old one.
    local full_name = "term: " .. opts['name']
    local old_buffer = utils.get_buffer_by_name(full_name)
    if old_buffer ~= nil then
        vim.api.nvim_buf_delete(old_buffer, { force = true })
    end
    vim.api.nvim_buf_set_name(target_buf, full_name)

    -- Move the cursor back to the original window.
    vim.api.nvim_set_current_win(original_win)
end

return utils
