local host_setup_fns = require('jobin.hosts')

local M = {}

---@param cmd_name string
---@param setup_fn fun()
---@param desc string
function M.ll_on_cmd(cmd_name, setup_fn, desc)
  vim.api.nvim_create_user_command(cmd_name, function(opts)
    -- Remove this dummy command so it doesn't conflict with the plugin's real command
    vim.api.nvim_del_user_command(cmd_name)

    -- Run setup if provided
    if setup_fn then
      setup_fn()
    end

    -- Re-run the command with the original arguments
    local args = opts.args ~= "" and (" " .. opts.args) or ""
    vim.cmd(cmd_name .. args)
  end, {
    bang = true,
    nargs = "*",
    range = true,
    desc = "Lazy load " .. desc .. " on command " .. cmd_name,
  })
end

---@param mode string
---@param lhs string
---@param rhs_or_fn string|fun()
---@param setup_fn fun()
---@param desc string
function M.ll_on_map(mode, lhs, rhs_or_fn, setup_fn, desc)
  vim.keymap.set(mode, lhs, function()
    -- 1. Remove the lazy keymap so it doesn't loop
    vim.keymap.del(mode, lhs)

    -- 2. Run setup if provided
    if setup_fn then
      setup_fn()
    end

    -- 3. Execute the actual logic
    if type(rhs_or_fn) == "function" then
      rhs_or_fn()
    else
      -- If it's a string (like a feedkeys or a command), execute it
      vim.api.nvim_input(rhs_or_fn)
    end
  end, { desc = "Lazy load " .. desc })
end

---@param opts table
---@param setup_fn string
function M.host_opts(opts, setup_fn)
  local fn = host_setup_fns[setup_fn]
  if fn then fn(opts) end
end

return M
