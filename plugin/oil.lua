vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open parent directory' })

vim.pack.add({
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
}, { confirm = false })

require('oil').setup({
  default_file_explorer = true,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  keymaps = {
    ['gy'] = 'actions.yank_entry',
    ['<C-v>'] = { 'actions.select', opts = { vertical = true }},
    ['<C-s>'] = { 'actions.select', opts = { horizontal = true }},
  },
  view_options = {
    natural_order = "fast",
    show_hidden = true,
  },
  win_options = {
    wrap = true,
  },
})
