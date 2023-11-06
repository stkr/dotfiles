
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

-------------  Useful common substitution commands
--
-- A little bit of background on why substitution mappings are that convoluted:
-- Normally one would define a command like
-- a = { "<cmd>s/a/b/<cr>", "subst b for a" },
-- however, that does update the pattern register and hlsearch.
-- Per design, vim does restore those, when exiting from a function. However, this only works when
-- the substitution is within a vimscript function - the following would still work, but also
-- change pattern register and hlsearch:
-- b = { "<cmd>lua vim.api.nvim_command('s/a/b/')<cr>", "subst b for a" },
-- So, what we need to do instead is, to define a vimscript function which contains the
-- substitution command, and call that function. We then can bind that function to a key.
--
-- In visual mode one would use the marks '< and '> to select the range of lines in which to
-- substitute.
-- However, the marks '< and '> are only set when you leave Visual mode.
-- When you're using Vim interactively, this happens naturally, as you use the : to start typing
-- a "substitute" command Vim will leave Visual mode and enter command-line mode. But that's not
-- the case when you're using normal! from a function.
-- You can add an <Esc> to leave Visual mode explicitely. You'll need :execute to encode
-- the <Esc> inside a string. Source:
-- https://vi.stackexchange.com/questions/25104/how-do-i-substitute-inside-the-visual-selection-in-a-vimscript-function
--
function mh_substitute(command)
    vim.api.nvim_exec(string.format([[
          function s:mh_substitute_vimscript()
              exe "normal! \<esc>"
              %s
          endfunction
          call s:mh_substitute_vimscript()
      ]], command), false)
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

vim.keymap.set('n', '<leader>dd', "<cmd>DiffviewOpen -uno<cr>", { desc = "Open diffview" })
vim.keymap.set('n', '<leader>dh', "<cmd>DiffviewFileHistory<cr>", { desc = "Open diffview of file history" })
vim.keymap.set('n', '<leader>dn', utils.dotrepeat_create_func("GitGutterNextHunk"), { desc = "Go to next git diff hunk" })
vim.keymap.set('n', '<leader>dN', utils.dotrepeat_create_func("GitGutterPrevHunk"),
    { desc = "Go to previous git diff hunk" })
vim.keymap.set('n', '<leader>dp', utils.dotrepeat_create_func("GitGutterPreviewHunk"),
    { desc = "Show git diff hunk preview" })
vim.keymap.set('n', '<leader>dq', utils.dotrepeat_create_func({ "GitGutterQuickFix", "copen" }),
    { desc = "Load git diff into quickfix window" })
vim.keymap.set('n', '<leader>dr', utils.dotrepeat_create_func("GitGutterUndoHunk"), { desc = "Revert git diff hunk" })
vim.keymap.set('n', '<leader>ds', utils.dotrepeat_create_func({ "GitGutterStageHunk", "GitGutterNextHunk" }),
    { desc = "Stage current hunk" })
vim.keymap.set('n', '<leader>dS', utils.dotrepeat_create_func("GitGutterUnstageHunk"), { desc = "Unstage current hunk" })

vim.keymap.set('v', '<leader>dn', "<cmd>GitGutterNextHunk<cr>", { desc = "Go to next git diff hunk" })
vim.keymap.set('v', '<leader>dN', "<cmd>GitGutterPrevHunk<cr>", { desc = "Go to previous git diff hunk" })


-------------  Edit commonly used files

vim.keymap.set('n', '<leader>eb', "<cmd>:e ~/.bashrc<cr>", { desc = "Edit ~/.bashrc" })
vim.keymap.set('n', '<leader>eg', "<cmd>:e ~/.gitconfig<cr>", { desc = "Edit ~/.gitconfig" })

vim.keymap.set('n', '<leader>enni', function() require("telekasten").new_note() end,
    { desc = "Create new note in category: info", })

vim.keymap.set('n', '<leader>ennj', function() require("telekasten").goto_today() end,
    { desc = "Create new note in category: journal", })

vim.keymap.set('n', '<leader>ennp', function()
    local tk = require("telekasten")
    tk.chdir(tk.vaults['persons'])
    tk.new_note()
end, { desc = "Create new note in category: persons" })

vim.keymap.set('n', '<leader>enf', function() require("telekasten").find_notes() end, { desc = "Find note", })
vim.keymap.set('n', '<leader>ev', "<cmd>:e ~/.vim/vimrc<cr>", { desc = "Edit ~/.vim/vimrc" })


-------------  Finding stuff

