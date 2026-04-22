-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                         Options                          ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

-- General
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = false
vim.opt.wrap = false

-- Scroll
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.smoothscroll = true


-- Indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.breakindent = true
vim.opt.breakindentopt = 'list:2,min:20,sbr'
vim.opt.linebreak = true
-- vim.opt.showbreak = '↪ '

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Visual
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
vim.opt.showmode = false
vim.opt.pumheight = 10
vim.opt.pumblend = 0
vim.opt.completeopt = 'menu,menuone,noinsert,noselect,popup'
vim.opt.conceallevel = 2
vim.opt.synmaxcol = 300
vim.opt.virtualedit = 'block'
vim.opt.list = true
vim.opt.listchars = "tab:󰅂 ,trail:-,nbsp:+"
require('vim._core.ui2').enable({ msg = { target = 'cmd' } })


-- File handling
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('config') .. '/undodir'
vim.opt.updatecount = 0
vim.opt.autoread = true

-- Behavior
-- vim.opt.iskeyword:append('-')
-- vim.opt.path:append('**')
vim.opt.mouse = 'a'
vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard

-- Folding
vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
vim.o.foldcolumn = '0'
vim.opt.foldenable = true
vim.opt.foldlevelstart = 1
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = "v:lua.require('jobin.config.custom.ui').custom_fold_text()"

-- Split
vim.opt.splitkeep = 'screen'
vim.opt.splitbelow = true
vim.opt.splitright = true


-- Session
vim.opt.sessionoptions = 'curdir,folds,globals,help,tabpages,terminal,winsize'

-- Statusbar
-- vim.opt.statusline= "%<%=%(%f %h%m%r%)%=%-14.(%l,%c%V%) %P"
vim.opt.statusline = "%!v:lua.require('jobin.config.statusline').status()"
-- vim.opt.statuscolumn = '%=%s%{v:relnum?v:relnum:v:lnum } %C '
vim.opt.laststatus = 3
vim.opt.winbar = "%=%m %{expand('%:~:.')}"
vim.opt.winborder = 'rounded'

-- format
vim.opt.formatoptions = vim.opt.formatoptions
    - "a" -- Auto formatting is BAD.
    - "t" -- Don't auto format my code. I got linters for that.
    + "c" -- In general, I like it when comments respect textwidth
    + "q" -- Allow formatting comments w/ gq
    - "o" -- O and o, don't continue comments
    + "r" -- But do continue when pressing enter.
    + "n" -- Indent past the formatlistpat, not underneath it.
    + "j" -- Auto-remove comments if possible.
    - "2" -- I'm not in gradeschool anymore

-- disabled
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                       Colorscheme                        ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

-- vim.cmd('colorscheme cat')

-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                      Global Values                       ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

vim.g.git_worktrees = {
  {
    toplevel = vim.env.HOME,
    gitdir = vim.env.HOME .. "/.dotfiles",
  },
}
vim.g.org_files = {
  personal = vim.fs.normalize('~/playground/org_files')
}

-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                        Filetype                          ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

vim.filetype.add {
  filename = {
    ['.eslintrc.json'] = 'jsonc',
  },
  pattern = {
    ['tsconfig*.json'] = 'jsonc',
    ['.*/%.vscode/.*%.json'] = 'jsonc',
    -- Borrowed from LazyVim. Mark huge files to disable features later.
    ['.*'] = function(path, bufnr)
      return vim.bo[bufnr]
          and vim.bo[bufnr].filetype ~= 'bigfile'
          and path
          and vim.fn.getfsize(path) > (1024 * 500) -- 500 KB
          and 'bigfile'
          or nil
    end,
  },
}

vim.filetype.add({
  extension = {
    env = "dotenv",
  },
  filename = {
    [".env"] = "dotenv",
    ["env"] = "dotenv",
  },
  pattern = {
    ["[jt]sconfig.*.json"] = "jsonc",
    ["%.env%.[%w_.-]+"] = "dotenv",
  },
})
