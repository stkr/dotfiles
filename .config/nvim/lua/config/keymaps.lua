-- Since leader mapping for plugins are defined in here, this file may "require" lots
-- of modules. All plugin requires shall be encapsulated in anonymous functions. This
-- is for two reasons:
--   1.) Plugins may be lazy loaded. As a require will trigger loading of the plugin,
--       the require shall done only once the mapped key is pressed, not when this
--       file is executed.
--   2.) Parsing/execution of this file will not fail if a plugin is removed but its
--       mapping is still present. It will only fail at the invocation of the
--       mapping.


-- helper functions

local utils = require("utils")
local function toggle_autocomplete()
    local cmp = require('cmp')
    if (cmp.get_config()['completion']['autocomplete'] == false) then
        local types = require('cmp.types')
        cmp.setup({ completion = { autocomplete = { types.cmp.TriggerEvent.TextChanged, } } })
    else
        cmp.setup({ completion = { autocomplete = false } })
    end
end

-------------  Helpers for substitution mappings

local function subst(line_nr, columns, pat, repl)
    local bufline = vim.api.nvim_buf_get_lines(0, line_nr, line_nr + 1, true)[1]
    local line_length = string.len(bufline)
    if columns[2] < 0 or columns[2] > line_length then
        columns[2] = line_length
    end

    local prefix = string.sub(bufline, 1, columns[1])
    local relevant = string.sub(bufline, columns[1] + 1, columns[2])
    local suffix = string.sub(bufline, columns[2] + 1)
    relevant = string.gsub(relevant, pat, repl)
    bufline = prefix .. relevant .. suffix
    vim.api.nvim_buf_set_lines(0, line_nr, line_nr + 1, true, { bufline })
end

local function nmap_subst(pat, repl)
    local func = function(line_nr, columns)
        subst(line_nr, columns, pat, repl)
    end
    return utils.dotrepeat_create_callback_on_line_func(func)
end

local function vmap_subst(pat, repl)
    local func = function(line_nr, columns)
        subst(line_nr, columns, pat, repl)
    end
    return utils.dotrepeat_create_callback_on_selection_func(func)
end

function mh_extract_hex()
    vim.api.nvim_exec([[
          function s:mh_extract_hex_vimscript()
              let @a=""
              s/[0-9a-fA-F][0-9a-fA-F]/\=setreg('A', submatch(0), 'c')/g
              normal d$
              normal "ap
          endfunction
          call s:mh_extract_hex_vimscript()
      ]], false)
end

local function hexstring_swap(width)
    utils.current_line_subst_callback(
        function(line, col)
            local hexstr = require("hexstr")
            local s, e = hexstr.find_around(line, col)
            if (s < 1) then
                return 0, 0, nil
            end
            local str = line:sub(s, e)
            local swapped = hexstr.swap(str, width)
            return s, e, swapped
        end)
end

local function hexstring_swap_2()
    hexstring_swap(2)
    utils.dotrepeat_set_func(hexstring_swap_2)
end

local function hexstring_swap_4()
    hexstring_swap(4)
    utils.dotrepeat_set_func(hexstring_swap_4)
end

local function hexstring_swap_8()
    hexstring_swap(8)
    utils.dotrepeat_set_func(hexstring_swap_8)
end


-- ############# Leader key mappings

-------------  Context information

vim.keymap.set('n', '<leader>cd', vim.diagnostic.setqflist, { desc = "Load diagnostics to quickfix window" })

-- directory name (/something/src)
vim.keymap.set('n', '<leader>cfd', function() utils.info(vim.fn.expand("%:p:h")) end,
    { desc = "Print directory of opened file" })

-- filename       (foo.txt)
vim.keymap.set('n', '<leader>cff', function() utils.info(vim.fn.expand("%:t")) end,
    { desc = "Print filename of open file" })

