-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                        Mappings                          ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

local map = vim.keymap.set
-- General
map('n', '<leader>f<cr>', '<cmd>FzfLua resume<cr>', { desc = 'Find Resume' })
map('n', '<leader>fB', '<cmd>FzfLua builtin<cr>', { desc = 'Find Builtins' })
map('n', '<leader>fr', '<cmd>FzfLua oldfiles<cr>', { desc = 'Find Recent files' })
map('n', '<leader>fb', '<cmd>FzfLua buffers<cr>', { desc = 'Find Buffers' })
map('n', '<leader>ff', function()
  require("fzf-lua").files({ cwd = require("jobin.config.custom.git").get_git_root_buf() })
end, { desc = 'Find Files' })
map('n', '<leader>fF', '<cmd>FzfLua files<cr>', { desc = 'Find Files (cwd)' })
map('n', '<leader>fg', function()
  require("fzf-lua").git_files({ cwd = require("jobin.config.custom.git").get_git_root_buf() })
end, { desc = 'Find Git Files' })
map('n', '<leader>fG', '<cmd>FzfLua git_files<cr>', { desc = 'Find Git Files (cwd)' })
map('n', '<leader>fh', '<cmd>FzfLua helptags<cr>', { desc = 'Find Help' })
map('n', '<leader>fH', '<cmd>FzfLua highlights<cr>', { desc = 'Find Highlight' })
map('n', '<leader>fc', '<cmd>FzfLua grep_cword<cr>', { desc = 'Find word under Cursor' })
map('n', '<leader>fw', function()
  require("fzf-lua").live_grep({ cwd = require("jobin.config.custom.git").get_git_root_buf() })
end, { desc = 'Find words (root)' })
map('n', '<leader>fW', '<cmd>FzfLua live_grep<cr>', { desc = 'Find words (cwd)' })
map('n', '<leader>fC', '<cmd>FzfLua commands<cr>', { desc = 'Find Commands' })
map('n', '<leader>fk', '<cmd>FzfLua keymaps<cr>', { desc = 'Find Keymaps' })
map('n', "<leader>f'", '<cmd>FzfLua marks<cr>', { desc = 'Find Marks' })
map('n', "<leader>fm", '<cmd>FzfLua manpages<cr>', { desc = 'Find Man Pages' })
map('n', '<leader>ft', '<cmd>FzfLua colorschemes<cr>', { desc = 'Find Themes' })
map('n', '<leader>f/', '<cmd>FzfLua blines<cr>', { desc = 'Buffer Search' })

-- git
map('n', '<leader>gb', '<cmd>FzfLua git_branches<cr>', { desc = 'Git Branches' })
map('n', '<leader>gt', '<cmd>FzfLua git_status<cr>', { desc = 'Git Status' })
map('n', '<leader>gc', '<cmd>FzfLua git_commits<cr>', { desc = 'Git Commits' })
map({ 'n', 'v' }, '<leader>gC', '<cmd>FzfLua git_bcommits<cr>', { desc = 'Git Buffer Commits' })

-- custom
map('n', '<leader>fA', '<cmd>FzfLua files cwd=~/playground/projects/config-setup<cr>',
  { desc = 'Find Config Setup' })
