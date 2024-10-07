-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
        hide_dotfiles = false,
        hide_gitignored = true,
      },
      hijack_netrw_behavior = 'open_current',
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['<tab>'] = function(state)
            state.commands['open'](state)
            vim.cmd 'Neotree reveal'
          end,
          ['<cr>'] = function(state)
            state.commands['open'](state)
            state.commands['close_window'](state)
          end,
        },
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd('BufNewFile', {
      group = vim.api.nvim_create_augroup('RemoteFile', { clear = true }),
      callback = function()
        local f = vim.fn.expand '%:p'
        for _, v in ipairs { 'sftp', 'scp', 'ssh', 'dav', 'fetch', 'ftp', 'http', 'rcp', 'rsync' } do
          local p = v .. '://'
          if string.sub(f, 1, #p) == p then
            vim.cmd [[
	      unlet g:loaded_netrw
	      unlet g:loaded_netrwPlugin
	      runtime! plugin/netrwPlugin.vim
	      silent Explore %
	    ]]
            vim.api.nvim_clear_autocmds { group = 'RemoteFile' }
            break
          end
        end
      end,
    })
    vim.api.nvim_create_autocmd('BufEnter', {
      group = vim.api.nvim_create_augroup('NeoTreeInit', { clear = true }),
      callback = function()
        local f = vim.fn.expand '%:p'
        if vim.fn.isdirectory(f) ~= 0 then
          vim.cmd('Neotree current dir=' .. f)
          vim.api.nvim_clear_autocmds { group = 'NeoTreeInit' }
        end
      end,
    })
  end,
}