-- absolute path  (/something/src/foo.txt)
vim.keymap.set('n', '<leader>cfp', function() utils.info(vim.fn.expand("%:p")) end,
    { desc = "Print full path of open file" })

-- relative path  (src/foo.txt)
vim.keymap.set('n', '<leader>cfr', function() utils.info(vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:.")) end,
    { desc = "Print relative path of open file" })

vim.keymap.set('n', '<leader>ci', vim.lsp.buf.hover, { desc = "Display lsp hover context information" })
vim.keymap.set('n', '<leader>cs', vim.lsp.buf.signature_help, { desc = "Display lsp signature context help" })


-------------  Diffing files
-- Note, some of them are set from within gitsigns on_attach() method. 
-- Please see lua/plugins/gitsigns.lua


-------------  Edit commonly used files

vim.keymap.set('n', '<leader>eb', "<cmd>:e ~/.bashrc<cr>", { desc = "Edit ~/.bashrc" })
vim.keymap.set('n', '<leader>eg', "<cmd>:e ~/.gitconfig<cr>", { desc = "Edit ~/.gitconfig" })

vim.keymap.set('n', '<leader>enni', function() require("telekasten").new_note() end,
    { desc = "Create new note in category: info", })

vim.keymap.set('n', '<leader>ennj', function() require("telekasten").goto_today() end,
    { desc = "Create new note in category: journal", })

vim.keymap.set('n', '<leader>ennp', function()
    local tk = require("telekasten")
    tk.chdir(tk.vaults['private'])
    tk.new_note()
end, { desc = "Create new note in category: private" })

vim.keymap.set('n', '<leader>enf', function() require("telekasten").find_notes() end, { desc = "Find note", })
vim.keymap.set('n', '<leader>ev', "<cmd>:e ~/.vim/vimrc<cr>", { desc = "Edit ~/.vim/vimrc" })


-------------  Finding stuff

vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua buffers<cr>', { desc = "Find buffer" })
vim.keymap.set('n', '<leader>fc', '<cmd>FzfLua resume<cr>', { desc = "Continue last find operation" })
vim.keymap.set('n', '<leader>ff', '<cmd>FzfLua files<cr>', { desc = "Find file" })
vim.keymap.set('n', '<leader>fg', '<cmd>FzfLua live_grep<cr>', { desc = "Find in files" })
vim.keymap.set('n', '<leader>fh', '<cmd>FzfLua oldfiles<cr>', { desc = "Find file history" })

vim.keymap.set('n', '<leader>fni', 
    function() require("telekasten").find_notes() 
        local tk = require("telekasten")
        tk.chdir(tk.vaults['default'])
        tk.find_notes()
    end, { desc = "Find note in category: info" })
vim.keymap.set('n', '<leader>fnp',
    function()
        local tk = require("telekasten")
        tk.chdir(tk.vaults['private'])
        tk.find_notes()
    end, { desc = "Find note in category: private" })

vim.keymap.set('n', '<leader>fr', "<cmd>GrugFar<cr>", { desc = "Find with ripgrep" })
vim.keymap.set('n', '<leader>fq', '<cmd>FzfLua quickfix<cr>', { desc = "Find quickfix history" })
vim.keymap.set('n', '<leader>ft', '<cmd>FzfLua tags<cr>', { desc = "Find tag" })
vim.keymap.set('n', '<leader>f:', '<cmd>FzfLua command_history<cr>', { desc = "Find in command history" })
vim.keymap.set('n', '<leader>f*', '<cmd>FzfLua grep_cword<cr>', { desc = "Find word under cursor in files" })
vim.keymap.set('n', '<leader>fs', '<cmd>FzfLua lsp_workspace_symbols<cr>', { desc = "Find symbol in workspace" })
vim.keymap.set('n', '<leader>fu', '<cmd>FzfLua lsp_references<cr>', { desc = "Find usage" })
vim.keymap.set('n', '<leader>f/', '<cmd>FzfLua search_history<cr>', { desc = "Find in search history" })
vim.keymap.set('n', '<leader>fa', "<cmd>FzfLua<cr>", { desc = "Find anything" })


-------------  Going to / jumping to

vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { desc = "Goto definition" })
vim.keymap.set('n', '<leader>gh', "<cmd>ClangdSwitchSourceHeader<cr>", { desc = "Goto header/src" })


