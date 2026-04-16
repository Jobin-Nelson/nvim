-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                      User Commands                       ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

---@class MyCmdSubcommand
---@field impl fun(args:string[], opts: table) The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback, taking the lead of the subcommand's arguments

---@type table<string, MyCmdSubcommand>
local subcommand_tbl = {
  disable = {
    impl = function(_, opts)
      ---@diagnostic disable-next-line: undefined-field
      if opts.bang then
        -- FormatDisable! will disable formatting just for this buffer
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end,
  },
  enable = {
    impl = function(_, _)
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end,
  },
}

---@param opts table :h lua-guide-commands-create
local function my_cmd(opts)
  local fargs = opts.fargs
  local subcommand_key = fargs[1]
  -- Get the subcommand's arguments, if any
  local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
  local subcommand = subcommand_tbl[subcommand_key]
  if not subcommand then
    vim.notify("Format: Unknown command: " .. subcommand_key, vim.log.levels.ERROR)
    return
  end
  -- Invoke the subcommand
  subcommand.impl(args, opts)
end

vim.api.nvim_create_user_command("Format", my_cmd, {
  nargs = "+",
  desc = "Enable/Disable format on save",
  complete = function(arg_lead, cmdline, _)
    -- Get the subcommand.
    local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*Format[!]*%s(%S+)%s(.*)$")
    if subcmd_key
        and subcmd_arg_lead
        and subcommand_tbl[subcmd_key]
        and subcommand_tbl[subcmd_key].complete
    then
      -- The subcommand has completions. Return them.
      return subcommand_tbl[subcmd_key].complete(subcmd_arg_lead)
    end
    -- Check if cmdline is a subcommand
    if cmdline:match("^['<,'>]*Format[!]*%s+%w*$") then
      -- Filter subcommands that match
      local subcommand_keys = vim.tbl_keys(subcommand_tbl)
      return vim.iter(subcommand_keys)
          :filter(function(key)
            return key:find(arg_lead) ~= nil
          end)
          :totable()
    end
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
