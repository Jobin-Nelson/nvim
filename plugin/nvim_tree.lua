-- mappings
vim.keymap.set('n', '<leader>e',
  function() require("nvim-tree.api").tree.toggle({find_file=true, path=require("jobin.config.custom.git").get_git_root_buf() or vim.fn.expand("%:p:h")}) end,
  { desc = 'Open Explorer' })
vim.keymap.set('n', '<leader>E',
  function() require("nvim-tree.api").tree.toggle({file_file=true, path=vim.uv.cwd()}) end,
  { desc = 'Open Explorer (cwd)' })

vim.pack.add({
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/nvim-tree/nvim-web-devicons',
}, { confirm = false })

-- Lsp aware renames
local api = require("nvim-tree.api")
local Event = api.events.Event

api.events.subscribe(Event.WillRenameNode, function(data)
  local changes = {
    files = { {
      oldUri = vim.uri_from_fname(data.old_name),
      newUri = vim.uri_from_fname(data.new_name)
    } }
  }

  -- Let lsp know about the rename
  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    if client.supports_method("workspace/willRenameFiles") then
      local res = client.request_sync("workspace/willRenameFiles", changes, 1000, 0)
      if res and res.result ~= nil then
        vim.lsp.util.apply_workspace_edit(res.result, client.offset_encoding)
      end
    end
  end
end)
api.events.subscribe(Event.NodeRenamed, function(data)
  local changes = {
    files = { {
      oldUri = vim.uri_from_fname(data.old_name),
      newUri = vim.uri_from_fname(data.new_name)
    } }
  }
  -- Let lsp know that file has been renamed
  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    if client.supports_method("workspace/didRenameFiles") then
      client.notify("workspace/didRenameFiles", changes)
    end
  end
end)

-- Setup h, l keybinds
local function on_attach(bufnr)
  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)

  vim.keymap.set('n', 'l', api.node.open.no_window_picker, opts('Open'))
  vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
end

require('nvim-tree').setup({
  on_attach = on_attach,
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  view = {
    relativenumber = true,
  },
  renderer = {
    indent_markers = {
      enable = true,
    },
  },
  git = { enable = false },
  diagnostics = { enable = false },
})
