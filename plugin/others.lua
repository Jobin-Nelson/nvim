vim.pack.add({
  'https://github.com/kylechui/nvim-surround',
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/b0o/schemastore.nvim',
  'https://github.com/windwp/nvim-autopairs',
  -- 'https://github.com/stevearc/dressing.nvim',
  -- { 'sindrets/diffview.nvim', cmd = { 'DiffviewFileHistory', 'DiffViewOpen' }, opts = {} },
  -- { 'tpope/vim-sleuth',       lazy = false },
}, { confirm = false })

require('nvim-surround').setup()
require('nvim-autopairs').setup()
