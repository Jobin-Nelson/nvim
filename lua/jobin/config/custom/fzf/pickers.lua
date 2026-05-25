local fzf_lua = require 'fzf-lua'

local M = {}


---@param cmd string
---@param opts table?
M.fzf_cd_dir = function(cmd, opts)
  local default_opts = {
    fzf_opts = {
      ['--preview'] = "ls -lAhF --group-directories-first {}",
      ['--preview-window'] = 'hidden,down,50%',
    },
    prompt = "cd ❯ ",
    winopts = {
      title = " Change Directory ",
      title_pos = "center",
      height = 0.40,
      width = 0.40,
      row = 0.50,
      col = 0.50,
    },
    actions = {
      ['default'] = function(selected)
        vim.cmd("tcd " .. selected[1])
        vim.notify(
          "Changed directory into " .. selected[1],
          vim.log.levels.INFO,
          { title = 'FZF' }
        )
      end
    },
    -- fn_transform = function(x)
    --   return fzf_lua.utils.ansi_codes.magenta(x)
    -- end
  }
  opts = vim.tbl_deep_extend('force', default_opts, opts or {})
  fzf_lua.fzf_exec(cmd, opts)
end

---@param opts table?
M.fzf_read_file = function(opts)
  local path = require('fzf-lua.path')
  local default_opts = {
    prompt = "read ❯ ",
    cwd_prompt = false,
    winopts = {
      title = " Read File ",
      title_pos = "center",
      height = 0.50,
      width = 0.50,
      row = 0.50,
      col = 0.50,
      preview = {
        hidden = 'hidden',
      }
    },
    actions = {
      ['default'] = function(selected, lopts)
        for _, sel in ipairs(selected) do
          local entry = path.entry_to_file(sel, lopts, lopts._uri)
          local fullpath = entry.path
          vim.cmd('-1read ' .. fullpath)
          vim.notify(
            'Inserted ' .. vim.fs.basename(fullpath),
            vim.log.levels.INFO,
            { title = 'FZF' }
          )
        end
      end
    }
  }
  opts = vim.tbl_deep_extend('force', default_opts, opts or {})
  fzf_lua.files(opts)
end

---@param opts table?
M.fzf_move_file = function(opts)
  local rename_file = require('jobin.config.custom.utils').rename_file
  local default_opts = {
    fzf_opts = {
      ['--preview'] = "ls -lAhF --group-directories-first {}",
      ['--preview-window'] = 'hidden,down,50%',
    },
    prompt = "move ❯ ",
    winopts = {
      title = " Move File ",
      title_pos = "center",
      height = 0.40,
      width = 0.40,
      row = 0.50,
      col = 0.50,
    },
    actions = {
      ['default'] = function(selected)
        rename_file(selected[1])
      end
    }
  }
  opts = vim.tbl_deep_extend('force', default_opts, opts or {})
  local cwd = require('jobin.config.custom.git').get_git_root_buf() or vim.uv.cwd()
  local cmd = string.format(
    [[find %s \( -path '*/.git' -o -path '*/.obsidian' -o -path '*/node_modules' -o -path '*/.venv' \) -prune -o -type d -print]],
    cwd)
  fzf_lua.fzf_exec(cmd, opts)
end

M.fzf_second_brain_grep = function()
  local second_brain = "~/playground/second_brain"
  fzf_lua.live_grep({
    cwd = second_brain,
  })
end

