-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- require important helper functions
local utils = require("utils")
local version = vim.version()

--#region helper functions
--#endregion


-- Remap comma as leader key (note, this has to be done before even
-- loading lazy as lazy uses <leader> for it's own mappings).
vim.g.mapleader = ','
vim.g.maplocalleader = ','

--#region plugins
require("lazy").setup("plugins", {
    performance = {
        rtp = {
            disabled_plugins = {
                "netrw",
                "netrwPlugin",
                "netrwSettings",
                "netrwFileHandlers",
                "gzip",
                "zip",
                "zipPlugin",
                "tar",
                "tarPlugin",
                "getscript",
                "getscriptPlugin",
                "vimball",
                "vimballPlugin",
                "2html_plugin",
                "logipat",
                "rrhelper",
                "spellfile_plugin",
                "matchit"
            },
        },
    },
})


--
-- end)

--#endregion


--Set highlight on search
vim.o.hlsearch = false

--Make line numbers default
vim.wo.number = true

-- Use relative numbers per default
vim.o.relativenumber = true

-- Enable cursorline
vim.o.cursorline = true

--Enable mouse mode
vim.o.mouse = 'a'

--Enable break indent
vim.o.breakindent = true

-- Use 4 spaces for indentation
-- show existing tab with 4 spaces width
vim.o.tabstop = 4
-- when indenting with '>', use 4 spaces width
vim.o.shiftwidth = 4
-- On pressing tab, insert 4 spaces
vim.o.expandtab = true

-- Reasonable listchars
vim.o.listchars = "eol:¬,tab:>>,trail:~,extends:>,precedes:<,space:·"

--Save undo history
vim.opt.undofile = true

--Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

--Decrease update time
vim.o.updatetime = 250
vim.o.signcolumn = 'yes'

--Set clipboard to use system clipboard per default
vim.o.clipboard = "unnamedplus"

-- Enable more reasonable diffs
if version.major > 0 or version.minor >= 9 then
    vim.opt.diffopt:append("linematch:50")
end

-- If run from within tmux, nvim per default on yank does copy also to a tmux
-- buffer. This a kind of shared clipboard between tmux panes. In addition,
-- tmux has the feature that it can copy this buffer to the client. This would
-- be using an OSC52 sequence, therefore requiring a terminal that supports
-- that.
--
-- To yank to tmux, nvim uses the "tmux load-buffer" command (see man tmux). In
-- order for that additional copy step to the client to happen, the -w argument
-- to load-buffer is required. Now per design nvim does not enable that
-- (https://github.com/neovim/neovim/issues/14545). Therefore, we need to
-- override the clipboard command ourselves and add that -w option with the
-- following configuration.
--
-- Note, there would also be an alternative to this approach - an alias for
-- "load-buffer" to "load-buffer -w" from within tmux
-- (https://github.com/tmux/tmux/issues/3088). This was tried and working as
-- well, however, it seems to be quite invasive and therefore this approach was
-- taken.

if os.getenv("TMUX") then
    vim.api.nvim_exec([[
let g:clipboard = {
          \   'name': 'myClipboard',
          \   'copy': {
          \      '+': ['tmux', 'load-buffer', '-w', '-'],
          \      '*': ['tmux', 'load-buffer', '-w', '-'],
          \    },
          \   'paste': {
          \      '+': ['tmux', 'save-buffer', '-'],
          \      '*': ['tmux', 'save-buffer', '-'],
          \   },
          \   'cache_enabled': 1,
          \ }
    ]], false)
end

-- New splits shall be below or to the right
vim.o.splitbelow = true
vim.o.splitright = true

local terminal_autocommands = vim.api.nvim_create_augroup("TerminalAutocommands", { clear = true })
-- Enter insert mode immediately when opening a terminal.
vim.api.nvim_create_autocmd({ "TermOpen", },
    { command = "startinsert", group = terminal_autocommands })
-- This could be used to prevent automatic closing of the terminal window when the process is done.
-- vim.api.nvim_create_autocmd({ "TermClose", },
-- { command = [[ call feedkeys("\<C-\>\<C-n>") ]], group = terminal_autocommands })

-- Add a keybinding to zoom in on the current split. This copies the split and creates a new
-- tab from it, so a simple close of the window is good enough to get back to the prev split
-- layout.
vim.keymap.set('n', '<C-W>z', ":tabnew %<CR>")

-- The s, and S keys are bound to svart and surround. Disable the inbuilt ones.
vim.keymap.set('n', 'S', "<nop>")

-- When doing command completion, do only complete as much as possible
-- and provide a list.
vim.o.wildmode = "longest:full,full"
vim.keymap.set('c', '<cr>', function()
    return vim.fn.pumvisible() == 1 and '<c-y>' or '<cr>'
end, { expr = true })
-- Interestingly enough, these won't work - neither their vimscript version
-- nor the lua version. So we stick with TAB for now...
-- vim.api.nvim_command([[ cnoremap <expr> <c-j> wildmenumode() ? "\<down>" : "\<c-j>" ]])
-- vim.api.nvim_command([[ cnoremap <expr> <c-k> wildmenumode() ? "\<up>" : "\<c-k>" ]])

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Ignore eol in visual block mode and allow having the cursor
-- one char after the end of the line
vim.o.virtualedit = "block,onemore"

-- Detect when a file is changed
vim.o.autoread = true

-- Use treesitter for folding
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldenable = false

-- Make marks always go to the marked column
vim.keymap.set('n', "'", "`")

-- Write a file as root
vim.api.nvim_create_user_command("SudoWrite", function(opts) require('utils').sudo_write() end, {})
-- vim.keymap.set('c', 'w!!<CR>', require('utils').sudo_write)

--Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('v', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('v', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

--- Don't copy the replaced text after pasting in visual mode
vim.keymap.set("v", "p", "p:let @+=@0<CR>")

-- Make gp select the recently pasted text
vim.keymap.set("n", "gp", "'[V']")

-- Avoid the escape key http://vim.wikia.com/wiki/Avoid_the_escape_key
vim.keymap.set('i', 'jk', '<esc>')
vim.keymap.set('i', 'kj', '<esc>')

-- Search for word under cursor without jumping around.
vim.keymap.set('n', '*', ':set hlsearch <bar> :let @/=expand(\'<cword>\')<CR>')

-- Quick jump
vim.keymap.set({ "n", "x", "o" }, "s", "<cmd>Svart<cr>")

--#region autocommands

-- Reload file after change
-- https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/149214
-- Trigger `autoread` when files changes on disk
-- https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
-- https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
-- https://vi.stackexchange.com/questions/14315/how-can-i-tell-if-im-in-the-command-window
-- getcmdwintype() returns a non-empty string if current window is the commandline window.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    command = "if mode() != 'c' && getcmdwintype() == '' | checktime | endif"
})

-- Save file when focus is lost
require("autosave").enable({ silent = true })

-- Notification after file change
-- https://vi.stackexchange.com/questions/13091/autocmd-event-for-autoread
vim.api.nvim_create_autocmd({ "FileChangedShellPost" }, {
    callback = function()
        require('utils').warn('File changed on disk. Buffer reloaded.')
    end
})

-- Automatically reload buffers when re-entering vim.
vim.api.nvim_create_autocmd({ "BufWinLeave" }, { command = "let b:winview = winsaveview()" })
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    command = "if exists('b:winview') | call winrestview(b:winview) | unlet b:winview"
})

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

