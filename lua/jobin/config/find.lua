vim.api.nvim_create_autocmd("CmdlineChanged", {
  group = vim.api.nvim_create_augroup('jobin/CmdLineChanged', { clear = true }),
  pattern = ":",
  callback = function()
    vim.fn.wildtrigger()
  end
})

-- function _G.my_find(text, _)
--   local files = vim.fn.glob("**/*", false, true)
--   return vim.fn.matchfuzzy(files, text)
-- end

-- vim.opt.findfunc = "v:lua.my_find"
