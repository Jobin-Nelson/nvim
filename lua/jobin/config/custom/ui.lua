local M = {}

local function bool2str(bool) return bool and "on" or "off" end

function M.set_indent()
  vim.ui.input({
    prompt = "Set indent value (>0 expandtab, <=0 noexpandtab): ",
  }, function(new_indent)
    new_indent = tonumber(new_indent)
    if new_indent == nil or new_indent == 0 then
      return
    end

    vim.bo.expandtab = (new_indent > 0)
    new_indent = math.abs(new_indent)
    vim.bo.tabstop = new_indent
    vim.bo.softtabstop = new_indent
    vim.bo.shiftwidth = new_indent
    vim.notify("Indent set to " .. new_indent, vim.log.levels.INFO, { title = 'UI' })
  end)
end

function M.toggle_spell()
  vim.wo.spell = not vim.wo.spell
  vim.notify("Spell set to " .. bool2str(vim.wo.spell), vim.log.levels.INFO, { title = 'UI' })
end

function M.toggle_diagnostics()
  if vim.diagnostic.is_enabled() then
    vim.diagnostic.enable(false)
    vim.notify('Diagnostics Disabled', vim.log.levels.INFO, { title = 'UI' })
  else
    vim.diagnostic.enable()
    vim.notify('Diagnostics Enabled', vim.log.levels.INFO, { title = 'UI' })
  end
end

function M.toggle_transparency()
  local transparent_hl = { bg = 'None', ctermbg = 'None' }
  local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  local normalnc_hl = vim.api.nvim_get_hl(0, { name = 'NormalNC', link = false })
  local normalfloat_hl = vim.api.nvim_get_hl(0, { name = 'NormalFloat', link = false })
  local msg = ''

  ---@diagnostic disable-next-line: undefined-field
  if vim.tbl_isempty(normal_hl) or (normal_hl.bg == nil and normal_hl.ctermbg == nil) then
    vim.cmd.colorscheme(vim.g.colors_name or 'default')

    local status_hl = vim.api.nvim_get_hl(0, { name = 'StatusLine', link = false })
    status_hl = vim.tbl_extend('force', status_hl, { bold = true })
    vim.api.nvim_set_hl(0, "StatusLine", status_hl)
    msg = 'Transparency Disabled'
  else
    normal_hl = vim.tbl_extend('force', normal_hl, transparent_hl)
    normalnc_hl = vim.tbl_extend('force', normalnc_hl, transparent_hl)
    normalfloat_hl = vim.tbl_extend('force', normalfloat_hl, transparent_hl)
    vim.api.nvim_set_hl(0, 'Normal', normal_hl)
    vim.api.nvim_set_hl(0, 'NormalNC', normalnc_hl)
    vim.api.nvim_set_hl(0, 'NormalFloat', normalfloat_hl)
    vim.api.nvim_set_hl(0, "StatusLine", { bold = true })
    vim.api.nvim_set_hl(0, 'SignColumn', transparent_hl)
    -- vim.api.nvim_set_hl(0, 'WinSeparator', { cterm = nil })

    vim.api.nvim_set_hl(0, 'NvimTreeNormal', { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'NvimTreeEndOfBuffer', { link = 'Normal' })

    msg = 'Transparency Enabled'
  end

  vim.notify(msg, vim.log.levels.INFO, { title = 'UI' })
end

function M.custom_fold_text()
  local line = vim.fn.getline(vim.v.foldstart)
  local line_count = vim.v.foldend - vim.v.foldstart + 1
  local line_count_text = ("  %d lines "):format(line_count)
  local win_width = vim.api.nvim_win_get_width(0)
  -- 3  - ellipsis width
  -- 13 - line_count width (max 3 digits)
  -- 10 - right padding width
  local foldtext_start = line:sub(1, win_width - 3 - 13 - 10) .. "  "
  local foldtext_end = line_count_text
  local foldtext_length = vim.fn.strdisplaywidth(foldtext_start .. foldtext_end)
  return foldtext_start .. (" "):rep(win_width - foldtext_length - 10) .. foldtext_end
end

function M.toggle_virtual_lines()
  vim.diagnostic.config({
    virtual_lines = not vim.diagnostic.config().virtual_lines
  })
end

function M.toggle_codelens()
  vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled())
end

return M