vim.keymap.set('n', '<leader>fb',
    function()
        require('telescope.builtin').buffers({
            previewer = false,
            sort_mru = true,
            sort_lastused = true,
            ignore_current_buffer = true
        })
    end, { desc = "Find buffer" })
vim.keymap.set('n', '<leader>fc', function() require('telescope.builtin').resume() end,
    { desc = "Continue last find/telescope operation" })
vim.keymap.set('n', '<leader>ff', function() require('telescope.builtin').fd({ previewer = false }) end,
    { desc = "Find file" })
vim.keymap.set('n', '<leader>fg', function() require('telescope.builtin').live_grep({ previewer = false }) end,
    { desc = "Find in files" })
vim.keymap.set('n', '<leader>fh', function() require('telescope.builtin').oldfiles({ previewer = false }) end,
    { desc = "Find file history" })
vim.keymap.set("n", "<leader>fm", function() require("telescope.builtin").keymaps() end, { desc = "Find key mapping"})

vim.keymap.set('n', '<leader>fni', function() require("telekasten").find_notes() end,
    { desc = "Find note in category: info" })
vim.keymap.set('n', '<leader>fnp',
    function()
        local tk = require("telekasten")
        tk.chdir(tk.vaults['persons'])
        tk.find_notes()
    end, { desc = "Find note in category: persons" })

vim.keymap.set('n', '<leader>fq', function() require('telescope.builtin').quickfixhistory() end,
    { desc = "Find quickfix history" })
vim.keymap.set('n', '<leader>ft', function() require('telescope.builtin').tags() end, { desc = "Find tag" })
vim.keymap.set('n', '<leader>f:', function() require('telescope.builtin').command_history() end,
    { desc = "Find command history" })
vim.keymap.set('n', '<leader>f*', function() require('telescope.builtin').grep_string({ previewer = false }) end,
    { desc = "Find word under cursor in files" })
vim.keymap.set('n', '<leader>fr', function() require("telescope").extensions.frecency.frecency({ previewer = false }) end,
    { desc = "Find recent file" })
vim.keymap.set('n', '<leader>fs', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end,
    { desc = "Find symbol in workspace" })
vim.keymap.set('n', '<leader>fu', function() require('telescope.builtin').lsp_references() end, { desc = "Find usage" })
vim.keymap.set('n', '<leader>f/', function() require('telescope.builtin').search_history() end,
    { desc = "Find in search history" })
vim.keymap.set('n', '<leader>fa', "<cmd>Telescope<cr>", { desc = "Find anything" })


-------------  Going to / jumping to

vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { desc = "Goto definition" })
vim.keymap.set('n', '<leader>gh', "<cmd>ClangdSwitchSourceHeader<cr>", { desc = "Goto header/src" })


-------------  Launcing things

vim.keymap.set('n', '<leader>lt', '<cmd>:PlenaryBustedFile %<cr>', { desc = "Launch tests in current file" })


-------------  Navigation

vim.keymap.set('n', '<leader>nc', "cmd>cd %:p:h<cr>", { desc = "Change dir to current file" })


-------------  Refactoring

vim.keymap.set('n', '<leader>rf', function() vim.lsp.buf.format() end, { desc = "Format current file" })
vim.keymap.set('n', '<leader>rm', function()
    require('telescope'); vim.lsp.buf.code_action()
end, { desc = "Display code actions menu" })
vim.keymap.set('n', '<leader>rr', function() vim.lsp.buf.rename() end, { desc = "Rename identifier under cursor" })

vim.keymap.set('v', '<leader>rf', function() vim.lsp.buf.format() end, { desc = "Format selection" })
vim.keymap.set('v', '<leader>rm', function()
    require('telescope'); vim.lsp.buf.code_action()
end, { desc = "Display code actions menu" })

vim.keymap.set('n', '<leader>sse', [[<cmd>lua mh_substitute(":s/\\\\/\\\\\\\\/ge")<cr>]], { desc = "Escape slashes" })
vim.keymap.set('n', '<leader>ssu', [[<cmd>lua mh_substitute(":s/\\\\/\\//ge")<cr>]],
    { desc = "Convert slashes to unix format" })
vim.keymap.set('n', '<leader>ssw', [[<cmd>lua mh_substitute(":s/\\//\\\\/ge")<cr>]],
    { desc = "Convert slashes to windows format" })

vim.keymap.set('n', '<leader>shc', [[<cmd>lua mh_substitute(":s!\\([0-9a-fA-F][0-9a-fA-F]\\)!0x\\1, !ge")<cr>]],
    { desc = "Convert hex number to c-style array of bytes" })
