-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                      User Commands                       ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

vim.api.nvim_create_user_command("Format", function(opts)
  local subcommand_key = opts.fargs[1]
  if subcommand_key == 'disable' then
    if opts.bang then
      -- FormatDisable! will disable formatting just for this buffer
      vim.b.disable_autoformat = true
    else
      vim.g.disable_autoformat = true
    end
  elseif subcommand_key == 'enable' then
    vim.b.disable_autoformat = false
    vim.g.disable_autoformat = false
  else
    vim.notify("Format: Unknown command: " .. subcommand_key, vim.log.levels.ERROR)
  end
end, {
  nargs = "+",
  desc = "Enable/Disable format on save",
  complete = function(arg_lead, cmdline, _)
    local arg_list = vim.split(cmdline, '%s+')
    if #arg_list >= 3 then return end

    local subcommand_keys = { 'enable', 'disable' }
    return vim.iter(subcommand_keys)
        :filter(function(key)
          return key:find(arg_lead) ~= nil
        end)
        :totable()
  end,
  bang = true, -- If you want to support ! modifiers
})


-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                         Keymap                           ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛


vim.keymap.set('n', '<leader>lf',
  function()
    require('conform').format({ async = true })
  end,
  { desc = 'Format Buffer' })


-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                         Plugin                           ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛


vim.pack.add({
  'https://github.com/stevearc/conform.nvim',
}, { confirm = false })


-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                          Setup                           ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛


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
  },
  format_on_save = function(bufnr)
    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 500, lsp_format = "fallback" }
  end,
})
