-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', { command = 'source <afile> | PackerCompile', group = packer_group, pattern = 'init.lua' })

--#region helper functions
--#endregion

--#region plugins
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Package manager
  use 'folke/which-key.nvim'
  use 'tpope/vim-repeat'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-abolish'
  use 'tpope/vim-unimpaired'
  use 'tpope/vim-obsession'
  use 'tpope/vim-surround'
  use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
  -- use 'ludovicchabant/vim-gutentags' -- Automatic tags management
  -- UI to select things (files, grep results, open buffers...)
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use 'mjlbach/onedark.nvim' -- Theme inspired by Atom
  use 'nvim-lualine/lualine.nvim' -- Fancier statusline
  -- Add indentation guides even on blank lines
  use 'lukas-reineke/indent-blankline.nvim'
  -- Add git related info in the signs columns and popups
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  -- Highlight, edit, and navigate code using a fast incremental parsing library
  use 'nvim-treesitter/nvim-treesitter'
  -- Additional textobjects for treesitter
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use 'ray-x/lsp_signature.nvim'
  -- Autocompletion plugin
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip' -- Snippets plugin
  use 'rafamadriz/friendly-snippets'
  use {
    "junegunn/vim-easy-align",
    cmd = { "EasyAlign" },
  }
  use {
      "vim-scripts/ReplaceWithRegister",
  }
  use {
      "nvim-telescope/telescope-live-grep-raw.nvim",
  }
	use {
			"farmergreg/vim-lastplace",
	}
  use {
    "mhinz/vim-sayonara",
    cmd = { "Sayonara" },
  }

end)
--#endregion

--Set highlight on search
vim.o.hlsearch = false

--Make line numbers default
vim.wo.number = true

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

--Set colorscheme
vim.o.termguicolors = true
vim.cmd [[colorscheme onedark]]

--Set clipboard to use system clipboard per default
vim.o.clipboard = "unnamedplus"

-- New splits shall be below or to the right
vim.o.splitbelow = true
vim.o.splitright = true

-- When doing command completion, do only complete as much as possible
-- and provide a list.
vim.o.wildmode = "longest:full,full"
vim.keymap.set('c', '<cr>', function()
  return vim.fn.pumvisible() == 1 and '<c-y>' or '<cr>'
end, {expr = true})
-- Interestingly enough, these won't work - nether their vimscript version
-- nor the lue version. So we stick with TAB for now...
-- vim.api.nvim_command([[ cnoremap <expr> <c-j> wildmenumode() ? "\<down>" : "\<c-j>" ]])
-- vim.api.nvim_command([[ cnoremap <expr> <c-k> wildmenumode() ? "\<up>" : "\<c-k>" ]])

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Ignore eol in visual block mode and allow having the cursor
-- one char after the end of the line
vim.o.virtualedit = "block,onemore"

-- Detect when a file is changed
vim.o.autoread = true

--Set statusbar
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'onedark',
    component_separators = '|',
    section_separators = '',
  },

  extensions = {},
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {}
  },
  sections = {
    lualine_a = { "mode", "vim.o.paste and 'PASTE' or ''" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename" },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" }
  },
  tabline = {}
}

-- Use treesitter for folding
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldenable = false

--Enable Comment.nvim
require('Comment').setup()

--Remap comma as leader key
vim.keymap.set({ 'n', 'v' }, ',', '<Nop>', { silent = true })
vim.g.mapleader = ','
vim.g.maplocalleader = ','

--Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Don't copy the replaced text after pasting in visual mode
vim.keymap.set("v", "p", "p:let @+=@0<CR>")

-- Don't yank text on cut ( x )
vim.keymap.set({ "n", "v" }, "x", '"_x')

-- Avoid the escape key http://vim.wikia.com/wiki/Avoid_the_escape_key
vim.keymap.set('i', 'jk', '<esc>')
vim.keymap.set('i', 'kj', '<esc>')

--#region autocommands

-- Reload file after change
    -- https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/149214
    -- Triger `autoread` when files changes on disk
    -- https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
    -- https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
    -- https://vi.stackexchange.com/questions/14315/how-can-i-tell-if-im-in-the-command-window
    -- getcmdwintype() returns a non-empty string if current window is the commandline window.
vim.api.nvim_create_autocmd({"FocusGained","BufEnter","CursorHold","CursorHoldI"}, {
  command = "if mode() != 'c' && getcmdwintype() == '' | checktime | endif" })

-- Notification after file change
  -- https://vi.stackexchange.com/questions/13091/autocmd-event-for-autoread
vim.api.nvim_create_autocmd({"FileChangedShellPost"}, {
  command = "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl"})

-- Automatically reload buffers when re-entering vim.
vim.api.nvim_create_autocmd({"BufWinLeave"}, { command = "let b:winview = winsaveview()"})
vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  command = "if exists('b:winview') | call winrestview(b:winview) | unlet b:winview"})

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
--#endregion