vim.keymap.set('n', '<leader>shj', [[<cmd>lua mh_substitute(":s!\\([0-9a-fA-F][0-9a-fA-F]\\)!(byte) 0x\\1, !ge")<cr>]],
    { desc = "Convert hex number to java array of bytes" })
vim.keymap.set('n', '<leader>shs', [[<cmd>lua mh_substitute(":s!\\([0-9a-fA-F][0-9a-fA-F]\\)!\\1 !ge")<cr>]],
    { desc = "Convert hex number to space separated bytes" })
vim.keymap.set('n', '<leader>shx', [[<cmd>lua mh_extract_hex()<cr>]], { desc = "extract hex" })
vim.keymap.set('n', '<leader>sh2', hexstring_swap_2, { desc = "Swap 2 bytes" })
vim.keymap.set('n', '<leader>sh4', hexstring_swap_4, { desc = "Swap 4 bytes" })
vim.keymap.set('n', '<leader>sh8', hexstring_swap_8, { desc = "Swap 8 bytes" })

vim.keymap.set('n', '<leader>swe', [[<cmd>lua mh_substitute(":s!\\s\\+$!!")<cr>]], {
    desc =
    "Delete whitespace before eol"
})
vim.keymap.set('n', '<leader>swu', "<cmd>set ff=unix<cr>", { desc = "Set file format to unix (eol)" })
vim.keymap.set('n', '<leader>sww', "<cmd>set ff=dos<cr>", { desc = "Set file format to dos/windows (eol)" })

vim.keymap.set('n', '<leader>ssu', [[<cmd>lua mh_substitute(":\'<,\'>s/\\%V\\\\/\\//ge")<cr>]],
    { desc = "Convert slashes to unix format" })
vim.keymap.set('n', '<leader>ssw', [[<cmd>lua mh_substitute(":\'<,\'>s/\\%V\\//\\\\/ge")<cr>]],
    { desc = "Convert slashes to windows format" })
vim.keymap.set('n', '<leader>shc',
    [[<cmd>lua mh_substitute(":\'<,\'>s!\\(\\%V[0-9a-fA-F]\\%V[0-9a-fA-F]\\)!0x\\1, !ge")<cr>]],
    { desc = "Convert hex number to c-style array of bytes" })
vim.keymap.set('n', '<leader>shj',
    [[<cmd>lua mh_substitute(":\'<,\'>s!\\(\\%V[0-9a-fA-F]\\%V[0-9a-fA-F]\\)!(byte) 0x\\1, !ge")<cr>]],
    { desc = "Convert hex number to java array of bytes" })
vim.keymap.set('n', '<leader>shs',
    [[<cmd>lua mh_substitute(":\'<,\'>s!\\(\\%V[0-9a-fA-F]\\%V[0-9a-fA-F]\\)!\\1 !ge")<cr>]],
    { desc = "Convert hex number to space separated bytes" })
vim.keymap.set('n', '<leader>swe', [[<cmd>lua mh_substitute(":\'<,\'>s!\\s\\+$!!")<cr>]],
    { desc = "Delete whitespace before eol" })
vim.keymap.set('n', '<leader>swn', [[<cmd>lua mh_substitute(":\'<,\'>s/\\n\\{2,}/\\r\\r/g")<cr>]],
    { desc = "Delete consecutive newlines" })


-------------  Toggle

vim.keymap.set('n', '<leader>tc', toggle_autocomplete, { desc = "Toggle (auto-)completion" })
vim.keymap.set('n', '<leader>th', "<cmd>set hlsearch!<cr>", { desc = "Toggle search highlight (hlsearch)" })
vim.keymap.set('n', '<leader>tl', "<cmd>set list!<cr>", { desc = "Toggle invisible characters (list(chars))" })
vim.keymap.set('n', '<leader>tp', "<cmd>set paste!<cr>", { desc = "Toggle paste mode" })
vim.keymap.set('n', '<leader>tr', "<cmd>set relativenumber!<cr>", { desc = "Toggle relativenumber" })
vim.keymap.set('n', '<leader>ts', "<cmd>set spell!<cr>", { desc = "Toggle spell" })
vim.keymap.set('n', '<leader>tt', "<cmd>NvimTreeFindFileToggle<cr>", { desc = "Toggle file tree" })
vim.keymap.set('n', '<leader>tw', "<cmd>set wrap!<cr>", { desc = "Toggle word wrap" })
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

-------------  Misc
vim.keymap.set('n', '<leader>.', "<cmd>e#<cr>", { desc = "Edit alternate/most recent file" })
vim.keymap.set('n', '<leader>,', "<cmd>w<cr>", { desc = "Save file" })
