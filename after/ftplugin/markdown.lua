-- Options
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.wrap = true
vim.opt.foldtext = "v:lua.require('jobin.config.custom.ui').custom_fold_text()"

-- Functions
local function jump_to_parent_header()
  local cursor_node = vim.treesitter.get_node()

  if not cursor_node then return end
  -- Climb up the tree until we find the section containing our current section
  ---@type TSNode?
  local current_section = cursor_node
  while current_section and current_section:type() ~= "section" do
    current_section = current_section:parent()
  end

  if not current_section then return end

  local parent_section = current_section:parent()
  if not parent_section or parent_section:type() ~= "section" then
    return vim.notify(
      "Already at the top-level header or no parent found.",
      vim.log.levels.WARN,
      { title = 'Markdown' }
    )
  end

  -- The first child of a section is always its heading
  local parent_header = parent_section:child(0)
  if parent_header then
    local row, col, _, _ = parent_header:range()
    vim.api.nvim_win_set_cursor(0, { row + 1, col })
  end
end


local function jump_to_sibling_header(direction)
  local node = vim.treesitter.get_node()
  if not node then return end

  -- 1. Find the current "section" node we are inside
  ---@type TSNode?
  local current_section = node
  while current_section and current_section:type() ~= "section" do
    current_section = current_section:parent()
  end

  if not current_section then return end

  -- 2. Find the next/previous sibling that is also a section
  local target_section
  if direction == "next" then
    target_section = current_section:next_sibling()
    -- Skip any non-section nodes (like blocks of text or whitespace)
    while target_section and target_section:type() ~= "section" do
      target_section = target_section:next_sibling()
    end
  else
    target_section = current_section:prev_sibling()
    while target_section and target_section:type() ~= "section" do
      target_section = target_section:prev_sibling()
    end
  end

  -- 3. Jump to the heading of that target section
  if target_section then
    local header = target_section:child(0) -- The heading is always the first child
    if header then
      local row, col = header:range()
      vim.api.nvim_win_set_cursor(0, { row + 1, col })
    end
  else
    vim.notify(
      "No more sibling headers found in this direction.",
      vim.log.levels.WARN,
      { title = 'Markdown' }
    )
  end
end


local function toggle_checkbox()
  local line = vim.api.nvim_get_current_line()
  local new_line
  if line:match('^%s*%- %[ %]') then
    new_line = line:gsub('%[ %]', '[x]', 1)
  elseif line:match('^%s*%- %[[xX]%]') then
    new_line = line:gsub('%[[xX]%]', '[ ]', 1)
  else
    return vim.notify(
      'Current line not a checkbox',
      vim.log.levels.WARN,
      { title = 'Markdown' }
    )
  end
  vim.api.nvim_set_current_line(new_line)
end

local function move_node_to_sibling_header(direction)
  local node = vim.treesitter.get_node()
  if not node then return end

  -- 1. Find the current "section" node we are inside
  ---@type TSNode?
  local current_section = node
  while current_section and current_section:type() ~= "section" do
    current_section = current_section:parent()
  end

  if not current_section then return end

  -- 2. Find the target section (next or previous)
  local target_section
  if direction == "next" then
    target_section = current_section:next_sibling()
    while target_section and target_section:type() ~= "section" do
      target_section = target_section:next_sibling()
    end
  else
    target_section = current_section:prev_sibling()
    while target_section and target_section:type() ~= "section" do
      target_section = target_section:prev_sibling()
    end
  end

  if not target_section then
    return vim.notify(
      "No more sibling headers found in this direction.",
      vim.log.levels.WARN,
      { title = 'Markdown' }
    )
  end

  -- 3. Determine the exact node/block to move
  local move_node
  local temp = node --[[@as TSNode?]]

  -- First, check if we are inside a list item. We grab the closest one.
  -- This ensures if you are on a nested list item, it grabs that item and its children.
  while temp and temp:parent() and temp:parent() ~= current_section do
    move_node = temp
    temp = temp:parent()
  end

  -- If we aren't in a list item, find the highest block-level child of the section
  -- (e.g., a whole paragraph, a code block, or a quote block)
  if not move_node then
    temp = node
    while temp and temp:parent() and temp:parent() ~= current_section do
      temp = temp:parent()
    end
    if temp and temp:type() ~= "section" then
      move_node = temp
    end
  end

  -- Fallback in case something went wrong, though unlikely in a valid markdown file
  if not move_node then move_node = node end

  -- 4. Get the full line range of the node
  vim.print(move_node:type())
  local start_row, _, end_row, _ = move_node:range()
  start_row = start_row + 1
  -- end_row = math.max(start_row, end_row - 1)

  -- 5. Determine insertion point under target header
  local insert_row = target_section:start()
  insert_row = insert_row + 1

  local cmd = ('silent %s,%smove %s'):format(start_row, end_row, insert_row)
  vim.cmd(cmd)
end

-- keymaps
vim.keymap.set('n', '<C-Space>', toggle_checkbox, { desc = 'Toggle Checkbox', buf = 0 })
vim.keymap.set('n', 'g{', jump_to_parent_header, { desc = "Parent Header", buf = 0 })
vim.keymap.set('n', '[{', function() jump_to_sibling_header("prev") end,
  { desc = "Jump to prev Sibling Header", buf = 0 })
vim.keymap.set('n', ']}', function() jump_to_sibling_header("next") end,
  { desc = "Jump to next Sibling Header", buf = 0 })
vim.keymap.set('n', '<leader>[', function() move_node_to_sibling_header("prev") end,
  { desc = "Move block to Prev Sibling Header", buf = 0 })
vim.keymap.set('n', '<leader>]', function() move_node_to_sibling_header("next") end,
  { desc = "Move block to Next Sibling Header", buf = 0 })
