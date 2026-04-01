vim.pack.add({ 'https://github.com/folke/which-key.nvim' }, { confirm = false })

require('which-key').setup({
  icons = {
    mappings = false,
  },
  defaults = {
    preset = 'modern',
  },
  spec = {
    { "<leader>f", group = "Find",        nowait = true, remap = false },
    { "<leader>b", group = "Buffers",     nowait = true, remap = false },
    { "<leader>l", group = "Lsp",         nowait = true, remap = false },
    { "<leader>w", group = "Work",        nowait = true, remap = false },
    { "<leader>j", group = "Custom",      nowait = true, remap = false },
    { "<leader>g", group = "Git",         nowait = true, remap = false },
    { "<leader>d", group = "Debug",       nowait = true, remap = false },
    { "<leader>u", group = "UI",          nowait = true, remap = false },
    { "<leader>s", group = "Session",     nowait = true, remap = false },
    { "<leader>L", group = "LSP clients", nowait = true, remap = false },
  }
})

