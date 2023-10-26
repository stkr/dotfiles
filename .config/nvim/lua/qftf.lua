local function digits(i)
    if i > 100000 then
        return 5
    end

    if i > 10000 then
        return 5
    end

    if i > 1000 then
        return 4
    end

    if i > 100 then
        return 3
    end

    if i > 10 then
        return 2
    end

    return 1
end


function _G.qftf(info)
    local items
    local ret = {}
    if info.quickfix == 1 then
        items = vim.fn.getqflist({ id = info.id, items = 0 }).items
    else
        items = vim.fn.getloclist(info.winid, { id = info.id, items = 0 }).items
    end

    local fname_limit = 0
    local line_limit = 0
    local col_limit = 0
    for i = info.start_idx, info.end_idx do
        local e = items[i]
        if e.valid == 1 then
            local fname = ''
            if e.bufnr > 0 then
                fname = vim.fn.bufname(e.bufnr)
            end

            if fname == '' then
                fname = '[No Name]'
            else
                fname = vim.fs.basename(fname)
            end

            e.fname = fname

            fname_limit = math.max(#fname, fname_limit)
            line_limit = math.max(digits(e.lnum), line_limit)
            col_limit = math.max(digits(e.col), col_limit)
        end
    end

    local fmt = '%' .. fname_limit .. 's |%' .. line_limit .. 'd:%-' .. col_limit .. 'd|%s %s'

    for i = info.start_idx, info.end_idx do
        local e = items[i]
        local str
        if e.valid == 1 then
            local qtype = e.type == '' and '' or ' ' .. e.type:sub(1, 1):upper()
            str = fmt:format(e.fname, e.lnum, e.col, qtype, e.text)
        else
            str = e.text
        end
        table.insert(ret, str)
    end
    return ret
end

vim.o.qftf = '{info -> v:lua._G.qftf(info)}'