M.fzf_second_brain_files = function()
  local second_brain = "~/playground/second_brain"
  fzf_lua.files({
    cwd = second_brain,
    actions = {
      ['ctrl-space'] = function(_, opts)
        local query = opts.__call_opts.query
        if query == "" then
          return vim.notify(
            'Query is empty',
            vim.log.levels.INFO,
            { title = 'FZF' }
          )
        end
        local md_suffix = '.md'
        if query:sub(- #md_suffix) ~= md_suffix then
          query = query .. md_suffix
        end
        local new_file = vim.fs.joinpath(second_brain, query)
        vim.cmd.edit(new_file)
      end
    }
  })
end

---@param org_dir string
M.fzf_org_live_grep = function(org_dir)
  fzf_lua.grep({
    no_esc = true,
    cwd = org_dir,
    search = "^\\*+ (TODO|NEXT|INPROGRESS|WAITING|REVIEW)",
    rg_opts = "--column --type org --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
    winopts = {
      title = " Org Todo ",
      title_pos = "center",
      preview = {
        layout = 'vertical',
        vertical = 'up:45%'
      }
    }
  })
end

---@param jql string?
---@param maxlimit integer?
M.fzf_search_jira = function(jql, maxlimit)
  if not jql or jql == '' then
    return vim.notify('JQL is empty, aborting', vim.log.levels.WARN, { title = 'FZF' })
  end

  local jira = require('jobin.config.custom.work_stuff.jira')
  local search = require('jobin.config.custom.work_stuff.jira.search')
  local issue = require('jobin.config.custom.work_stuff.jira.issue')

  local opts = {
    fzf_opts = {
      ['--multi'] = true,
    },
    prompt = "Issues ❯ ",
    winopts = {
      title = " Search Jira ",
      title_pos = "center",
    },
    actions = {
      ['default'] = function(selected, opts)
        vim.api.nvim_buf_set_lines(
          opts.__CTX.bufnr,
          opts.__CTX.cursor[1],
          opts.__CTX.cursor[1],
          false,
          selected
        )
      end,
      ['ctrl-o'] = {
        fn = function(selected, _)
          issue.open(selected[1])
        end,
        exec_silent = true,
      },
      ['alt-y'] = {
        fn = function(selected, _)
          jira.copy_id(selected[1])
        end,
        exec_silent = true,
      }
    },
  }
  local results = vim.tbl_map(
    jira.issue2List_with_status,
    search.query_jql(jql, maxlimit or 500)
  )

  if vim.tbl_isempty(results) then
    return jira.notify(
      ('No issues found for JQL: %s'):format(jql),
      vim.log.levels.INFO
    )
  end
  fzf_lua.fzf_exec(results, opts)
end

---@param cmd string
---@param opts table?
M.fzf_todoist = function(cmd, opts)
  local close_or_delete = function(op)
    return function(selected)
      local indices = vim.tbl_map(function(t)
        return vim.iter(vim.gsplit(vim.trim(t), ' ')):next():sub(1, -2)
      end, selected)
      vim.system(vim.list_extend({ 'todo.py', op, 'task', }, indices), {}, function(res)
        vim.schedule(function()
          if res.code == 0 then
            vim.notify(('Successfully %s Tasks: %s'):format(op, table.concat(indices, ', ')), vim.log.levels.INFO,
              { title = 'Todo' })
          else
            vim.notify(('Failed to %s Tasks: %s'):format(op, table.concat(indices, ', ')), vim.log.levels.INFO,
              { title = 'Todo' })
          end
        end)
      end)
    end
  end
  local default_opts = {
    prompt = "Todo ❯ ",
    winopts = {
      title = " Search Todoist ",
      title_pos = "center",
    },
    actions = {
      ['default'] = function(selected, lopts)
        vim.api.nvim_buf_set_lines(
          lopts.__CTX.bufnr,
          lopts.__CTX.cursor[1],
          lopts.__CTX.cursor[1],
          false,
          selected
        )
      end,
      ['ctrl-l'] = close_or_delete('delete'),
      ['ctrl-d'] = close_or_delete('close'),
    },
  }
  fzf_lua.fzf_exec(cmd, vim.tbl_deep_extend('force', default_opts, opts or {}))
end

M.fzf_icons = function()
  local nerdfonts_sets = {
    cod = "Codicons",
    dev = "Devicons",
    fa = "Font Awesome",
    fae = "Font Awesome Extension",
    iec = "IEC Power Symbols",
    linux = "Font Logos",
    logos = "Font Logos",
    oct = "Octicons",
    ple = "Powerline Extra",
    pom = "Pomicons",
    seti = "Seti-UI",
    weather = "Weather Icons",
    md = "Material Design Icons",
  }

  local sources = {
    nerd_fonts = {
      url = "https://github.com/ryanoasis/nerd-fonts/raw/refs/heads/master/glyphnames.json",
      v = 4,
      build = function(data)
        local ret = {}
        for name, info in pairs(data) do
          if name ~= "METADATA" then
            local font, icon = name:match("^([%w_]+)%-(.*)$")
            if not font then
              error("Invalid icon name: " .. name)
            end
            table.insert(ret, {
              name = icon,
              icon = info.char,
              source = "nerd fonts",
              category = nerdfonts_sets[font] or font,
              text = ("%s  %s - %s"):format(info.char, icon, nerdfonts_sets[font] or font)
            })
          end
        end
        return ret
      end,
    },
    emoji = {
      url = "https://raw.githubusercontent.com/muan/unicode-emoji-json/refs/heads/main/data-by-emoji.json",
      v = 4,
      build = function(data)
        local ret = {}
        for icon, info in pairs(data) do
          table.insert(ret, {
            name = info.name,
            icon = icon,
            source = "emoji",
            category = info.group,
            text = ("%s  %s - %s"):format(icon, info.name, info.group)
          })
        end
        return ret
      end,
    },
  }

  ---@param source_name string
  ---@return table<string,string> icons table
  local function load(source_name)
    local source = sources[source_name]
    local file = vim.fn.stdpath("cache") .. "/fzf/picker/icons/" .. source_name .. "-v" .. (source.v or 1) .. ".json"
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":h"), "p")
    if vim.fn.filereadable(file) == 1 then
      local fd = assert(io.open(file, "r"))
      local data = fd:read("*a")
      fd:close()
      return vim.json.decode(data)
    end

    vim.notify("Fetching `" .. source_name .. "` icons", vim.log.levels.INFO, { title = 'Fzf Icon Picker' })
    if vim.fn.executable("curl") == 0 then
      vim.notify("`curl` is required to fetch icons", vim.log.levels.ERROR, { title = 'Fzf Icon Picker' })
      return {}
    end
    local out = vim.fn.system({ "curl", "-s", "-L", source.url })
    if vim.v.shell_error ~= 0 then
      vim.notify(out, vim.log.levels.ERROR, { title = 'Fzf Icon Picker' })
      return {}
    end
    local icons = source.build(vim.json.decode(out))
    local fd = assert(io.open(file, "w"))
    fd:write(vim.json.encode(icons))
    fd:close()
    return icons
  end

  ---@return string[]
  local function icons()
    local ret = {}
    for source, _ in pairs(sources) do
      vim.list_extend(ret, vim.tbl_map(function(i) return i.text end, load(source)))
    end
    return ret
  end

  local default_opts = {
    prompt = "Pick ❯ ",
    winopts = {
      title = " Icons ",
      title_pos = "center",
      height = 0.50,
      width = 0.40,
      row = 0.50,
      col = 0.50,
    },
    actions = {
      ['default'] = function(selected)
        vim.api.nvim_put(vim.tbl_map(function(line)
          return line:match("^(%S+)")
        end, selected), "", true, true)
      end
    },
  }
  fzf_lua.fzf_exec(icons(), default_opts)
end

local list_files_from_branch_action = function(action, selected, args)
  local file = require('fzf-lua').path.entry_to_file(selected[1])
  vim.print('args is ' .. args)
  local cmd = string.format('%s %s:%s', action, args, file.path)
  vim.cmd(cmd)
end

---@param args string
function M.fzf_git_diff_branch(args)
  fzf_lua.files {
    cmd = 'git diff --name-only ' .. args,
    prompt = args .. ' ❯ ',
    hidden = false,
    actions = {
      ['default'] = function(selected)
        list_files_from_branch_action('Gedit', selected, args)
      end,
      ['ctrl-s'] = function(selected)
        list_files_from_branch_action('Gsplit', selected, args)
      end,
      ['ctrl-v'] = function(selected)
        list_files_from_branch_action('Gvsplit', selected, args)
      end,
    },
    previewer = false,
    preview = {
      type = 'cmd',
      fn = function(items)
        local file = require('fzf-lua').path.entry_to_file(items[1])
        return string.format('git diff --color=always %s HEAD -- %s', args, file.path)
      end,
    },
  }
end

-- vim.keymap.set('n', '<leader>rt', function() M.fzf_icons() end)
-- vim.keymap.set('n', '<leader>rr', ':update | luafile %<cr>')

return M
