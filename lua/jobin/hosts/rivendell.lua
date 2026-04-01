if vim.fn.hostname() ~= 'rivendell' then return {} end

vim.g.org_files.work = vim.fs.normalize('~/playground/dev/infosys')
local work_agenda_files = vim.g.org_files.work .. '/notes'
local jira_creds_file = vim.g.org_files.work .. '/creds/jira.json'
local daily_update_dir = vim.g.org_files.work .. '/daily_updates'

vim.keymap.set('n', '<leader>foT', function()
  require("jobin.config.custom.fzf.pickers").fzf_org_live_grep(work_agenda_files)
end, { desc = 'Org Todo grep (Work)' })

-- Setup jira creds
require('jobin.config.custom.work_stuff.jira.opts'):set_creds_file_path(jira_creds_file)

-- Setup git remote
require('jobin.config.custom.git').opts.url_patterns["git%.infosys%.com"] = {
  branch = "/tree/{branch}",
  file = "/blob/{branch}/{file}#L{line_start}-L{line_end}",
  commit = "/commit/{commit}",
}

-- Setup daily update
require('jobin.config.custom.work_stuff.daily_update').opts.daily_update_dir = daily_update_dir

-- Modify in snippets ~/.config/nvim/snippets/org.json

return {
  orgmode = function(opts)
      opts.org_agenda_files = {
        work_agenda_files .. '/**/*.org',
      }
      opts.org_default_notes_file = work_agenda_files .. '/work_inbox.org'
      opts.org_capture_templates.m = {
        description = 'Meeting',
        template = '\n* %?\n  %u',
        target = work_agenda_files .. '/meeting_notes.org',
      }
      opts.org_capture_templates.w = {
        description = 'Work Task',
        template = '\n* TODO %?\n  SCHEDULED: %t',
        target = work_agenda_files .. '/work_inbox.org',
      }
      opts.org_agenda_custom_commands.w = {
        description = 'Work Agenda',
        types = {
          {
            type = 'agenda',
            org_agenda_overriding_header = "Today's Agenda:",
            org_agenda_span = 'day',
            org_agenda_files = work_agenda_files
          },
        }
      }
    end
  -- {
  --   "zbirenbaum/copilot.lua",
  --   event = 'InsertEnter',
  --   optional = true,
  --   opts = function(_, opts)
  --     opts.suggestion.enabled = true
  --     opts.suggestion.auto_trigger = true
  --   end
  -- },
  -- {
  --   'supermaven-inc/supermaven-nvim',
  --   enabled = false,
  -- }
  }