-- Do not prefix newlines with the comment char if they are inserted
-- with O. The typical usecase for when we want that prefix is if we are editing
-- a comment and creating a newline with <cr>.
-- Normally one would just change the setting here. However A LOT of ftplugins
-- override the option. The suggested way to deal with it is to define yet another
-- autocommand that overrides the ftplugin's override :-(
-- https://codeahoy.com/q/287/vim-faq
-- https://stackoverflow.com/questions/23691236/vim-removing-r-from-format-options-for-all-filetypes
vim.api.nvim_create_autocmd({ "Filetype" }, { command = "set formatoptions-=o" })

--#endregion


-- Gitgutter settings
vim.g.gitgutter_map_keys = 0
vim.g.gitgutter_close_preview_on_escape = 1

-- vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers)
-- vim.keymap.set('n', '<leader>sf', function()
--   require('telescope.builtin').find_files { previewer = false }
-- end)
-- vim.keymap.set('n', '<leader>sb', require('telescope.builtin').current_buffer_fuzzy_find)
-- vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags)
-- vim.keymap.set('n', '<leader>st', require('telescope.builtin').tags)
-- vim.keymap.set('n', '<leader>sd', require('telescope.builtin').grep_string)
-- vim.keymap.set('n', '<leader>sp', require('telescope.builtin').live_grep)
-- vim.keymap.set('n', '<leader>so', function()
--   require('telescope.builtin').tags { only_current_buffer = true }
-- end)
-- vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles)

local lspconfig = utils.safe_require("lspconfig")
local lsp_utils = utils.safe_require("lsp_utils")
if lspconfig ~= nil and lsp_utils ~= nil then
    -- Enable the following language servers
    local servers = { 'clangd', 'tsserver', 'gdscript' }
    for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.get_capabilities(),
        }
    end
end


-- The idea is to have the language server installed in the same virtual
-- environment as the proect itself. The venv is activated before nvim
-- is launched from that shell.
-- This allows to access the language servers as well as to run python
-- code from within nvim with the same environment.
if lspconfig ~= nil and lsp_utils ~= nil then
    lspconfig.pylsp.setup {
        on_attach = lsp_utils.on_attach,
        capabilities = lsp_utils.get_capabilities(),
        settings = {
            pylsp = {
                configurationSources = { "black" },
                plugins = {
                    -- default code style linter disabled in favor of black.
                    pycodestyle = {
                        enabled = false,
                    },
                    -- code actions:
                    rope_autoimport = {
                        enabled = true,
                    },
                    -- reformatting:
                    black = {
                        enabled = true,
                        line_length = 100,
                        preview = true,
                    },
                    flake8 = {
                        enabled = true,
                    },
                }
            }
        }
    }
end

-- Example custom server
-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

if lspconfig ~= nil and lsp_utils ~= nil then
    lspconfig.lua_ls.setup({
        on_attach = lsp_utils.on_attach,
        capabilities = lsp_utils.capabilities,
        settings = {
            Lua = {
                runtime = {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = 'LuaJIT',
                    -- Setup your lua path
                    path = runtime_path,
                },
                diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = { 'vim' },
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = vim.api.nvim_get_runtime_file('', true),
                    checkThirdParty = false,
                },
                -- Do not send telemetry data containing a randomized but unique identifier
                telemetry = {
                    enable = false,
                },
            },
        },
    })
end


-- To avoid that this config file gets even larger, some parts are in separate files and need to be included from here.
require("qftf")

require("config.keymaps")

-- vim: ts=4 sts=4 sw=4 et
