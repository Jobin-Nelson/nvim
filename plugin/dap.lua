---@param config {args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
  config = vim.deepcopy(config)
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.input("Run with args: ", table.concat(args, " ")) --[[@as string]]
    return vim.split(vim.fn.expand(new_args) --[[@as string]], " ")
  end
  return config
end

require('jobin.config.lazy').ll_on_map(
  'n',
  '<leader>db',
  function() require("dap").toggle_breakpoint() end,
  function()
    vim.pack.add({
      {
        src = 'https://github.com/mfussenegger/nvim-dap',
        name = 'dap',
      },
      {
        src = 'https://github.com/rcarriga/nvim-dap-ui',
        name = 'dapui',
      },
      {
        src = 'https://github.com/nvim-neotest/nvim-nio',
      },
      {
        src = 'https://github.com/theHamsta/nvim-dap-virtual-text',
      },
      {
        src = 'https://github.com/mfussenegger/nvim-dap-python',
      }
    }, { confirm = false })
    vim.keymap.set('n', "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
    vim.keymap.set('n', "<leader>dc", function() require("dap").continue() end, { desc = "Continue" })
    vim.keymap.set('n', "<leader>da", function() require("dap").continue({ before = get_args }) end,
      { desc = "Run with Args" })
    vim.keymap.set('n', "<leader>dC", function() require("dap").run_to_cursor() end, { desc = "Run to Cursor" })
    vim.keymap.set('n', "<leader>dg", function() require("dap").goto_() end, { desc = "Go to Line (No Execute)" })
    vim.keymap.set('n', "<leader>di", function() require("dap").step_into() end, { desc = "Step Into" })
    vim.keymap.set('n', "<leader>dj", function() require("dap").down() end, { desc = "Down" })
    vim.keymap.set('n', "<leader>dk", function() require("dap").up() end, { desc = "Up" })
    vim.keymap.set('n', "<leader>dl", function() require("dap").run_last() end, { desc = "Run Last" })
    vim.keymap.set('n', "<leader>dO", function() require("dap").step_out() end, { desc = "Step Out" })
    vim.keymap.set('n', "<leader>do", function() require("dap").step_over() end, { desc = "Step Over" })
    vim.keymap.set('n', "<leader>dp", function() require("dap").pause() end, { desc = "Pause" })
    vim.keymap.set('n', "<leader>dr", function() require("dap").repl.toggle() end, { desc = "Toggle REPL" })
    vim.keymap.set('n', "<leader>ds", function() require("dap").session() end, { desc = "Session" })
    vim.keymap.set('n', "<leader>dt", function() require("dap").terminate() end, { desc = "Terminate" })
    vim.keymap.set('n', "<leader>dw", function() require("dap.ui.widgets").hover() end, { desc = "Widgets" })

    vim.keymap.set('n', "<leader>du", function() require("dapui").toggle({}) end, { desc = "Dap UI" })
    vim.keymap.set('n', "<leader>dr", function() require("dapui").open({ reset = true }) end, { desc = "Dap UI" })
    vim.keymap.set({ "n", "v" }, "<leader>de", function() require("dapui").eval() end, { desc = "Eval" })

    vim.keymap.set('n', '<leader>dv', '<cmd>DapVirtualTextToggle<cr>', { desc = 'Toggle Virtual text' })


    vim.keymap.set('n', "<leader>dPt", function() require('dap-python').test_method() end, { desc = "Debug Method" })
    vim.keymap.set('n', "<leader>dPc", function() require('dap-python').test_class() end, { desc = "Debug Class" })

    local dap = require("dap")
    local dapui = require("dapui")
    dapui.setup()

    dap.listeners.before.attach.dapui_config = dapui.open
    dap.listeners.before.launch.dapui_config = dapui.open
    dap.listeners.before.event_terminated.dapui_config = dapui.close
    dap.listeners.before.event_exited.dapui_config = dapui.close

    require('nvim-dap-virtual-text').setup({
      display_callback = function(variable)
        if #variable.value > 8 then
          return ' ' .. string.sub(variable.value, 1, 15) .. '... '
        end
        return ' ' .. variable.value
      end
    })

    vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })
    for name, sign in pairs(require 'jobin.config.icons'.dap) do
      vim.fn.sign_define(
        name,
        {
          text = sign,
          texthl = 'DiagnosticWarn',
          linehl = name == 'DapStopped' and 'DapStoppedLine' or nil,
        }
      )
    end

    require('dap-python').setup('uv')
  end, 'DAP')
