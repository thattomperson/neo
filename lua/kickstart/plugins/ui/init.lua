return {

  -- Useful plugin to show you pending keybinds.
  {
    "folke/which-key.nvim",
    opts = {},
    lazy = false,
    config = function (_, opts) 
      wk = require('which-key');
      wk.setup(opts);

      wk.register({
        ["<leader>g"] = { name = "+git" },
      })
    end
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      dark_variant = 'moon',
    },
    config = function(_, opts)
      require('rose-pine').setup(opts)
      vim.cmd.colorscheme("rose-pine")
    end,
  },
  -- better vim.ui
  {
    "stevearc/dressing.nvim",
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
      },
    },
    -- stylua: ignore
    keys = {
      {
        "<S-Enter>",
        function() require("noice").redirect(vim.fn.getcmdline()) end,
        mode = "c",
        desc =
        "Redirect Cmdline"
      },
      {
        "<leader>snl",
        function() require("noice").cmd("last") end,
        desc =
        "Noice Last Message"
      },
      {
        "<leader>snh",
        function() require("noice").cmd("history") end,
        desc =
        "Noice History"
      },
      { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
      {
        "<leader>snd",
        function() require("noice").cmd("dismiss") end,
        desc =
        "Dismiss All"
      },
      {
        "<c-f>",
        function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end,
        silent = true,
        expr = true,
        desc =
        "Scroll forward",
        mode = {
          "i", "n", "s" }
        },
        {
          "<c-b>",
          function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end,
          silent = true,
          expr = true,
          desc =
          "Scroll backward",
          mode = {
            "i", "n", "s" }
          },
        },
      },
      {
        -- Add indentation guides even on blank lines
        "lukas-reineke/indent-blankline.nvim",
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help indent_blankline.txt`
        event = { "BufReadPost", "BufNewFile" },
        opts = {
          char = "┊",
          filetype_exclude = {
            "starter",
            "minifiles",
            "toggleterm",
            "mason",
            "lazy",
            "notify",
          },
          show_current_context = true,
          show_trailing_blankline_indent = false,
        },
      },
      {
        "nvim-treesitter/playground",
        cmd = { "TSPlaygroundToggle" },
        dependencies = {
          "nvim-treesitter/nvim-treesitter",
        }
      },
      {
        -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        cmd = { "TSUpdate" },
        event = "BufEnter",
        dependencies = {
          "nvim-treesitter/nvim-treesitter-textobjects",
        },
        build = ":TSUpdate",
        opts = {
          -- Add languages to be installed here that you want installed for treesitter
          ensure_installed = { "go", "lua", "tsx", "typescript", "vimdoc", "vim", "php", "json" },

          -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
          auto_install = false,

          highlight = { enable = true },
          indent = { enable = true },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = "<c-space>",
              node_incremental = "<c-space>",
              scope_incremental = "<c-s>",
              node_decremental = "<M-space>",
            },
          },
          textobjects = {
            select = {
              enable = true,
              lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
              keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
              },
            },
            move = {
              enable = true,
              set_jumps = true, -- whether to set jumps in the jumplist
              goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = "@class.outer",
              },
              goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
              },
              goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer",
              },
              goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
              },
            },
            swap = {
              enable = true,
              swap_next = {
                ["<leader>a"] = "@parameter.inner",
              },
              swap_previous = {
                ["<leader>A"] = "@parameter.inner",
              },
            },
          },
        },

        -- scrollbar
        { "lewis6991/satellite.nvim", opts = {}, event = "VeryLazy", enabled = false },
        {
          "echasnovski/mini.map",
          main = "mini.map",
          event = "VeryLazy",
          enabled = false,
          config = function()
            local map = require("mini.map")
            map.setup({
              integrations = {
                map.gen_integration.builtin_search(),
                map.gen_integration.gitsigns(),
                map.gen_integration.diagnostic(),
              },
            })
            map.open()
          end,
        },
        { import = "kickstart.plugins.ui.git" },
        { import = "kickstart.plugins.ui.start" },
        { import = "kickstart.plugins.ui.bars" },
      },
    }
