
-- There are several types of keymappins:
--   - Plugins define the keymaps on there own: For lazy-loaded plugins, the lazy plugin 
--     spec needs to have those as trigger for lazy-loading.
--   - Manual mappings for plugin functionality: Regardless of lazy-loading, the plugin 
--     spec seems to be the right place to define those as well. For mappings that use
--     the <leader> we define them in the which-key config file. This has the advantage
--     of having an overfiew of the leader mappings in central place.
--
-- Since leader mapping for plugins are defined in here, this file may "require" lots 
-- of modules. In order not to have an invalid configuration once a plugin is 
-- disabled/uninstalled, NEVER invoke the require of the module directly in a mapping.
-- Encapsulate them in anonymous functions instead - then the require gets evaluated 
-- at the invocation of a mapping opposed to the loading of which-key and faults have
-- much less impact.


-- helper functions:

local function toggle_autocomplete()
    local cmp = require('cmp')
    if (cmp.get_config()['completion']['autocomplete'] == false) then
        local types = require('cmp.types')
        cmp.setup({ completion = { autocomplete = { types.cmp.TriggerEvent.TextChanged, } } })
    else
        cmp.setup({ completion = { autocomplete = false } })
    end
end

-- key mappings:
return
{
    'folke/which-key.nvim',
    keys = { "<leader>", nil, {"n", "v"}, desc = "Open which-key" },
    config =
        function()
            local wk = require("which-key")
            local utils = require("utils")

            local leader_normal = { prefix = "<leader>", mode = "n" }
            local leader_visual = { prefix = "<leader>", mode = "v" }

            wk.setup {
                ignore_missing = true
            }


            -------------  Context information
            wk.register({
                c = {
                    name = "context",
                    d = { "<cmd>lua vim.diagnostic.setqflist()<cr>", "Load diagnostics to quickfix window" },
                    f = {
                        name = "file",
                        -- directory name (/something/src)
                        d = { function() utils.info(vim.fn.expand("%:p:h")) end, "Print directory of opened file" },
                        -- filename       (foo.txt)
                        f = { function() utils.info(vim.fn.expand("%:t")) end, "Print filename of open file" },
                        -- absolute path  (/something/src/foo.txt)
                        p = { function() utils.info(vim.fn.expand("%:p")) end, "Print full path of open file" },
                        -- relative path  (src/foo.txt)
                        r = { function() utils.info(vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:.")) end,
                            "Print relative path of open file" },
                    },
                    i = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Display lsp hover information" },
                    s = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Display lsp signature help" },
                },
            }, leader_normal)


            -------------  Diffing files
            wk.register({
                d = {
                    name = "diff",
                    d = { "<cmd>DiffviewOpen -uno<cr>", "Open diffview" },
                    h = { "<cmd>DiffviewFileHistory<cr>", "Open diffview of file history" },
                    n = { utils.dotrepeat_create_func("GitGutterNextHunk"), "Go to next git diff hunk" },
                    N = { utils.dotrepeat_create_func("GitGutterPrevHunk"), "Go to previous git diff hunk" },
                    p = { utils.dotrepeat_create_func("GitGutterPreviewHunk"), "Show git diff hunk preview" },
                    q = { utils.dotrepeat_create_func({ "GitGutterQuickFix", "copen" }), "Load git diff into quickfix window" },
                    r = { utils.dotrepeat_create_func("GitGutterUndoHunk"), "Revert git diff hunk" },
                    s = { utils.dotrepeat_create_func({ "GitGutterStageHunk", "GitGutterNextHunk" }), "Stage current hunk" },
                    S = { utils.dotrepeat_create_func("GitGutterUnstageHunk"), "Unstage current hunk" },
                },
            }, leader_normal)

            wk.register({
                d = {
                    name = "diff",
                    n = { "<cmd>GitGutterNextHunk<cr>", "Go to next git diff hunk" },
                    N = { "<cmd>GitGutterPrevHunk<cr>", "Go to previous git diff hunk" },
                },
            }, leader_visual)

            -------------  Edit commonly used files
            wk.register({
                e = {
                    name = "edit/open",
                    b = { "<cmd>:e ~/.bashrc<cr>", "Edit ~/.bashrc" },
                    g = { "<cmd>:e ~/.gitconfig<cr>", "Edit ~/.gitconfig" },
                    n = {
                        name = "notes",
                        n = {
                            name = "new",
                            i = { function() require("telekasten").new_note() end, "Create new note in category: info", },
                            j = { function() require("telekasten").goto_today() end, "Create new note in category: journal", },
                            p = {
                                function()
                                    local tk = require("telekasten")
                                    tk.chdir(tk.vaults['persons'])
                                    tk.new_note()
                                end, "Create new note in category: persons",
                            },
                        },
                        f = { function() require("telekasten").find_notes() end, "Find note", },
                    },
                    v = { "<cmd>:e ~/.vim/vimrc<cr>", "Edit ~/.vim/vimrc" },
                },
            }, leader_normal)

            -------------  Finding stuff
            wk.register({
                f = {
                    name = "find",

                    b = {
                        "<cmd>lua require('telescope.builtin').buffers({ previewer = false, sort_mru = true, sort_lastused = true, ignore_current_buffer = true })<cr>",
                        "Find buffer" },
                    c = { "<cmd>Telescope resume<cr>", "Continue last find/telescope operation" },
                    f = { "<cmd>lua require('telescope.builtin').fd({ previewer = false })<cr>", "Find file" },
                    g = { "<cmd>lua require('telescope.builtin').live_grep({ previewer = false })<cr>", "Find in files" },
                    h = { function() require('telescope.builtin').oldfiles({ previewer = false }) end, "Find file history" },
                    n = {
                        name = "notes",
                        i = { function() require("telekasten").find_notes() end, "Find note in category: info", },
                        p = {
                            function()
                                local tk = require("telekasten")
                                tk.chdir(tk.vaults['persons'])
                                tk.find_notes()
                            end, "Find note in category: persons",
                        },
                    },
                    q = { "<cmd>lua require('telescope.builtin').quickfixhistory()<cr>", "Find quickfix history" },
                    t = { "<cmd>lua require('telescope.builtin').tags()<cr>", "Find tag" },
                    [':'] = { "<cmd>lua require('telescope.builtin').command_history()<cr>", "Find command history" },
                    ['*'] = { "<cmd>lua require('telescope.builtin').grep_string({ previewer = false })<cr>",
                        "Find word under cursor in files" },
                    r = { function() require("telescope").extensions.frecency.frecency({ previewer = false }) end, "Find recent file" },
                    s = { function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, "symbols" },
                    u = { "<cmd>lua require('telescope.builtin').lsp_references()<cr>", "Find usage" },
                    ['/'] = { "<cmd>lua require('telescope.builtin').search_history<cr>", "Find in search history" },
                    a = { "<cmd>Telescope<cr>", "Find anything" },
                },
            }, leader_normal)


            -------------  Going to / jumping to
            wk.register({
                g = {
                    name = "goto",
                    d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Goto definition" },
                    h = { "<cmd>ClangdSwitchSourceHeader<cr>", "Goto header/src" },
                },
            }, leader_normal)

            -------------  Navigation
            wk.register({
                n = {
                    name = "navigate",
                    c = { "<cmd>cd %:p:h<cr>", "Change dir to current file" },
                },
            }, leader_normal)

            -------------  Refactoring
            wk.register({
                r = {
                    name = "refactor",
                    f = { function() vim.lsp.buf.format() end, "Format current file" },
                    m = { function()
                        require('telescope'); vim.lsp.buf.code_action()
                    end, "Display code actions menu" },
                    r = { function() vim.lsp.buf.rename() end, "Rename identifier under cursor" },
                },
            }, leader_normal)

            wk.register({
                r = {
                    name = "refactor",
                    f = { function() vim.lsp.buf.format() end, "Format selection" },
                    m = { function()
                        require('telescope'); vim.lsp.buf.code_action()
                    end, "Display code actions menu" },
                },
            }, leader_visual)

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

            wk.register({
                s = {
                    name = "subst",
                    s = {
                        name = "slashes",
                        e = { [[<cmd>lua mh_substitute(":s/\\\\/\\\\\\\\/ge")<cr>]], "Escape slashes" },
                        u = { [[<cmd>lua mh_substitute(":s/\\\\/\\//ge")<cr>]], "Convert slashes to unix format" },
                        w = { [[<cmd>lua mh_substitute(":s/\\//\\\\/ge")<cr>]], "Convert slashes to windows format" },
                    },
                    h = {
                        name = "hex",
                        c = { [[<cmd>lua mh_substitute(":s!\\([0-9a-fA-F][0-9a-fA-F]\\)!0x\\1, !ge")<cr>]], "Convert hex number to c-style array of bytes" },
                        j = { [[<cmd>lua mh_substitute(":s!\\([0-9a-fA-F][0-9a-fA-F]\\)!(byte) 0x\\1, !ge")<cr>]], "Convert hex number to java array of bytes" },
                        s = { [[<cmd>lua mh_substitute(":s!\\([0-9a-fA-F][0-9a-fA-F]\\)!\\1 !ge")<cr>]], "Convert hex number to space separated bytes" },
                        x = { [[<cmd>lua mh_extract_hex()<cr>]], "extract hex" },
                        ['2'] = { hexstring_swap_2, "Swap 2 bytes" },
                        ['4'] = { hexstring_swap_4, "Swap 4 bytes" },
                        ['8'] = { hexstring_swap_8, "Swap 8 bytes" },
                    },
                    w = {
                        name = "whitespace",
                        e = { [[<cmd>lua mh_substitute(":s!\\s\\+$!!")<cr>]], "Delete whitespace before eol" },
                        u = { "<cmd>set ff=unix<cr>", "Set file format to unix (eol)" },
                        w = { "<cmd>set ff=dos<cr>", "Set file format to dos/windows (eol)" },
                    },
                },
            }, leader_normal)

            wk.register({
                s = {
                    name = "subst",
                    s = {
                        name = "slashes",
                        u = { [[<cmd>lua mh_substitute(":\'<,\'>s/\\%V\\\\/\\//ge")<cr>]], "Convert slashes to unix format" },
                        w = { [[<cmd>lua mh_substitute(":\'<,\'>s/\\%V\\//\\\\/ge")<cr>]], "Convert slashes to windows format" },
                    },
                    h = {
                        name = "hex",
                        c = {
                            [[<cmd>lua mh_substitute(":\'<,\'>s!\\(\\%V[0-9a-fA-F]\\%V[0-9a-fA-F]\\)!0x\\1, !ge")<cr>]],
                            "Convert hex number to c-style array of bytes" },
                        j = {
                            [[<cmd>lua mh_substitute(":\'<,\'>s!\\(\\%V[0-9a-fA-F]\\%V[0-9a-fA-F]\\)!(byte) 0x\\1, !ge")<cr>]],
                            "Convert hex number to java array of bytes" },
                        s = { [[<cmd>lua mh_substitute(":\'<,\'>s!\\(\\%V[0-9a-fA-F]\\%V[0-9a-fA-F]\\)!\\1 !ge")<cr>]],
                            "Convert hex number to space separated bytes" },
                    },
                    w = {
                        name = "whitespace",
                        e = { [[<cmd>lua mh_substitute(":\'<,\'>s!\\s\\+$!!")<cr>]], "Delete whitespace before eol" },
                        n = { [[<cmd>lua mh_substitute(":\'<,\'>s/\\n\\{2,}/\\r\\r/g")<cr>]],
                            "Delete consecutive newlines" },
                    },
                },
            }, leader_visual)


            -------------  Toggle
            wk.register({
                t = {
                    name = "toggle",
                    c = { toggle_autocomplete, "Toggle (auto-)completion" },
                    h = { "<cmd>set hlsearch!<cr>", "Toggle search highlight (hlsearch)" },
                    l = { "<cmd>set list!<cr>", "Toggle invisible characters (list(chars))" },
                    p = { "<cmd>set paste!<cr>", "Toggle paste mode" },
                    r = { "<cmd>set relativenumber!<cr>", "Toggle relativenumber" },
                    s = { "<cmd>set spell!<cr>", "Toggle spell" },
                    t = { "<cmd>NvimTreeFindFileToggle<cr>", "Toggle file tree" },
                    w = { "<cmd>set wrap!<cr>", "Toggle word wrap" },
                    q = { function() require("autosave").toggle() end, "Toggle autosave" },
                },
            }, leader_normal)


            -------------  Yanking
            wk.register({
                y = {
                    name = "yank",
                    f = {
                        name = "file",
                        -- directory name (/something/src)
                        d = { ':let @*=expand("%:p:h")<cr>', "Yank/copy directory of opened file" },
                        -- filename       (foo.txt)
                        f = { ':let @*=expand("%:t")<cr>', "Yank/copy filename of open file" },
                        -- absolute path  (/something/src/foo.txt)
                        p = { ':let @*=expand("%:p")<cr>', "Yank/copy full path of open file" },
                        -- relative path  (src/foo.txt)
                        r = { ':let @*=fnamemodify(expand("%"), ":~:.")<cr>', "Yank/copy relative path of open file" },
                    },
                },
            }, leader_normal)

            -------------  Misc
            wk.register({
                ['.'] = { "<cmd>e#<cr>", "Edit alternate/most recent file" },
                [','] = { "<cmd>w<cr>", "Save file" },
            }, leader_normal)
        end,
}