--Map blankline
vim.g.indent_blankline_char = '┊'
vim.g.indent_blankline_filetype_exclude = { 'help', 'packer' }
vim.g.indent_blankline_buftype_exclude = { 'terminal', 'nofile' }
vim.g.indent_blankline_show_trailing_blankline_indent = false

-- Gitsigns
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}

-- Telescope
local actions = require('telescope.actions')
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-k>'] = actions.move_selection_previous,
        ['<C-j>'] = actions.move_selection_next,
        ['<C-l>'] = actions.cycle_history_next,
        ['<C-h>'] = actions.cycle_history_prev,
      },
    },
  },
}

-- Enable telescope fzf native
require('telescope').load_extension 'fzf'

--Add leader shortcuts via whichkey
local function whichkey_setup()

  local present, wk = pcall(require, "which-key")
  if not present then
     return
  end

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
          b = { "<cmd>Telescope buffers<cr>", "buffer" },
          e = { "<cmd>NvimTreeFocus<cr>", "explore" },
          f = { "<cmd>Telescope fd<cr>", "file" },
          -- g = { "<cmd>Telescope live_grep<cr>", "grep" },
          g = { "<cmd>lua require(\"telescope\").extensions.live_grep_raw.live_grep_raw()<cr>", "grep" },
          t = { "<cmd>Telescope tags<cr>", "tag" },
          [':'] = { "<cmd>Telescope command_history<cr>", "command history" },
          ['*'] = { "<cmd>Telescope grep_string<cr>", "word in files" },
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
          a = { "<cmd>EasyAlign<cr>", "align" },
          f = { "<cmd>lua vim.lsp.buf.range_formatting()<cr>", "format" },
          m = { "<cmd>lua require('telescope.builtin').lsp_code_actions()<cr>", "menu" },
          r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "rename" },
      }, }, leader_normal)
  wk.register({
      r = {
          name = "refactor",
          a = { "<cmd>EasyAlign<cr>", "align" },
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

  function toggle_autocomplete()
    local cmp = require 'cmp'
    if (cmp.get_config()['completion']['autocomplete'] == false) then
      local types = require('cmp.types')
      cmp.setup({ completion = { autocomplete={ types.cmp.TriggerEvent.TextChanged, }}})
    else
      cmp.setup({ completion = { autocomplete=false }})
    end
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
whichkey_setup()


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

-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true, -- false will disable the whole extension
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = nil,
      node_incremental = nil,
      scope_incremental = 'ga',
      node_decremental = nil,
    },
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  },
}


-- LSP settings
local lspconfig = require 'lspconfig'
local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wl', function()
    vim.inspect(vim.lsp.buf.list_workspace_folders())
  end, opts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>so', require('telescope.builtin').lsp_document_symbols, opts)
  vim.api.nvim_create_user_command("Format", vim.lsp.buf.formatting, {})
end

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- For pyright, try to adapt for venv
local util = require('lspconfig/util')
local path = util.path

local function get_python_path(workspace)
  -- Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then
    return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
  end

  -- Find and use virtualenv in workspace directory.
  for _, pattern in ipairs({'*', '.*'}) do
    local match = vim.fn.glob(path.join(workspace, pattern, 'pyvenv.cfg'))
    if match ~= '' then
      return path.join(path.dirname(match), 'bin', 'python')
    end
  end

  -- Fallback to system Python.
  return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

lspconfig.pyright.setup({
  before_init = function(_, config)
    config.settings.python.pythonPath = get_python_path(config.root_dir)
  end,
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Enable the following language servers
local servers = { 'clangd', 'rust_analyzer', 'tsserver' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end




-- Example custom server
-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

lspconfig.sumneko_lua.setup {
  on_attach = on_attach,
  capabilities = capabilities,
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
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

-- nvim-cmp setup
local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp_setup = function()
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'
  -- make luasnip aware of the friendly-snippets
  require("luasnip.loaders.from_vscode").lazy_load()
  cmp.setup {
     completion = {
      completeopt = 'menu,menuone,preview',
      autocomplete = false,
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    formatting = {
      format = function(entry, vim_item)
        -- local icons = require "plugins.configs.lspkind_icons"
        -- vim_item.kind = string.format("%s %s", icons[vim_item.kind], vim_item.kind)
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          nvim_lua = "[Lua]",
          buffer = "[BUF]",
        })[entry.source.name]
        return vim_item
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-j>'] = cmp.mapping.select_next_item(),
      ['<C-k>'] = cmp.mapping.select_prev_item(),
      ['<C-d>'] = cmp.mapping.scroll_docs(4),
      ['<C-u>'] = cmp.mapping.scroll_docs(-4),

      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
      ['<esc>'] = cmp.mapping.abort(),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    sources = {
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = "buffer" },
      { name = "nvim_lua" },
      { name = "path" },
    },
  }
end
cmp_setup()

-- vim: ts=2 sts=2 sw=2 et
