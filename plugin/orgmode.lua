local function load_fn()
  vim.pack.add({
    'https://github.com/nvim-orgmode/orgmode',
  }, { confirm = false })

  local opts = {
    org_agenda_files = {
      vim.g.org_files.personal .. '/**/*.org',
    },
    org_default_notes_file = vim.g.org_files.personal .. '/inbox.org',
    org_todo_keywords = {
      -- Open
      'TODO(t)',
      'NEXT(n)',
      'INPROGRESS(i)',
      'WAITING(w)',
      'REVIEW(r)',
      '|',
      -- Completed
      'DONE(d)',
      'CANCELLED(c)',
      'DELEGATED(e)'
    },
    -- org_archive_location = '~/playground/org_files/archive_file.org_archive',
    org_todo_repeat_to_state = 'NEXT',
    org_startup_folded = 'content',
    org_hide_leading_stars = false,
    org_hide_emphasis_markers = true,
    org_ellipsis = '  ',
    org_agenda_span = 'day',
    org_blank_before_new_entry = { heading = true, plain_list_item = false },
    org_log_into_drawer = 'LOGBOOK',
    org_agenda_skip_deadline_if_done = true,
    mappings = {
      org_return_uses_meta_return = true,
      org = {
        org_forward_heading_same_level = ']}',
        org_backward_heading_same_level = '[{',
      },
    },
    org_capture_templates = {},
    org_agenda_block_separator = '─',
    org_agenda_custom_commands = {
      -- "c" is the shortcut that will be used in the prompt
      A = {
        description = 'Agenda GTD',
        types = {
          {
            type = 'agenda',
            org_agenda_overriding_header = "Today's Agenda:",
            org_agenda_span = 'day'
          },
          {
            type = 'tags_todo',
            match = '/INPROGRESS',
            org_agenda_overriding_header = 'In Progress Items:',
            org_agenda_todo_ignore_scheduled = 'all',
          },
          {
            type = 'tags_todo',
            match = '/NEXT',
            org_agenda_overriding_header = 'Next Items:',
            org_agenda_todo_ignore_scheduled = 'all',
          },
          {
            type = 'tags_todo',
            match = '/WAITING',
            org_agenda_overriding_header = 'Waiting on Items:',
            org_agenda_todo_ignore_scheduled = 'all',
          },
          {
            type = 'tags_todo',
            match = '+PRIORITY="A"',
            org_agenda_overriding_header = 'High Priority Todos:',
            org_agenda_todo_ignore_deadlines = 'far',
          },
        }
      },
      r = {
        description = 'Review',
        types = {
          {
            type = 'tags_todo',
            org_agenda_overriding_header = 'Inbox:',
            org_agenda_category_filter_preset = 'inbox',
          },
          {
            type = 'tags_todo',
            org_agenda_overriding_header = 'Someday:',
            org_agenda_category_filter_preset = 'someday',
          },
        }
      },
      c = {
        description = 'Combined view', -- Description shown in the prompt for the shortcut
        types = {
          {
            type = 'tags_todo',                       -- Type can be agenda | tags | tags_todo
            match = '+PRIORITY="A"',                  --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
            org_agenda_overriding_header = 'High priority todos',
            org_agenda_todo_ignore_deadlines = 'far', -- Ignore all deadlines that are too far in future (over org_deadline_warning_days). Possible values: all | near | far | past | future
          },
          {
            type = 'agenda',
            org_agenda_overriding_header = 'My daily agenda',
            org_agenda_span = 'day' -- can be any value as org_agenda_span
          },
          {
            type = 'tags',
            match = 'WORK',                           --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
            org_agenda_overriding_header = 'My work todos',
            org_agenda_todo_ignore_scheduled = 'all', -- Ignore all headlines that are scheduled. Possible values: past | future | all
          },
          {
            type = 'agenda',
            org_agenda_overriding_header = 'Whole week overview',
            org_agenda_span = 'week',        -- 'week' is default, so it's not necessary here, just an example
            org_agenda_start_on_weekday = 1, -- Start on Monday
            org_agenda_remove_tags = true    -- Do not show tags only for this view
          },
        },
      },
    },
    ui = {
      input = {
        use_vim_ui = true
      }
    }
  }


  require('jobin.config.lazy').host_opts(opts, 'orgmode')

  require('orgmode').setup(opts)

  -- Experimental LSP support
  vim.lsp.enable('org')
end


require('jobin.config.lazy').ll_on_map(
  'n',
  '<leader>o',
  function() vim.cmd('Org agenda') end,
  load_fn,
  'Orgmode'
)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('jobin/filetype', { clear = false }),
  once = true,
  pattern = {
    'org',
  },
  callback = load_fn
})
