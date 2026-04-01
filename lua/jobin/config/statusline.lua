-- Note that: \19 = ^S and \22 = ^V.
local modes = {
  ['n'] = 'NORMAL',
  ['no'] = 'OP-PENDING',
  ['nov'] = 'OP-PENDING',
  ['noV'] = 'OP-PENDING',
  ['no\22'] = 'OP-PENDING',
  ['niI'] = 'NORMAL',
  ['niR'] = 'NORMAL',
  ['niV'] = 'NORMAL',
  ['nt'] = 'NORMAL',
  ['ntT'] = 'NORMAL',
  ['v'] = 'VISUAL',
  ['vs'] = 'VISUAL',
  ['V'] = 'VISUAL LINE',
  ['Vs'] = 'VISUAL',
  ['\22'] = 'VISUAL BLOCK',
  ['\22s'] = 'VISUAL',
  ['s'] = 'SELECT',
  ['S'] = 'SELECT LINE',
  ['\19'] = 'SELECT BLOCK',
  ['i'] = 'INSERT',
  ['ic'] = 'INSERT',
  ['ix'] = 'INSERT',
  ['R'] = 'REPLACE',
  ['Rc'] = 'REPLACE',
  ['Rx'] = 'REPLACE',
  ['Rv'] = 'VIRT REPLACE',
  ['Rvc'] = 'VIRT REPLACE',
  ['Rvx'] = 'VIRT REPLACE',
  ['c'] = 'COMMAND',
  ['cv'] = 'VIM EX',
  ['ce'] = 'EX',
  ['r'] = 'PROMPT',
  ['rm'] = 'MORE',
  ['r?'] = 'CONFIRM',
  ['!'] = 'SHELL',
  ['t'] = 'TERMINAL',
}

local icons = require('jobin.config.icons')

---@return string
local function vcs_component()
  ---@diagnostic disable-next-line: undefined-field
  local head = vim.b.gitsigns_head
  return head and string.format('%%#StatuslineGitBranch#%s %s', icons.git.Branch, head) or ''
end

---@return string
local function diff()
  ---@diagnostic disable-next-line: undefined-field
  local diff_info = vim.b.gitsigns_status_dict
  if not diff_info then return '' end
  return table.concat({
    (diff_info.added and diff_info.added ~= 0) and
    ("%%#%s#%s%s"):format('GitSignsAdd', icons.git.LineAdded, diff_info.added) or '',
    (diff_info.changed and diff_info.changed ~= 0) and
    ("%%#%s#%s%s"):format('GitSignsChange', icons.git.LineModified, diff_info.changed) or '',
    (diff_info.removed and diff_info.removed ~= 0) and
    ("%%#%s#%s%s"):format('GitSignsDelete', icons.git.LineRemoved, diff_info.removed) or '',
  }, ' ')
end

---@return string
local function mode_component()
  local mode = modes[vim.api.nvim_get_mode().mode] or 'UNKOWN'
  -- Set the highlight group.
  return string.format("%%#StatuslineMode# %s %s", icons.ui.Neovim, mode)
end

---@return string
local function file_component()
  local filetype = vim.bo.filetype
  if filetype == '' then
    filetype = '[No Name]'
  end

  local buf_name = vim.api.nvim_buf_get_name(0)
  local filename, ext = vim.fn.fnamemodify(buf_name, ':t'), vim.fn.fnamemodify(buf_name, ':e')

  local ok, nvim_web_devicons = pcall(require, 'nvim-web-devicons')
  local icon, icon_hl
  if not ok then
    icon = icons.kind.File
  else
    icon, icon_hl = nvim_web_devicons.get_icon(filename, ext)
    if not icon then
      icon, icon_hl = nvim_web_devicons.get_icon_by_filetype(filetype, { default = true })
    end
  end

  local is_modified = vim.api.nvim_get_option_value('modified', { buf = 0 }) and icons.ui.FileModified or ''
  local is_readonly = vim.api.nvim_get_option_value('readonly', { buf = 0 }) and icons.ui.FileReadOnly or ''
  return string.format('%%#%s#%s %%#StatuslineFilename# %s %s%s',
    icon_hl, icon, filename, is_modified, is_readonly)
