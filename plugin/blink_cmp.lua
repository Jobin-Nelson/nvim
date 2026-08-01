vim.pack.add({
  {
    src = 'https://github.com/saghen/blink.cmp',
    version = vim.version.range('*'),
  },
  'https://github.com/rafamadriz/friendly-snippets',

  -- dependencies
  'https://github.com/kristijanhusak/vim-dadbod-completion',
  {
    src = 'https://github.com/L3MON4D3/LuaSnip',
    version = vim.version.range('^2'),
  },
}, { confirm = false })

require('luasnip.loaders.from_vscode').lazy_load()

vim.api.nvim_create_autocmd("PackChanged", {
  pattern = "LuaSnip",
  desc = "Build jsregexp for LuaSnip after install/update",
  group = vim.api.nvim_create_augroup("jobin/luasnip", { clear = true }),
  callback = function(e)
    -- The event data contains the kind of change and the plugin name
    local kind = e.data.kind

    -- We only want to build on fresh installs or updates
    if kind == "install" or kind == "update" then
      -- We must load the plugin first so we know where it lives
      vim.cmd.packadd({ args = { "LuaSnip" }, bang = false })

      local luasnip_dir = ""

      -- Split the comma-separated packpath string and iterate over each path
      for _, path in ipairs(vim.split(vim.o.packpath, ",")) do
        if path ~= "" then
          -- Search inside the pack/*/start and pack/*/opt directories for this specific path
          local start_path = vim.fn.finddir("LuaSnip", path .. "/pack/*/start")
          local opt_path = vim.fn.finddir("LuaSnip", path .. "/pack/*/opt")

          if start_path ~= "" then
            luasnip_dir = start_path
            break
          elseif opt_path ~= "" then
            luasnip_dir = opt_path
            break
          end
        end
      end

      if luasnip_dir ~= "" then
        vim.notify("Building LuaSnip jsregexp...", vim.log.levels.INFO)
        vim.fn.jobstart({ "make", "install_jsregexp" }, {
          cwd = vim.fn.fnamemodify(luasnip_dir, ":p"),
          on_exit = function(_, code)
            if code == 0 then
              vim.notify("LuaSnip jsregexp built successfully!", vim.log.levels.INFO)
            else
              vim.notify("Failed to build LuaSnip jsregexp. Check dependencies.", vim.log.levels.ERROR)
            end
          end,
        })
      else
        vim.notify("Could not locate LuaSnip directory to build jsregexp.", vim.log.levels.WARN)
      end
    end
  end,
})

-- vim.api.nvim_create_autocmd('PackChanged', {
--   group = 'jobin/luasnip',
--   callback = function(ev)
--     local name, kind = ev.data.spec.name, ev.data.kind
--     if name == 'LuaSnip' and kind == 'install' then
--       if not ev.data.active then vim.cmd.packadd('') end
--       require('nvim-treesitter').update()
--     end
--   end,
--   desc = 'Update Treesitter',
-- })


require('blink.cmp').setup({
  cmdline = {
    keymap = {
      -- recommended, as the default keymap will only show and select the next item
      ['<Tab>'] = { 'show', 'accept' },
    },
    completion = {
      menu = {
        ---@diagnostic disable-next-line: unused-local
        auto_show = function(ctx)
          return vim.fn.getcmdtype() == ':'
        end,
      }
    }
  },
  keymap = { preset = 'default' },
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = 'mono',
    kind_icons = require('jobin.config.icons').kind,
  },
  completion = {
    menu = {
      border = 'rounded',
      winhighlight = '',
    },
    documentation = {
      -- disable if you run into performance issues
      auto_show = true,
      treesitter_highlighting = true,
      window = {
        border = 'rounded',
      }
    },
    list = {
      selection = {
        preselect = true,
        auto_insert = false,
      },
    }
  },
  snippets = {
    preset = 'luasnip',
  },
  -- default list of enabled providers defined so that you can extend it
  -- elsewhere in your config, without redefining it, via `opts_extend`
  sources = {
    providers = {
      buffer = {
        max_items = 3,
        min_keyword_length = 3,
      },
      dadbad = {
        name = 'Dadbod',
        module = 'vim_dadbod_completion.blink',
      }
      -- lazydev = {
      --   name = "LazyDev",
      --   module = "lazydev.integrations.blink",
      --   -- make lazydev completions top priority (see `:h blink.cmp`)
      --   score_offset = 100,
      -- },
    },
    default = { 'snippets', 'lsp', 'path', 'buffer' },
    per_filetype = {
      sql = { 'snippets', 'dadbod', 'buffer' },
    },
    -- optionally disable cmdline completions
    -- cmdline = {},
  },

  -- experimental signature help support
  signature = {
    enabled = true,
    window = {
      border = 'rounded',
    },
  },
})

local capabilities = {
  workspace = {
    fileOperations = {
      didCreate = true,
      didRename = true,
      didDelete = true,
      willCreate = true,
      willRename = true,
      willDelete = true,
    }
  }
}

vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)
})
