vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open parent directory' })

vim.pack.add({
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
}, { confirm = false })

local detail = false
require('oil').setup({
  default_file_explorer = true,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  keymaps = {
    ['gy'] = 'actions.yank_entry',
    ['<C-s>'] = { 'actions.select', opts = { vertical = true } },
    ['<C-x>'] = { 'actions.select', opts = { horizontal = true } },
    ["gd"] = {
      desc = "Toggle file detail view",
      callback = function()
        detail = not detail
        if detail then
          require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
        else
          require("oil").set_columns({ "icon" })
        end
      end,
    },
  },
  view_options = {
    natural_order = "fast",
    show_hidden = true,
  },
  win_options = {
    wrap = true,
  },
})