end

local last_diagnostic_component = ''
---@return string
local function diagnostics()
  if vim.bo.filetype == 'lazy' then
    return ''
  end
  -- Use the last computed value if in insert mode.
  if vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
    return last_diagnostic_component
  end

  local counts = vim.diagnostic.count(0, {
    severity = {
      vim.diagnostic.severity.ERROR,
      vim.diagnostic.severity.WARN,
      vim.diagnostic.severity.INFO,
      vim.diagnostic.severity.HINT,
    }
  })

  local highlights = {
    ERROR = 'DiagnosticSignError',
    WARN = 'DiagnosticSignWarn',
    INFO = 'DiagnosticSignInfo',
    HINT = 'DiagnosticSignHint',
  }

  local diagnostic_counts = {
    ERROR = counts[vim.diagnostic.severity.ERROR] or 0,
    WARN = counts[vim.diagnostic.severity.WARN] or 0,
    INFO = counts[vim.diagnostic.severity.INFO] or 0,
    HINT = counts[vim.diagnostic.severity.HINT] or 0,
  }

  local parts = {}
  for severity, count in pairs(diagnostic_counts) do
    if count > 0 then
      table.insert(parts, string.format('%%#%s#%s %d',
        highlights[severity],
        icons.diagnostics[severity], count))
    end
  end

  last_diagnostic_component = table.concat(parts, ' ')
  return last_diagnostic_component
end

---@return string
local function lsp_component()
  local lsps = vim.tbl_map(function(client)
    return client.name
  end, vim.lsp.get_clients({ bufnr = 0 }))
  local res = {}
  if vim.list_contains(lsps, 'copilot') then table.insert(res, icons.kind.Copilot) end
  local lsps_string = vim.iter(lsps):filter(function(c) return c ~= 'copilot' end):join(',')
  if lsps_string ~= '' then table.insert(res, icons.misc.Servers .. lsps_string) end
  return '%#StatuslineLsp#' .. table.concat(res, '  ')
end

local M = {}

---@return string
function M.status()
  -- if vim.bo.filetype == 'alpha' then
  --   return ''
  -- end

  local filler = ' %= '
  -- local file_segment = '%(' .. fileicon() .. '%<%f %h%m%r%)'
  local line_info = '%#StatuslineProgress# '
      .. icons.ui.Location .. ' %3.(%l:%v%) '
      .. icons.ui.ProgressDown .. ' %P '
  local busy = "%{% &busy > 0 ? '◐ ' : '' %}%"
  local progress_status = vim.ui.progress_status()

  return table.concat({
    mode_component(),
    vcs_component(),
    diff(),
    filler,
    file_component(),
    filler,
    diagnostics(),
    lsp_component(),
    busy,
    progress_status,
    line_info,
  }, '  ')
end

---@type table<string, vim.api.keyset.highlight>
local statusline_highlights = {
  StatusLine = { link = 'Normal' },
  StatuslineMode = { bold = true },
  StatuslineProgress = { bold = true },
}

for group, opts in pairs(statusline_highlights) do
  vim.api.nvim_set_hl(0, group, opts)
end


-- vim.api.nvim_put({vim.opt.statusline:get()}, 'l', true, false)
-- "%<%f %h%w%m%r %{% v:lua.require('vim._core.util').term_exitcode() %}%=%{% luaeval('(package.loaded[''vim.ui''] and vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin or -1) and vim.ui.progress_status()) or '''' ')%}%{% &showcmdloc == 'statusline' ? '%-10.S ' : '' %}%{% exists('b:keymap_name') ? '<'..b:keymap_name..'> ' : '' %}%{% &busy > 0 ? '◐ ' : '' %}%{% luaeval('(package.loaded[''vim.diagnostic''] and next(vim.diagnostic.count()) and vim.diagnostic.status() .. '' '') or '''' ') %}%{% &ruler ? ( &rulerformat == '' ? '%-14.(%l,%c%V%) %P' : &rulerformat ) : '' %}'"

return M
