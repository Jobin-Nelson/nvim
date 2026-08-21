-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                      Autocommands                        ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('LspAttachKeyMaps', { clear = true }),
  callback = function(args)
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, { buffer = args.buf, desc = desc })
    end

    map('gd', vim.lsp.buf.definition, 'Goto [D]efinition')
    map('gD', vim.lsp.buf.declaration, 'Goto [D]eclaration')
    map('<leader>lq', vim.diagnostic.setloclist, 'Set diagnostic quickfix')

    map('<leader>lwa', vim.lsp.buf.add_workspace_folder, 'Lsp Workspace Add folder')
    map('<leader>lwr', vim.lsp.buf.remove_workspace_folder, 'Lsp Workspace Remove folder')
    map('<leader>lwl', function()
      vim.notify(
        vim.inspect(vim.lsp.buf.list_workspace_folders()),
        vim.log.levels.INFO,
        { title = 'LSP' }
      )
    end, 'Lsp Workspace List folders')

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    -- Native Completion
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end

    if client:supports_method('textDocument/codeLens') then
      map('<leader>ll', require('jobin.config.custom..ui').toggle_codelens, 'Toggle Codelens')
      -- vim.lsp.codelens.enable()
    end
  end,
  desc = 'Create keymaps for lsp attached buffers',
})

vim.api.nvim_create_autocmd({ "LspDetach" }, {
  group = vim.api.nvim_create_augroup("jobin/LspStopWithLastClient", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or not client.attached_buffers then return end
    for buf_id in pairs(client.attached_buffers) do
      if buf_id ~= args.buf then return end
    end
    client:stop(true)
  end,
  desc = "Stop lsp client when no buffer is attached",
})


-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                       Diagnostic                         ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛


vim.diagnostic.config {
  signs = {
    text = {
      [1] = '', -- ERROR
      [2] = '', -- WARN
      [3] = '', -- INFO
      [4] = '', -- HINT
    },
    numhl = {
      [1] = "DiagnosticError",
      [2] = "DiagnosticWarn",
    }
  },
  virtual_lines = false,
  virtual_text = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = true,
    style = "minimal",
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
  },
  jump = { float = true }
}


-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                       Lsp Config                         ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛


-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.workspace.fileOperations = {
--   didCreate = true,
--   didRename = true,
--   didDelete = true,
--   willCreate = true,
--   willRename = true,
--   willDelete = true,
-- }
-- vim.lsp.config('*', {
--   capabilities = capabilities
-- })

local servers = {
  'lua_ls',
  'jsonls',
  'yamlls',
  -- 'bashls',
  'astro',
  'marksman',
  'nil_ls',
  'pyright',
  -- 'ruff',
  'vtsls',
  'tailwindcss',
  -- 'emmet_language_server',
  'tinymist',
}

vim.lsp.enable(servers)
