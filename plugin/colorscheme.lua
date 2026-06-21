vim.pack.add({
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/RRethy/base16-nvim",
  -- "https://github.com/D0nw0r/dark2026.nvim",
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

local function source_matugen()
  vim.cmd('colorscheme matugen')
  vim.notify('Applied matugen theme')
end

-- Register an autocmd to listen for matugen updates
vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  callback = source_matugen,
  group = vim.api.nvim_create_augroup('jobin/matugen', { clear = false }),
})


source_matugen()
