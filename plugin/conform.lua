vim.pack.add({
  'https://github.com/stevearc/conform.nvim',
}, { confirm = false })

vim.keymap.set('n', '<leader>lf',
  function()
    require('conform').format({ async = true })
  end,
  { desc = 'Format Buffer' } )

require('conform').setup({
  formatters_by_ft = {
    javascript = { 'prettier' },
    json = { 'jq' },
    sh = { 'shfmt' },
    astro = { 'prettier' },
    markdown = { 'prettier' },
    nix = { 'nixfmt' },
    python = { 'ruff_format', 'ruff_organize_imports' },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
  },
  default_format_opts = {
    lsp_format = 'fallback',
  },
  formatters = {
    black = {
      prepend_args = { '--skip-string-normalization' },
    }
  }
})
