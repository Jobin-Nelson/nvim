local M = {}

---@param clients vim.lsp.ClientConfig
---@return vim.lsp.ClientConfig
local function not_copilot(clients)
  return vim.tbl_filter(function(client)
    return client.name ~= 'copilot'
  end, clients)
end

function M.stop_hidden_lsp()
  local active_lsp_ids = vim.tbl_map(function(lsp)
    return lsp.id
  end, vim.lsp.get_clients({
    bufnr = vim.api.nvim_get_current_buf()
  }))
  local inactive_lsps = vim.tbl_filter(function(lsp)
    return not vim.list_contains(active_lsp_ids, lsp.id)
  end, not_copilot(vim.lsp.get_clients()))
  vim.lsp.stop_client(inactive_lsps, true)
  vim.notify("All Inactive LSP's are stopped", vim.log.levels.INFO, { title = 'LSP' })
end

function M.display_active_lsp()
  local lsp_names = vim.tbl_map(function(lsp) return lsp.name end, vim.lsp.get_clients())
  vim.notify(
    ("#%s LSP: %s"):format(#lsp_names, table.concat(lsp_names, ', ')),
    vim.log.levels.INFO,
    { title = 'LSP' }
  )
end

function M.stop_lsp()
  vim.lsp.stop_client(not_copilot(vim.lsp.get_clients()), true)
  vim.notify("All LSP's are stopped", vim.log.levels.INFO, { title = 'LSP' })
end

return M