map('n', '<leader>fa', function()
  require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
end, { desc = 'Find Config' })
map('n', '<leader>fd', function()
  require("fzf-lua").files({
    cwd = "$HOME",
    hidden = false,
    cwd_prompt = false,
    prompt = "~/",
    cmd =
    "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME ls-tree --name-only --full-tree -r HEAD"
  })
end, { desc = 'Find Dotfiles' })
map('n', '<leader>fz', function() require('fzf-lua').zoxide() end, { desc = 'Find Zoxide' })
map('n', '<leader>fp', function()
  require("jobin.config.custom.fzf.pickers").fzf_cd_dir("find ~/playground/projects -maxdepth 1 -mindepth 1 -type d")
end, { desc = 'Find Projects' })
map('n', '<leader>fP', '<cmd>FzfLua profiles<cr>', { desc = 'Find profiles' })
map('n', '<leader>fl', function()
  require("fzf-lua").files({ cwd = vim.fs.joinpath(vim.fn.stdpath('data'), 'site', 'pack', 'core', 'opt') })
end, { desc = 'Find plugin' })
map('n', '<leader>fM', function()
  require("jobin.config.custom.fzf.pickers").fzf_move_file()
end, { desc = 'Move File' })
map('n', '<leader>fI', function()
  require("jobin.config.custom.fzf.pickers").fzf_icons()
end, { desc = 'Pick Icon' })

-- Second brain
map('n', '<leader>fss', function()
  require("jobin.config.custom.fzf.pickers").fzf_second_brain()
end, { desc = 'Find Second brain files' })
map('n', '<leader>fsi', function()
  require("jobin.config.custom.fzf.pickers").fzf_read_file({
    cwd =
    "~/playground/second_brain/Resources/Templates/"
  })
end, { desc = 'Insert Second brain Templates' })

-- Orgmode
map('n', '<leader>fot', function()
  require("jobin.config.custom.fzf.pickers").fzf_org_live_grep(vim.g.org_files.personal)
end, { desc = 'Org Todo grep' })
map('n', '<leader>fof', function()
  require("fzf-lua").files({ cwd = vim.g.org_files.personal })
end, { desc = 'Org files' })


-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                         Plugin                           ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛


vim.pack.add({
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/nvim-tree/nvim-web-devicons',
}, { confirm = false })


-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                          Setup                           ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛


local actions = require "fzf-lua.actions"
local my_actions = require "jobin.config.custom.fzf.actions"

local horizontal_winopts = {
  preview = {
    layout = "vertical",
    vertical = "down:65%",
  }
}

require("fzf-lua").setup({
  "default-title",
  actions = {
    files = {
      true,
      ["ctrl-y"] = { fn = my_actions.copy_entry, exec_silent = true },
      ["alt-r"] = { fn = actions.arg_add, exec_silent = true },
    },
  },
  winopts = {
    preview = {
      vertical = "down:45%",
      horizontal = "right:45%",
    },

  },
  keymap = {
    fzf = {
      true, -- inherit from defaults
      ["ctrl-q"] = "select-all+accept",
      ["ctrl-x"] = "jump",
    },
  },
  fzf_opts = {
    ["--style"] = 'default',
    ["--info"] = 'inline-right',
  },
  previewers = {
    builtin = {
      syntax_limit_b = 1024 * 100, -- 100KB
    },
  },
  defaults = {
    git_icons = false,
    file_icons = false,
    color_icons = false,
  },
  files = {
    actions = {
      ["alt-h"] = actions.toggle_hidden,
      ["alt-i"] = actions.toggle_ignore,
    }
  },
  git = {
    diff = { winopts = horizontal_winopts },
    status = { winopts = horizontal_winopts },
    commits = { winopts = horizontal_winopts },
    bcommits = { winopts = horizontal_winopts },
  },
  grep = {
    rg_glob = true,
    glob_flag = "--iglob",
    glob_separator = "%s%-%-",
    -- first returned string is the new search query
    -- second returned string are (optional) additional rg flags
    -- @return string, string?
    rg_glob_fn = function(query, opts)
      local regex, flags = query:match("^(.-)%s%-%-(.*)$")
      -- If no separator is detected will return the original query
      return (regex or query), flags
    end,
    actions = {
      ["alt-h"] = actions.toggle_hidden,
      ["alt-i"] = actions.toggle_ignore,
    }
  },
  hls = {
    backdrop = 'Normal',
    border = 'Normal',
    preview_border = 'Normal',
  }
})

-- use fzf-lua for vim.ui.select
require("fzf-lua").register_ui_select()
