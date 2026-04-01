-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                      Autocommands                        ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

local augroup = vim.api.nvim_create_augroup('jobin/treesitter', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  callback = function(args)
    local buf = args.buf
    local filetype = args.match


    -- you need some mechanism to avoid running on buffers that do not
    -- correspond to a language (like oil.nvim buffers), this implementation
    -- checks if a parser exists for the current language
    local language = vim.treesitter.language.get_lang(filetype) or filetype
    if not vim.treesitter.language.add(language) then
      return
    end

    -- replicate `fold = { enable = true }`
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

    -- replicate `highlight = { enable = true }`
    vim.treesitter.start(buf, language)

    -- replicate `indent = { enable = true }`
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

    -- `incremental_selection = { enable = true }` cannot be easily replicated
  end,
  desc = 'Setup Treesitter'
})

vim.api.nvim_create_autocmd('PackChanged', {
  group = augroup,
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
      require('nvim-treesitter').update()
    end
  end,
  desc = 'Update Treesitter',
})


-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                         Plugin                           ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

vim.pack.add({
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    version = 'main',
  },
  'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  'https://github.com/nvim-treesitter/nvim-treesitter-context',
  'https://github.com/windwp/nvim-ts-autotag',
}, { confirm = false })


-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                          Setup                           ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛


local parsers = {
  'python',
  'bash',
  'regex',
  'markdown',
  'markdown_inline',
  'json',
  'yaml',
  'lua',
  'toml',
  'make',
  'diff',
  'c',
  'html',
  'css',
  'javascript',
  'typescript',
  'tsx',
  'vim',
  'vimdoc',
  'query',
  'astro',
  'nix',
  'rust',
  'ron',
  'sql',
  'typst',
}
require('nvim-treesitter').install(parsers)

local textobject_opts = {
  select = {
    enable = true,
    lookahead = true,
    keymaps = {
      -- You can use the capture groups defined in textobjects.scm
      ["ak"] = { query = "@block.outer", group = 'textobjects', desc = "around block" },
      ["ik"] = { query = "@block.inner", group = 'textobjects', desc = "inside block" },
      ["ac"] = { query = "@class.outer", group = 'textobjects', desc = "around class" },
      ["ic"] = { query = "@class.inner", group = 'textobjects', desc = "inside class" },
      ["a?"] = { query = "@conditional.outer", group = 'textobjects', desc = "around conditional" },
      ["i?"] = { query = "@conditional.inner", group = 'textobjects', desc = "inside conditional" },
      ["af"] = { query = "@function.outer", group = 'textobjects', desc = "around function " },
      ["if"] = { query = "@function.inner", group = 'textobjects', desc = "inside function " },
      ["al"] = { query = "@loop.outer", group = 'textobjects', desc = "around loop" },
      ["il"] = { query = "@loop.inner", group = 'textobjects', desc = "inside loop" },
      ["aa"] = { query = "@parameter.outer", group = 'textobjects', desc = "around argument" },
      ["ia"] = { query = "@parameter.inner", group = 'textobjects', desc = "inside argument" },
      ["am"] = { query = "@call.outer", group = 'textobjects', desc = "around function call" },
    }
  },
  move = {
    enable = true,
    set_jumps = true, -- whether to set jumps in the jumplist
    keymaps = {
      goto_next_start = {
        ["]k"] = { query = "@block.outer", group = 'textobjects', desc = "Next block start" },
        ["]f"] = { query = "@function.outer", group = 'textobjects', desc = "Next function start" },
        -- ["]a"] = { query = "@parameter.inner", group = 'textobjects', desc = "Next argument start" },
        ["]]"] = { query = "@class.outer", group = 'textobjects', desc = "Next class start" },
        -- ["]z"] = { query = "@fold", group = 'folds', desc = "Next fold start" },
      },
      goto_next_end = {
        ["]K"] = { query = "@block.outer", group = 'textobjects', desc = "Next block end" },
        ["]F"] = { query = "@function.outer", group = 'textobjects', desc = "Next function end" },
        -- ["]A"] = { query = "@parameter.inner", group = 'textobjects', desc = "Next argument end" },
        ["]["] = { query = "@class.outer", group = 'textobjects', desc = "Next class end" },
      },
      goto_previous_start = {
        ["[k"] = { query = "@block.outer", group = 'textobjects', desc = "Previous block start" },
        ["[f"] = { query = "@function.outer", group = 'textobjects', desc = "Previous function start" },
        -- ["[a"] = { query = "@parameter.inner", group = 'textobjects', desc = "Previous argument start" },
        ["[["] = { query = "@class.outer", group = 'textobjects', desc = "Previous class start" },
        -- ["[z"] = { query = "@fold", group = 'folds', desc = "Previous fold start" },
      },
      goto_previous_end = {
        ["[K"] = { query = "@block.outer", group = 'textobjects', desc = "Previous block end" },
        ["[F"] = { query = "@function.outer", group = 'textobjects', desc = "Previous function end" },
        -- ["[A"] = { query = "@parameter.inner", group = 'textobjects', desc = "Previous argument end" },
        ["[]"] = { query = "@class.outer", group = 'textobjects', desc = "Previous class end" },
      },
    }
  },
  swap = {
    enable = true,
    keymaps = {
      swap_next = {
        [">K"] = { query = "@block.outer", group = 'textobjects', desc = "Swap next block" },
        [">F"] = { query = "@function.outer", group = 'textobjects', desc = "Swap next function" },
        [">A"] = { query = "@parameter.inner", group = 'textobjects', desc = "Swap next argument" },
      },
      swap_previous = {
        ["<K"] = { query = "@block.outer", group = 'textobjects', desc = "Swap previous block" },
        ["<F"] = { query = "@function.outer", group = 'textobjects', desc = "Swap previous function" },
        ["<A"] = { query = "@parameter.inner", group = 'textobjects', desc = "Swap previous argument" },
      },
    }
  },
}
require('nvim-treesitter-textobjects').setup(textobject_opts)

local select = require('nvim-treesitter-textobjects.select').select_textobject

for key, query_obj in pairs(textobject_opts.select.keymaps) do
  vim.keymap.set({ 'x', 'o' }, key, function()
    select(query_obj.query, query_obj.group)
  end, { desc = query_obj.desc })
end

for seg, keymap in pairs(textobject_opts.move.keymaps) do
  for key, query_obj in pairs(keymap) do
    vim.keymap.set({ "n", "x", "o" }, key, function()
      require("nvim-treesitter-textobjects.move")[seg](query_obj.query, query_obj.group)
    end, { desc = query_obj.desc })
  end
end

for seg, keymap in pairs(textobject_opts.swap.keymaps) do
  for key, query_obj in pairs(keymap) do
    vim.keymap.set("n", key, function()
      require("nvim-treesitter-textobjects.swap")[seg](query_obj.query, query_obj.group)
    end, { desc = query_obj.desc })
  end
end


require('treesitter-context').setup({ mode = "cursor", max_lines = 3 })
require('nvim-ts-autotag').setup()

