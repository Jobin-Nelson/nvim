vim.keymap.set('n', '<leader>p', '<cmd>PasteImage<cr>', { desc = 'Paste image from system clipboard' })

vim.pack.add({ 'https://github.com/HakonHarnes/img-clip.nvim' }, { confirm = false })

require('img-clip').setup({
  -- add options here
  -- or leave it empty to use the default settings
  dir_path = function()
    if vim.api.nvim_buf_get_name(0):match('second_brain') then
      return 'Resources/attachments'
    end

    return 'assets'
  end
})
