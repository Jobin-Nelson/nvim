vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('jobin/filetype', { clear = false }),
  once = true,
  pattern = {
    'typst',
  },
  callback = function()
    vim.cmd.packadd('typst-preview')
  end
})

vim.pack.add({
  {
    src = 'https://github.com/chomosuke/typst-preview.nvim',
    version = vim.version.range('^1'),
  }
}, { load = false, confirm = false })
