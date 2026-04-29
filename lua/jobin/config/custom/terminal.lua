local terminal_state = {
  buf = -1,
  win = -1,
}

local M = {}

local function term_open()
  if not vim.api.nvim_win_is_valid(terminal_state.win) then
    -- terminal_state = require('jobin.config.custom.utils').create_floating_window { buf = terminal_state.buf }
    terminal_state = require('jobin.config.custom.utils').create_bottom_window(terminal_state.buf)
    if vim.bo[terminal_state.buf].buftype ~= 'terminal' then
      vim.cmd.term()
    end
    vim.cmd.startinsert()
  end
end

function M.toggle_term()
  if not vim.api.nvim_win_is_valid(terminal_state.win) then
    term_open()
  else
    vim.api.nvim_win_hide(terminal_state.win)
  end
end

---@param mode "visual" | "normal"
function M.send_lines_term(mode)
  local modes = {
    visual = { 'v', '.' },
    normal = { '.', '.' },
  }
  local start_char, end_char = table.unpack(modes[mode])
  local lines = vim.api.nvim_buf_get_lines(
    0,
    vim.fn.line(start_char) - 1,
    vim.fn.line(end_char),
    false
  )
  -- open terminal if not visible
  term_open()

  local terminal = terminal_state
  local term_bufnr = terminal.buf
  local enter = '\n'
  assert(term_bufnr, 'ERROR: No terminal bufnr')

  -- strip trailing whitespaces
  while #lines > 0 and vim.trim(lines[#lines]) == "" do
    lines[#lines] = nil
  end
  -- send commands to terminal
  vim.api.nvim_chan_send(
    vim.bo[term_bufnr].channel,
    table.concat(lines, enter) .. enter
  )
  -- scroll to bottom
  vim.api.nvim_buf_call(term_bufnr, function()
    local info = vim.api.nvim_get_mode()
    if info and (info.mode == 'n' or info.mode == 'nt') then
      vim.cmd('normal! G')
    end
  end)
end

---@param cmd string[]
function M.send_lines_ext_term(cmd)
  require('jobin.config.custom.utils').apply_multimodal(function(input)
    vim.system(cmd, { stdin = input })
    return {}
  end)
end

vim.keymap.set({ 'n', 'v' }, '<leader>rt', function() M.send_lines_ext_term({ 'tmuxify.sh', '-r' }) end)
-- vim.keymap.set('n', '<leader>rr', ':update | luafile %<cr>')

return M
