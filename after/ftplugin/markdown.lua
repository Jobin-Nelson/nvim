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


-- keymaps
vim.keymap.set('n', '<C-Space>', toggle_checkbox, { desc = 'Toggle Checkbox', buffer = 0 })
vim.keymap.set('n', 'g{', jump_to_parent_header, { desc = "Parent Header" })
vim.keymap.set('n', '[{', function() jump_to_sibling_header("prev") end, { desc = "Prev Sibling Header" })
vim.keymap.set('n', ']}', function() jump_to_sibling_header("next") end, { desc = "Next Sibling Header" })
