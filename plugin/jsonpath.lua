vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('jobin/filetype', { clear = false }),
  once = true,
  pattern = {
    'json',
  },
  callback = function()
    vim.pack.add({ 'https://github.com/phelipetls/jsonpath.nvim' }, { confirm = false })
    require('jsonpath').setup()
  end
})