-------------  Launcing things

vim.keymap.set('n', '<leader>lt', '<cmd>:PlenaryBustedFile %<cr>', { desc = "Launch tests in current file" })
vim.keymap.set('n', '<leader>lf', '<cmd>:OverseerRun run\\ script<cr>', { desc = "Launch current file" })


-------------  Navigation

vim.keymap.set('n', '<leader>nc', "cmd>cd %:p:h<cr>", { desc = "Change dir to current file" })


-------------  Refactoring

vim.keymap.set('n', '<leader>rf', function() require("conform").format() end, { desc = "Format current file" })
vim.keymap.set('n', '<leader>rm', '<cmd>FzfLua lsp_code_actions<cr>', { desc = "Display code actions menu" })
vim.keymap.set('n', '<leader>rr', function() vim.lsp.buf.rename() end, { desc = "Rename identifier under cursor" })

vim.keymap.set('v', '<leader>rf', function() require("conform").format() end, { desc = "Format selection" })
vim.keymap.set('v', '<leader>rm', '<cmd>FzfLua lsp_code_actions<cr>', { desc = "Display code actions menu" })

vim.keymap.set('n', '<leader>sse', nmap_subst('\\', '\\\\'), { desc = "Escape slashes" })
vim.keymap.set('n', '<leader>ssu', nmap_subst('\\', '/'), { desc = "Convert slashes to unix format" })
vim.keymap.set('n', '<leader>ssw', nmap_subst('/', '\\'), { desc = "Convert slashes to windows format" })

vim.keymap.set('n', '<leader>shc', nmap_subst('(%x%x)', '0x%1, '),
    { desc = "Convert hex number to c-style array of bytes" })
vim.keymap.set('n', '<leader>shj', nmap_subst('(%x%x)', '(byte) 0x%1, '),
    { desc = "Convert hex number to java array of bytes" })
vim.keymap.set('n', '<leader>shs', nmap_subst('(%x%x)', '%1 '),
    { desc = "Convert hex number to space separated bytes" })
vim.keymap.set('n', '<leader>shx', [[<cmd>lua mh_extract_hex()<cr>]], { desc = "extract hex" })
vim.keymap.set('n', '<leader>sh2', hexstring_swap_2, { desc = "Swap 2 bytes" })
vim.keymap.set('n', '<leader>sh4', hexstring_swap_4, { desc = "Swap 4 bytes" })
vim.keymap.set('n', '<leader>sh8', hexstring_swap_8, { desc = "Swap 8 bytes" })

vim.keymap.set('n', '<leader>swe', nmap_subst('%s+$', ''), { desc = "Delete whitespace before eol" })
vim.keymap.set('n', '<leader>swu', "<cmd>set ff=unix<cr>", { desc = "Set file format to unix (eol)" })
vim.keymap.set('n', '<leader>sww', "<cmd>set ff=dos<cr>", { desc = "Set file format to dos/windows (eol)" })

vim.keymap.set('v', '<leader>ssu', vmap_subst('\\', '/'), { desc = "Convert slashes to unix format" })
vim.keymap.set('v', '<leader>ssw', vmap_subst('/', '\\'), { desc = "Convert slashes to windows format" })
vim.keymap.set('v', '<leader>shc', vmap_subst('(%x%x)', '0x%1, '),
    { desc = "Convert hex number to c-style array of bytes" })
vim.keymap.set('v', '<leader>shj', vmap_subst('(%x%x)', '(byte) 0x%1, '),
    { desc = "Convert hex number to java array of bytes" })
