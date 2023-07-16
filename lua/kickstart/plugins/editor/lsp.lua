return {

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {

    {
      'williamboman/mason.nvim',
      cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
      opts = {
        ensure_installed = {
          "intelephense",
          "sonarlint-language-server",
          "phpcs",
          "phpcbf",
        }
      },
      config = function(_, opts)
        require('mason').setup(opts)

        vim.api.nvim_create_user_command("MasonInstallAll", function()
          vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
        end, {})
      end

    },
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    event = "BufEnter",
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },
  {
    'folke/neodev.nvim',
  },
  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = "VeryLazy",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },
}
