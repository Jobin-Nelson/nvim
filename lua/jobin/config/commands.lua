-- User commands best practices
-- https://github.com/lumen-oss/nvim-best-practices?tab=readme-ov-file#speaking_head-user-commands

vim.api.nvim_create_user_command('Pack', function(opts)
  local subcommand_key = opts.fargs[1]
  if subcommand_key == 'check' then
    local active_plugins = vim.iter(vim.pack.get())
        :filter(function(p) return p.active end)
        :map(function(p) return p.spec.name end)
        :totable()
    local inactive_plugins = vim.iter(vim.pack.get())
        :filter(function(p) return not p.active end)
        :map(function(p) return p.spec.name end)
        :totable()

    print(('==== #%s Inactive Plugins ===='):format(#inactive_plugins))
    print('')

    for _, p in ipairs(inactive_plugins) do
      print(p)
    end

    print('')
    print(('==== #%s Active Plugins ===='):format(#active_plugins))
    print('')

    for _, p in ipairs(active_plugins) do
      print(p)
    end
  elseif subcommand_key == 'update' then
    vim.pack.update()
  else
    vim.notify("Pack: Unknown command: " .. subcommand_key, vim.log.levels.ERROR)
  end
end, {
  nargs = "+",
  desc = "Package manager utility",
  complete = function(arg_lead, cmdline, _)
    local arg_list = vim.split(cmdline, '%s+')
    if #arg_list >= 3 then return end

    local subcommand_keys = { 'check', 'update' }
    return vim.iter(subcommand_keys)
        :filter(function(key)
          return key:find(arg_lead) ~= nil
        end)
        :totable()
  end,
})


vim.api.nvim_create_user_command('DiffOrig', function()
  local start = vim.api.nvim_get_current_buf()
  vim.cmd('vnew | set buftype=nofile | read ++edit # | 0d_ | diffthis')
  local scratch = vim.api.nvim_get_current_buf()

  vim.cmd('wincmd p | diffthis')

  -- Map `q` for both buffers to exit diff view and delete scratch buffer
  for _, buf in ipairs({ scratch, start }) do
    vim.keymap.set('n', 'q', function()
      vim.api.nvim_buf_delete(scratch, { force = true })
      vim.keymap.del('n', 'q', { buffer = start })
    end, { buffer = buf })
  end
end, {})

-- Todoist
vim.api.nvim_create_user_command('Todo', function(opts)
  local utils = require('jobin.config.custom.utils')
  local notify = function(res)
    vim.schedule(function()
      if res.code == 0 then
        vim.notify('Todo operation successful', vim.log.levels.INFO, { title = 'Todo' })
      else
        vim.notify('Todo operation failed', vim.log.levels.ERROR, { title = 'Todo' })
      end
    end)
  end

  -- range
  if opts.range == 2 then
    local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
    for _, line in ipairs(lines) do
      vim.system(utils.shellsplit(line), {}, notify)
    end
    return
  end

  -- default
  if vim.startswith(opts.args, 'get') or opts.args == '' then
    return require('jobin.config.custom.fzf.pickers').fzf_todoist(
      opts.args == '' and 'todo.py get task' or 'todo.py ' .. opts.args
    )
  end

  -- print(vim.inspect(vim.list_extend({ 'todo.py' }, vim.shell(opts.args, ' '))))
  vim.system(vim.list_extend({ 'todo.py' }, utils.shellsplit(opts.args)), {}, notify)
end, {
  desc = 'Get/Add/Update/Delete/Close Todo',
  range = true,
  nargs = '*',
  complete = function(_, cmdline)
    local arg_list = vim.split(cmdline, '%s+')
    if #arg_list >= 2 then
      local flag = arg_list[#arg_list - 1]
      if vim.tbl_contains({ '-l', '--label' }, flag) then
        return vim.fn.systemlist({ 'todo.py', 'list', '--label' })
      elseif vim.tbl_contains({ '-p', '--priority' }, flag) then
        return vim.fn.systemlist({ 'todo.py', 'list', '--priority' })
      elseif '--project' == flag then
        return vim.fn.systemlist({ 'todo.py', 'list', '--project' })
      end
    end
    return {}
  end
})

-- Jira
vim.api.nvim_create_user_command('JQL', function(opts)
  local jql = opts.args
  -- s: current sprint
  if opts.args == 's' then
    jql = 'sprint in openSprints() and project = Lambert and assignee = currentUser() and status not in (Done)'
    -- ssb: current sprint, stories or bugs
  elseif opts.args == 'ssb' then
    jql = 'sprint in openSprints() and project = Lambert and type in (Story,Bug) and status != Done'
    -- st: current sprint, ready for test
  elseif opts.args == 'st' then
    jql = 'sprint in openSprints() and project = Lambert and assignee = currentUser() and status = "Ready for Test"'
    -- stw: current sprint, ready for test, last 7 days
  elseif opts.args == 'stw' then
    jql =
    'sprint in openSprints() and project = Lambert and assignee = currentUser() and status changed to "Ready for Test" after startOfDay(-7d)'
    -- std: current sprint, ready for test, last 24 hours
  elseif opts.args == 'std' then
    jql =
    'sprint in openSprints() and project = Lambert and assignee = currentUser() and status changed to "Ready for Test" after -1d'
    -- b: open bugs
  elseif opts.args == 'b' then
    jql =
    'project = Lambert and (assignee = currentUser() or reporter = currentUser()) and type = Bug and status not in (Done,"Won\'t Fix",Deferred,Duplicate)'
    -- dm: done in last month
  elseif opts.args == 'dm' then
    jql =
    'project = Lambert and assignee was currentUser() and status changed to Done after startOfMonth(-1) before endOfMonth(-1)'
    -- dw: done in last week
  elseif opts.args == 'dw' then
    jql =
    'project = Lambert and assignee was currentUser() and status changed to Done after startOfWeek(-1) before endOfWeek(-1)'
  end
  require('jobin.config.custom.fzf.pickers').fzf_search_jira(jql)
end, { nargs = 1 }
)

-- HTop
vim.api.nvim_create_user_command('Htop', function(_)
  require('jobin.config.custom.utils').wrap_cli({ 'htop' }, { title = ' HTOP ' })
end, { nargs = 0 })

-- Github cli dash
vim.api.nvim_create_user_command('Ghdash', function(_)
  require('jobin.config.custom.utils').wrap_cli({ 'gh', 'dash' }, { title = ' GH DASH ' })
end, { nargs = 0 })

-- Music client
vim.api.nvim_create_user_command('Rmpc', function(_)
  require('jobin.config.custom.utils').wrap_cli({ 'rmpc' }, { title = ' RMPC ' })
end, { nargs = 0 })

-- Dotfiles
vim.api.nvim_create_user_command('Dot', function(opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local buf_git_dir = vim.b.git_dir
  vim.b.git_dir = vim.g.git_worktrees[1].gitdir
  vim.cmd('Git ' .. opts.args)
  vim.b[bufnr].git_dir = buf_git_dir
end, {
  nargs = '?',
  complete = function(a, l, p)
    return vim.fn['fugitive#Complete'](a, l, p, { git_dir = vim.g.git_worktrees[1].gitdir })
  end
})

-- Change fonts
vim.api.nvim_create_user_command('Chfont', function(_)
  local chfont_script = vim.env.HOME .. '/.local/bin/chfont.sh'
  require('jobin.config.custom.utils').wrap_cli({ chfont_script })
end, {
  nargs = 0,
})

-- Diff files from git branch
vim.api.nvim_create_user_command('DiffBranch', function(opts)
  require('jobin.config.custom.fzf.pickers').fzf_git_diff_branch(opts.args)
end, {
  nargs = 1,
  force = true,
  complete = function()
    local branches = vim.fn.systemlist 'git branch --all --sort=-committerdate'
    if vim.v.shell_error == 0 then
      return vim.tbl_map(function(x)
        return x:match('[^%s%*]+'):gsub('^remotes/', '')
      end, branches)
    end
  end,
})