vim.keymap.set('v', '<leader>shs', vmap_subst('(%x%x)', '%1 '),
    { desc = "Convert hex number to space separated bytes" })

vim.keymap.set('v', '<leader>swe', vmap_subst('%s+$', ''), { desc = "Delete whitespace before eol" })


-------------  Toggle

-- The following are set by mini.basic already:
--- - `b` - |'background'|.
--- - `c` - |'cursorline'|.
--- - `C` - |'cursorcolumn'|.
--- - `d` - diagnostic (via |vim.diagnostic| functions).
--- - `h` - |'hlsearch'| (or |v:hlsearch| to be precise).
--- - `i` - |'ignorecase'|.
--- - `l` - |'list'|.
--- - `n` - |'number'|.
--- - `r` - |'relativenumber'|.
--- - `s` - |'spell'|.
--- - `w` - |'wrap'|.
vim.keymap.set('n', '<leader>tc', toggle_autocomplete, { desc = "Toggle (auto-)completion" })
vim.keymap.set('n', '<leader>to', "<cmd>Outline<cr>", { desc = "Toggle outline" })
vim.keymap.set('n', '<leader>tt', "<cmd>NvimTreeFindFileToggle<cr>", { desc = "Toggle file tree" })
vim.keymap.set('n', '<leader>tq', function() require("autosave").toggle() end, { desc = "Toggle autosave" })


-------------  Yanking

-- directory name (/something/src)
vim.keymap.set('n', '<leader>yfd', ':let @*=expand("%:p:h")<cr>', { desc = "Yank/copy directory of opened file" })

-- filename       (foo.txt)
vim.keymap.set('n', '<leader>yff', ':let @*=expand("%:t")<cr>', { desc = "Yank/copy filename of open file" })

-- absolute path  (/something/src/foo.txt)
vim.keymap.set('n', '<leader>yfp', ':let @*=expand("%:p")<cr>', { desc = "Yank/copy full path of open file" })

-- relative path  (src/foo.txt)
vim.keymap.set('n', '<leader>yfr', ':let @*=fnamemodify(expand("%"), ":~:.")<cr>',
    { desc = "Yank/copy relative path of open file" })

-------------  DAP

-- Note on the weird key-bindings for F17 and F29 below:
-- To get the escape sequences that the terminal uses to represent key presses, use
--     showkey -a
-- For this particular situation (alacritty, linux), the keys S-F5 and C-F5 get
-- reported as
--     ^[[15;2~         27 0033 0x1b
--     ^[[15;5~         27 0033 0x1b
-- Now to find out what key nvim does map that terminal sequence to, execute
-- nvim -V3/tmp/log
-- In the resulting log file, the sequences are found as:
--     key_f17                   kf17       = ^[[15;2~
--     key_f29                   kf29       = ^[[15;5~
-- So the <F17> mapping really is <S-F5> and <F29> is <C-F5>
-- It might be different on other terminal emulators / operating systems,
-- more evaluations needed.
-- (see also https://github.com/neovim/neovim/issues/7384)

vim.keymap.set('n', '<F5>', function() require("dap").continue() end)
vim.keymap.set('n', '<F29>', function() require("dap").run_last() end)  -- <C-F5>
vim.keymap.set('n', '<F17>', function() require("dap").terminate() end) -- <S-F5>
vim.keymap.set('n', '<F9>', function() require("dap").toggle_breakpoint() end)
vim.keymap.set('n', '<F10>', function() require("dap").step_over() end)
vim.keymap.set('n', '<F11>', function() require("dap").step_into() end)
vim.keymap.set('n', '<F23>', function() require("dap").step_out() end) --  <S-F11>

-------------  Misc
vim.keymap.set('n', '<leader>.', "<cmd>e#<cr>", { desc = "Edit alternate/most recent file" })
vim.keymap.set('n', '<leader>,', "<cmd>w<cr>", { desc = "Save file" })

vim.keymap.set('t', "<esc><esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
