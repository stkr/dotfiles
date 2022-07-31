local present, wk = pcall(require, "which-key")
if not present then
    vim.notify("Failed to require module [which-key].")
    return
end

local callbacks = {}

--Add leader shortcuts via whichkey
function callbacks.config()

    local leader_normal = { prefix = "<leader>", mode = "n" }
    local leader_visual = { prefix = "<leader>", mode = "v" }

    wk.setup {
        ignore_missing = true
    }

    -------------  Context information
    wk.register({
        c = {
            name = "context",
            d = { "<cmd>lua vim.diagnostic.setqflist()<cr>", "diagnostic" },
            i = { "<cmd>lua vim.lsp.buf.hover()<cr>", "info" },
            s = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "signature" },
        }, }, leader_normal)


    -------------  Edit commonly used files
    wk.register({
        e = {
            name = "edit/open",
            b = { "<cmd>:e ~/.bashrc<cr>", "bashrc" },
            g = { "<cmd>:e ~/.gitconfig<cr>", "gitconfig" },
            n = { "<cmd>:e ~/.config/nvim/custom/init.lua<cr>", "nvim-init" },
            v = { "<cmd>:e ~/.vim/vimrc<cr>", "vimrc" },
        }, }, leader_normal)


    -------------  Finding stuff
    wk.register({
        f = {
            name = "find",
            b = { "<cmd>lua require('telescope.builtin').buffers({ previewer = false })<cr>", "buffer" },
            e = { "<cmd>NvimTreeFocus<cr>", "explore" },
            f = { "<cmd>lua require('telescope.builtin').fd({ previewer = false })<cr>", "file" },
            g = { "<cmd>lua require('telescope.builtin').live_grep({ previewer = false })<cr>", "grep" },
            q = { "<cmd>lua require('telescope.builtin').quickfixhistory()<cr>", "quickfix" },
            t = { "<cmd>Telescope tags<cr>", "tag" },
            [':'] = { "<cmd>Telescope command_history<cr>", "command history" },
            ['*'] = { "<cmd>lua require('telescope.builtin').grep_string({ previewer = false })<cr>", "word in files" },
            r = { "<cmd>Telescope resume<cr>", "resume" },
            u = { "<cmd>Telescope lsp_references<cr>", "usages" },
            ['/'] = { "<cmd>Telescope search_history<cr>", "search history" },
            a = { "<cmd>Telescope<cr>", "anything" },
        }, }, leader_normal)


    -------------  Going to / jumping to
    wk.register({
        g = {
            name = "goto",
            d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "definition" },
            h = { "<cmd>ClangdSwitchSourceHeader<cr>", "header/src" },
        }, }, leader_normal)

    -------------  Navigation
    wk.register({
        n = {
            name = "navigate",
            c = { "<cmd>cd %:p:h<cr>", "current" },
        }, }, leader_normal)

    -------------  Refactoring
    wk.register({
        r = {
            name = "refactor",
            f = { "<cmd>lua vim.lsp.buf.formatting_seq_sync(nil, 5000, nil)<cr>", "format" },
            m = { "<cmd>lua require('telescope'); vim.lsp.buf.code_action()<cr>", "menu" },
            r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "rename" },
        }, }, leader_normal)

    wk.register({
        r = {
            name = "refactor",
            f = { "<cmd>lua vim.lsp.buf.range_formatting()<cr>", "format" },
        }, }, leader_visual)

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
      ]] , command), false)
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
      ]] , false)
    end

    function toggle_autocomplete()
        local cmp = require('cmp')
        if (cmp.get_config()['completion']['autocomplete'] == false) then
            local types = require('cmp.types')
            cmp.setup({ completion = { autocomplete = { types.cmp.TriggerEvent.TextChanged, } } })
        else
            cmp.setup({ completion = { autocomplete = false } })
        end
    end

    wk.register({
        s = {
            name = "subst",
            s = {
                name = "slashes",
                e = { [[<cmd>lua mh_substitute(":s/\\\\/\\\\\\\\/ge")<cr>]], "escape" },
                u = { [[<cmd>lua mh_substitute(":s/\\\\/\\//ge")<cr>]], "unix" },
                w = { [[<cmd>lua mh_substitute(":s/\\//\\\\/ge")<cr>]], "windows" },
            },
            h = {
                name = "hex",
                c = { [[<cmd>lua mh_substitute(":s!\\([0-9a-fA-F][0-9a-fA-F]\\)!0x\\1, !ge")<cr>]], "c" },
                j = { [[<cmd>lua mh_substitute(":s!\\([0-9a-fA-F][0-9a-fA-F]\\)!(byte) 0x\\1, !ge")<cr>]], "java" },
                s = { [[<cmd>lua mh_substitute(":s!\\([0-9a-fA-F][0-9a-fA-F]\\)!\\1 !ge")<cr>]], "spaces" },
                x = { [[<cmd>lua mh_extract_hex()<cr>]], "extract hex" },
                ['2'] = { [[<cmd>lua mh_substitute(":s!\\([0-9a-fA-F][0-9a-fA-F]\\)\\([0-9a-fA-F][0-9a-fA-F]\\)!\\2\\1!ge")<cr>]], "swap 2 bytes" },
                ['4'] = { [[<cmd>lua mh_substitute(":s!\\([0-9a-fA-F][0-9a-fA-F]\\)\\([0-9a-fA-F][0-9a-fA-F]\\)\\([0-9a-fA-F][0-9a-fA-F]\\)\\([0-9a-fA-F][0-9a-fA-F]\\)!\\4\\3\\2\\1!ge")<cr>]], "swap 4 bytes" },
                ['8'] = { [[<cmd>lua mh_substitute(":s!\\([0-9a-fA-F][0-9a-fA-F]\\)\\([0-9a-fA-F][0-9a-fA-F]\\)\\([0-9a-fA-F][0-9a-fA-F]\\)\\([0-9a-fA-F][0-9a-fA-F]\\)\\([0-9a-fA-F][0-9a-fA-F]\\)\\([0-9a-fA-F][0-9a-fA-F]\\)\\([0-9a-fA-F][0-9a-fA-F]\\)\\([0-9a-fA-F][0-9a-fA-F]\\)!\\8\\7\\6\\5\\4\\3\\2\\1!ge")<cr>]], "swap 8 bytes" },

            },
            w = {
                name = "whitespace",
                e = { [[<cmd>lua mh_substitute(":s!\\s\\+$!!")<cr>]], "delete whitespace before eol" },
                u = { "<cmd>set ff=unix<cr>", "unix" },
                w = { "<cmd>set ff=dos<cr>", "windows" },
            },
        }, }, leader_normal)

    wk.register({
        s = {
            name = "subst",
            s = {
                name = "slashes",
                u = { [[<cmd>lua mh_substitute(":\'<,\'>s/\\%V\\\\/\\//ge")<cr>]], "unix" },
                w = { [[<cmd>lua mh_substitute(":\'<,\'>s/\\%V\\//\\\\/ge")<cr>]], "windows" },
            },
            h = {
                name = "hex",
                c = { [[<cmd>lua mh_substitute(":\'<,\'>s!\\(\\%V[0-9a-fA-F]\\%V[0-9a-fA-F]\\)!0x\\1, !ge")<cr>]], "c" },
                j = { [[<cmd>lua mh_substitute(":\'<,\'>s!\\(\\%V[0-9a-fA-F]\\%V[0-9a-fA-F]\\)!(byte) 0x\\1, !ge")<cr>]], "java" },
                s = { [[<cmd>lua mh_substitute(":\'<,\'>s!\\(\\%V[0-9a-fA-F]\\%V[0-9a-fA-F]\\)!\\1 !ge")<cr>]], "spaces" },
            },
            w = {
                name = "whitespace",
                e = { [[<cmd>lua mh_substitute(":\'<,\'>s!\\s\\+$!!")<cr>]], "delete whitespace before eol" },
                n = { [[<cmd>lua mh_substitute(":\'<,\'>s/\\n\\{2,}/\\r\\r/g")<cr>]], "delete consecutive newlines" },
            },
        }, }, leader_visual)


    -------------  Toggle
    wk.register({
        t = {
            name = "toggle",
            c = { "<cmd>lua toggle_autocomplete()<cr>", "complete" },
            h = { "<cmd>set hlsearch!<cr>", "hlseach" },
            l = { "<cmd>set list!<cr>", "listchars" },
            r = { "<cmd>set relativenumber!<cr>", "relativenumber" },
            p = { "<cmd>set paste!<cr>", "paste" },
            s = { "<cmd>set spell!<cr>", "spell" },
            w = { "<cmd>set wrap!<cr>", "wrap" },
        }, }, leader_normal)


    -------------  Yanking
    wk.register({
        y = {
            name = "yank",
            f = {
                name = "file",
                -- directory name (/something/src)
                d = { ':let @*=expand("%:p:h")<cr>', "dir" },
                -- filename       (foo.txt)
                f = { ':let @*=expand("%:t")<cr>', "filename" },
                -- absolute path  (/something/src/foo.txt)
                p = { ':let @*=expand("%:p")<cr>', "path" },
                -- relative path  (src/foo.txt)
                r = { ':let @*=fnamemodify(expand("%"), ":~:.")<cr>', "relative path" },
            },
        }, }, leader_normal)

    -------------  Misc
    wk.register({
        ['.'] = { "<cmd>lua require('telescope.builtin').buffers({ sort_mru = true, ignore_current_buffer = true, previewer = false })<cr>", "recent files" },
        [','] = { "<cmd>w<cr>", "save" },
        ['/'] = { "<Plug>(comment_toggle_current_linewise)j", "comment" },
        q = { "<cmd>Sayonara!<cr>", "close" }
    }, leader_normal)
    wk.register({
        ['/'] = { "<Plug>(comment_toggle_linewise_visual)", "comment" },
    }, leader_visual)
end

return callbacks