
local multi_highlight = {}

-- Highlight groups
vim.cmd([[
  hi default MultiHighlight1 guifg=#000000 guibg=#FFD700
  hi default MultiHighlight2 guifg=#000000 guibg=#00FFFF
  hi default MultiHighlight3 guifg=#000000 guibg=#FF66CC
  hi default MultiHighlight4 guifg=#FFFFFF guibg=#7C4DFF
  hi default MultiHighlight5 guifg=#000000 guibg=#98FB98
]])

local groups = { "MultiHighlight1", "MultiHighlight2", "MultiHighlight3", "MultiHighlight4", "MultiHighlight5" }
local priority = 80

-- ─────────────────────────────────────────────────────────────────────────────
-- State helpers (window-local)
-- ─────────────────────────────────────────────────────────────────────────────
local function get_state()
  if not vim.w.regex_hl then
    vim.w.regex_hl = {
      patterns = {}, -- { { pat, group, id } }
      group_idx = 1,
    }
  end
  return vim.w.regex_hl
end

local function set_state(st)
  vim.w.regex_hl = st
end

-- Return current group, then advance (so first use is WinHL1)
local function next_group()
  local st = get_state()
  local grp = groups[st.group_idx]
  st.group_idx = (st.group_idx % #groups) + 1
  set_state(st)
  return grp
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Core add/remove
-- ─────────────────────────────────────────────────────────────────────────────
local function add_regex(pat, group)
  local id = vim.fn.matchadd(group, pat, priority)
  local st = get_state()
  table.insert(st.patterns, {
    pat = pat,
    group = group,
    id = id,
  })
  set_state(st)
end

local function add_word()
  local word = vim.fn.expand("<cword>")
  if not word or word == "" then
    vim.notify("No <cword> under cursor", vim.log.levels.WARN)
    return
  end
  local pat = "\\V" .. vim.fn.escape(word, [[\]])
  add_regex(pat, next_group())
end

local function add_last_search()
  local last = vim.fn.getreg("/")
  if last == "" then
    vim.notify("No previous / search", vim.log.levels.WARN)
    return
  end
  add_regex(last, next_group())
end

local function clear_window()
  local st = get_state()
  for _, m in ipairs(st.patterns) do
    pcall(vim.fn.matchdelete, m.id)
  end
  st.patterns = {}
  st.group_idx = 1
  set_state(st)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Match detection under cursor (single-line assumption)
-- ─────────────────────────────────────────────────────────────────────────────
-- Returns occurrence info if cursor is within any highlight:
-- {
--   match = { pat=..., group=..., id=... },
--   lnum  = <1-based line>,
--   s0    = <0-based start byte index>,
--   e0    = <0-based exclusive end byte index>
-- }
local function find_match_under_cursor()
  local st = get_state()
  local pos = vim.api.nvim_win_get_cursor(0)
  local lnum = pos[1]
  local col0 = pos[2] -- 0-based
  local line = vim.api.nvim_get_current_line()

  for _, m in ipairs(st.patterns) do
    local start0 = 0
    while true do
      local r = vim.fn.matchstrpos(line, m.pat, start0)
      if r[2] == -1 then break end
      local s0 = r[2]            -- 0-based start
      local e0 = r[3]            -- 0-based exclusive end
      if col0 >= s0 and col0 < e0 then
        return { match = m, lnum = lnum, s0 = s0, e0 = e0 }
      end
      start0 = r[3]              -- continue after this match
    end
  end

  return nil
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Jump helpers (use searchpos, respect 'wrapscan')
-- ─────────────────────────────────────────────────────────────────────────────
local function jump_next_same(count)
  local occ = find_match_under_cursor()
  if not occ then return false end

  local wrap = vim.o.wrapscan
  local flags = 'n' .. (wrap and '' or 'W')

  local last_lnum, last_c1 = nil, nil

  -- We need to start searching just after the current match end (e0)
  local save_pos = vim.api.nvim_win_get_cursor(0)

  local lnum = occ.lnum
  local after_col0 = occ.e0 -- 0-based position *after* match (exclusive end)

  for _ = 1, (count or 1) do
    -- temporarily place the cursor to compute search without moving the UI state
    vim.api.nvim_win_set_cursor(0, { lnum, after_col0 })

    local res = vim.fn.searchpos(occ.match.pat, flags)
    local found_lnum, found_c1 = res[1], res[2]

    last_lnum, last_c1 = found_lnum, found_c1

    if found_lnum == 0 then
      -- nothing found anywhere (or wrap disabled and no further matches)
      break
    end

    -- prepare next iteration to search after the found match end
    lnum = found_lnum

    -- compute end-of-match (0-based) on that line to avoid re-hitting same match
    local text = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
    -- start position (0-based) for matchstrpos on that line:
    local start0 = found_c1 - 1
    local r = vim.fn.matchstrpos(text, occ.match.pat, start0)
    -- r[3] is 0-based exclusive end (relative to line)
    if r[2] ~= -1 then
      after_col0 = r[3]
    else
      -- fallback: move at least one byte ahead to prevent potential loop
      after_col0 = (found_c1 - 1) + 1
    end
  end

  -- restore original cursor before we actually jump to the final destination
  vim.api.nvim_win_set_cursor(0, save_pos)

  if not last_lnum or last_lnum == 0 then
    vim.notify("No next occurrence for current highlight", vim.log.levels.INFO)
    return true
  end

  vim.api.nvim_win_set_cursor(0, { last_lnum, last_c1 - 1 })
  return true
end

local function jump_prev_same(count)
  local occ = find_match_under_cursor()
  if not occ then return false end

  local wrap = vim.o.wrapscan
  local flags = 'bn' .. (wrap and '' or 'W')

  local last_lnum, last_c1 = nil, nil

  -- Start searching from the current match start (s0), and since we don't pass 'c',
  -- the search will find strictly before that position.
  local save_pos = vim.api.nvim_win_get_cursor(0)

  local lnum = occ.lnum
  local at_col0 = occ.s0 -- 0-based start of current match

  for _ = 1, (count or 1) do
    vim.api.nvim_win_set_cursor(0, { lnum, at_col0 })

    local res = vim.fn.searchpos(occ.match.pat, flags)
    local found_lnum, found_c1 = res[1], res[2]

    last_lnum, last_c1 = found_lnum, found_c1

    if found_lnum == 0 then
      break
    end

    -- Prepare next iteration to search before the found match start
    lnum = found_lnum
    at_col0 = found_c1 - 1
  end

  vim.api.nvim_win_set_cursor(0, save_pos)

  if not last_lnum or last_lnum == 0 then
    vim.notify("No previous occurrence for current highlight", vim.log.levels.INFO)
    return true
  end

  vim.api.nvim_win_set_cursor(0, { last_lnum, last_c1 - 1 })
  return true
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Remove under cursor (updated to reuse detection)
-- ─────────────────────────────────────────────────────────────────────────────
local function remove_under_cursor()
  local st = get_state()
  local occ = find_match_under_cursor()
  if occ then
    -- Remove this match id entry
    for i, m in ipairs(st.patterns) do
      if m == occ.match then
        pcall(vim.fn.matchdelete, m.id)
        table.remove(st.patterns, i)
        set_state(st)
        return
      end
    end
  end
  vim.notify("No highlight under cursor", vim.log.levels.INFO)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- User commands
-- ─────────────────────────────────────────────────────────────────────────────
vim.api.nvim_create_user_command("MultiHighlightAdd", function()
  local pat = vim.fn.input("Regex: ")
  if pat ~= "" then
    add_regex(pat, next_group())
  end
end, {})

vim.api.nvim_create_user_command("MultiHighlightAddWord", add_word, {})
vim.api.nvim_create_user_command("MultiHighlightAddSearch", add_last_search, {})
vim.api.nvim_create_user_command("MultiHighlightClear", clear_window, {})
vim.api.nvim_create_user_command("MultiHighlightRemove", remove_under_cursor, {})

-- ─────────────────────────────────────────────────────────────────────────────
-- n / N mappings: pattern-aware only when on a highlight
-- ─────────────────────────────────────────────────────────────────────────────
-- They respect counts (e.g., 3n / 2N). If not on a highlight, default behavior.
local function map_repeat_keys()
  -- NOTE: Use <Cmd>lua ...<CR> with `normal!` fallback to keep default semantics.
  vim.keymap.set('n', 'n', function()
    local cnt = vim.v.count1
    if find_match_under_cursor() then
      jump_next_same(cnt)
    else
      vim.cmd('normal! ' .. cnt .. 'n')
    end
  end, { silent = true, noremap = true, desc = "Next occurrence of highlight under cursor (or default n)" })

  vim.keymap.set('n', 'N', function()
    local cnt = vim.v.count1
    if find_match_under_cursor() then
      jump_prev_same(cnt)
    else
      vim.cmd('normal! ' .. cnt .. 'N')
    end
  end, { silent = true, noremap = true, desc = "Prev occurrence of highlight under cursor (or default N)" })
end

map_repeat_keys()

return multi_highlight
