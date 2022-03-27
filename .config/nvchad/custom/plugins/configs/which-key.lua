local wk = require("which-key")


local leader_normal = { prefix = "<leader>", mode = "n" }
local leader_visual = { prefix = "<leader>", mode = "x" }

wk.setup {
    ignore_missing = true
}

-------------  Alignment
wk.register({
    a = {
        name = "align",
        a = { "<cmd>EasyAlign<CR>", "easyalign" },
    }, }, leader_normal)
wk.register({
    a = {
        name = "+align",
        a = { "<cmd>EasyAlign<CR>", "easyalign" },
    }, }, leader_visual)


-------------  Context information
wk.register({
    c = {
        name = "context",
        i = { "<cmd>lua vim.lsp.buf.hover()<CR>", "info" },
        s = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "signature" },
    }, }, leader_normal)


-------------  Edit commonly used files
wk.register({
    e = {
        name = "edit/open",
        b = { "<cmd>:e ~/.bashrc<CR>", "bashrc" },
        i = { "<cmd>:e ~/.vim/vimrc<CR>", "vimrc" },
        g = { "<cmd>:e ~/.gitconfig<CR>", "gitconfig" },
        n = { "<cmd>:e ~/.config/nvim/custom/init.lua<CR>", "nvim-init" },
    }, }, leader_normal)


-------------  Finding stuff
wk.register({
    f = {
        name = "find",
        b = { "<cmd>Telescope buffers<CR>", "buffer" },
        e = { "<cmd>NvimTreeFocus<CR>", "explore" },
        f = { "<cmd>Telescope fd<CR>", "file" },
        -- g = { "<cmd>Telescope live_grep<CR>", "grep" },
        g = { "<cmd>lua require(\"telescope\").extensions.live_grep_raw.live_grep_raw()<CR>", "grep" },
        t = { "<cmd>Telescope tags<CR>", "tag" },
        [':'] = { "<cmd>Telescope command_history<CR>", "command history" },
        ['*'] = { "<cmd>Telescope grep_string<CR>", "word in files" },
        r = { "<cmd>Telescope lsp_references<CR>", "references" },
        u = { "<cmd>Telescope lsp_references<CR>", "usages" },
        ['/'] = { "<cmd>Telescope search_history<CR>", "search history" },
        a = { "<cmd>Telescope<CR>", "anything" },
    }, }, leader_normal)


-------------  Going to / jumping to
wk.register({
    g = {
        name = "goto",
        d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "definition" },
        h = { "<cmd>ClangdSwitchSourceHeader<CR>", "header/src" },
    }, }, leader_normal)


-------------  Refactoring
wk.register({
    r = {
        name = "refactor",
        r = { "<cmd>lua vim.lsp.buf.rename()<CR>", "rename" },
        f = { "<cmd>lua vim.lsp.buf.range_formatting()<CR>", "format" },
    }, }, leader_normal)


-------------  Useful common substitution commands
--
-- A little bit of background on why substitution mappings are that convoluted:
-- Normally one would define a command like
-- a = { "<cmd>s/a/b/<cr>", "subst b for a" },
-- however, that does update the pattern register and hlsearch.
-- Per design, vim does restore those, when exiting from a function. However, this only works when
-- the substitution is within a vimscript function - the following would still work, but also
-- change pattern register and hlsearch:
-- b = { "<cmd>lua vim.api.nvim_command('s/a/b/')<CR>", "subst b for a" },
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
            :let @a=""
            :s/[0-9][0-9]/\=setreg('A', submatch(0), 'c')/g
            :d
            :normal "ap
        endfunction
        call s:mh_extract_hex_vimscript()
    ]], false)
end

wk.register({
    s = {
        name = "subst",
        s = {
            name = "slashes",
            u = { [[<cmd>lua mh_substitute(":s/\\\\/\\//ge")<cr>]], "unix" },
            w = { [[<cmd>lua mh_substitute(":s/\\//\\\\/ge")<cr>]], "windows" },
        },
        h = {
            name = "hex",
            c = { [[<cmd>lua mh_substitute(":s!\\([0-9a-fA-F][0-9a-fA-F]\\)!0x\\1, !ge")<cr>]], "c" },
            j = { [[<cmd>lua mh_substitute(":s!\\([0-9a-fA-F][0-9a-fA-F]\\)!(byte) 0x\\1, !ge")<cr>]], "java" },
            s = { [[<cmd>lua mh_substitute(":s!\\([0-9a-fA-F][0-9a-fA-F]\\)!\\1 !ge")<cr>]], "spaces" },
            h = { [[<cmd>lua mh_extract_hex()<cr>]], "hex" },
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
        l = { "<cmd>set list!<cr>", "listchars" },
        n = { "<cmd>set relativenumber!<cr>", "numbers are relative" },
        p = { "<cmd>set paste!<cr>", "paste" },
        s = { "<cmd>set spell!<cr>", "spell" },
    }, }, leader_normal)
