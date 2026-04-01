vim.g.rustaceanvim = {
  server = {
    on_attach = function(_, bufnr)
      local map = function(mode, keys, func, desc)
        vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
      end
      map('n', '<leader>lra', function() vim.cmd.RustLsp('codeAction') end, 'Lsp code Action')
      map('n', '<leader>dRr', function() vim.cmd.RustLsp('runnables') end, 'Rust Debuggables')
      map('n', '<leader>dRd', function() vim.cmd.RustLsp('debuggables') end, 'Rust Debuggables')
      map('n', '<leader>dRt', function() vim.cmd.RustLsp('testables') end, 'Rust Testables')
      map('n', '<leader>lf', function() vim.cmd.RustFmt() end, 'Rust Format')
      map('v', '<leader>lf', function() vim.cmd.RustFmtRange() end, 'Rust Format Range')
    end,
    default_settings = {
      -- rust-analyzer language server configuration
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
          loadOutDirsFromCheck = true,
          buildScripts = {
            enable = true,
          },
        },
        -- Add clippy lints for Rust if using rust-analyzer
        checkOnSave = true,
        -- Enable diagnostics if using rust-analyzer
        diagnostics = { enable = true },
        -- procMacro = {
        --   enable = true,
        --   ignored = {
        --     ["async-trait"] = { "async_trait" },
        --     ["napi-derive"] = { "napi" },
        --     ["async-recursion"] = { "async_recursion" },
        --   },
        -- },
        files = {
          excludeDirs = {
            ".direnv",
            ".git",
            ".github",
            ".gitlab",
            "bin",
            "node_modules",
            "target",
            "venv",
            ".venv",
          },
        },
        -- Avoid Roots Scanned hanging, see https://github.com/rust-lang/rust-analyzer/issues/12613#issuecomment-2096386344
        watcher = "client",
      },
    },
  }
}

vim.api.nvim_create_autocmd('BufRead', {
  group = vim.api.nvim_create_augroup('jobin/bufread', { clear = false }),
  pattern = "Cargo.toml",
  once = true, -- Only run once per session
  callback = function()
    -- 1. Load the plugin
    vim.cmd.packadd("crates.nvim")

    -- 2. Configure it
    require("crates").setup({
      completion = {
        crates = {
          enabled = true,
        },
      },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
      popup = {
        border = "rounded",
      }
    })
  end,
})

vim.pack.add({
  {
    src = 'https://github.com/mrcjkb/rustaceanvim',
    version = vim.version.range('^8'),
  }
}, { confirm = false })

vim.pack.add({
  'https://github.com/Saecki/crates.nvim',
}, { load = false, confirm = false })
