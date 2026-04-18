vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('jobin/filetype', { clear = false }),
  once = true,
  pattern = {
    'typescript',
    'javascript',
    'typescriptreact',
    'javascriptreact'
  },
  callback = function()
    vim.pack.add({
      'https://github.com/yioneko/nvim-vtsls',
    }, { confirm = false })
  end
})
