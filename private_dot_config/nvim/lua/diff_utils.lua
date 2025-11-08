local diff_utils = {}

local utils = require("utils")

local conflict_start = '^<<<<<<<'
local conflict_middle = '^======='
local conflict_end = '^>>>>>>>'
local conflict_ancestor = '^|||||||'

local function _find_start(lines, offset)
    for i = offset, 1, -1 do
        local line = lines[i]
        if line:match(conflict_start) then
            return i
            -- If the end marker is a the first line we look at, we still go
            -- ahead and search for the corresponding start.
            -- If an end marker is found somewhere else (before the
            -- current line) and we have not yet found a start, we stop
            -- searching.
        elseif i ~= offset and line:match(conflict_end) then
            return nil
        end
    end
    return nil
end

local function _detect_conflict_markers(lines, offset)
    -- vim.notify("###################### detect_conflict_marker")
    local indices = {}
    indices["start"] = _find_start(lines, offset)
    if indices["start"] ~= nil then
        for i = indices["start"] + 1, #lines do
            local line = lines[i]
            if line:match(conflict_ancestor) then
                indices["ancestor"] = i
            elseif line:match(conflict_middle) then
                indices["middle"] = i
            elseif line:match(conflict_end) then
                indices["end"] = i
                break
            end
        end
    end

    if (indices["start"] == nil) or (indices["middle"] == nil) or (indices["end"] == nil)
        or (indices["middle"] <= indices["start"]) or (indices["end"] <= indices["middle"]) then
        return nil
    end

    return indices
end

local function _get_options()
    local max_offset = 150
    local buffer_idx_line, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local start_offset = math.min(buffer_idx_line, max_offset)
    local buffer_idx_first_line = buffer_idx_line - start_offset
    local lines = vim.api.nvim_buf_get_lines(0, buffer_idx_first_line, buffer_idx_line + max_offset, false)

    local array_indices = _detect_conflict_markers(lines, start_offset)
    if array_indices == nil then
        return nil
    end

    local buffer_indices = {}
    buffer_indices["start"] = array_indices["start"] + buffer_idx_first_line
    buffer_indices["end"] = array_indices["end"] + buffer_idx_first_line

    local result = {}
    result["none"] = {}
    if array_indices["ancestor"] ~= nil then
        result["theirs"] = { unpack(lines, array_indices["start"] + 1, array_indices["ancestor"] - 1) }
        result["base"] = { unpack(lines, array_indices["ancestor"] + 1, array_indices["middle"] - 1) }
        result["ours"] = { unpack(lines, array_indices["middle"] + 1, array_indices["end"] - 1) }
    else
        result["theirs"] = { unpack(lines, array_indices["start"] + 1, array_indices["middle"] - 1) }
        result["ours"] = { unpack(lines, array_indices["middle"] + 1, array_indices["end"] - 1) }
    end

    return buffer_indices, result
end

local function _replace(buffer_indices, replacement)
    -- API uses zero-based indexing, lua uses one-based indexing hence - 1
    if replacement ~= nil then
        vim.api.nvim_buf_set_lines(0, buffer_indices["start"] - 1, buffer_indices["end"], true, replacement)
        vim.api.nvim_win_set_cursor(0, { buffer_indices["start"] + #replacement, 0 })
    end
end

function diff_utils.choose(all_selected)
    local buffer_indices, options = _get_options()
    if buffer_indices ~= nil and options ~= nil then
        local combined = {}
        for _, selected in ipairs(all_selected) do
            if options[selected] == nil then
                utils.warn("Invalid selection [" .. selected .. "].")
            else
                combined = utils.concat(combined, options[selected])
            end
        end
        _replace(buffer_indices, combined)
    end
end

return diff_utils
