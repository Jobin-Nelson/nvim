vim.pack.add({
  "https://github.com/folke/tokyonight.nvim",
}, { confirm = false })

require('tokyonight').setup({
  style = 'night',
  -- on_highlights = function(hl, c)
  --   hl.Folded = {
  --     bg = 'none',
  --     fg = c.comment
  --   }
  -- end
})

vim.cmd('colorscheme tokyonight')
