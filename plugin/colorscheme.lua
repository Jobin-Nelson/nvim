vim.pack.add({
  "https://github.com/folke/tokyonight.nvim",
}, { confirm = false })

require('tokyonight').setup()

vim.cmd('colo tokyonight-night')
