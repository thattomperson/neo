return {
  {
    "mfussenegger/nvim-lint",
    lazy = false,
    cmd = { "Format" },
    opts = {},
    config = function(_, opts)
      local lint = require("lint")

      local phpcs = lint.linters.phpcs
      phpcs.args = {
        "-q",
        "--standard=" .. vim.fn.expand("~/.config/nvim/data/phpcs.xml"),
        "--report=json",
        "-",
      }

      lint.linters_by_ft = {
        php = { "phpcs" },
      }

      vim.api.nvim_create_autocmd({ "TextChanged", "BufEnter" }, {
        pattern = { "*.php" },
        callback = function()
          lint.try_lint()
        end,
      })

      -- Create a command `:Format` local to the LSP buffer
      vim.api.nvim_create_user_command("Format", function(_)
        if (vim.bo.filetype ~= "php") then
          print("Only supports PHP")
          return
        end
        local bufnr = vim.api.nvim_get_current_buf()
        local filename = vim.api.nvim_buf_get_name(bufnr)
        local uv = vim.loop

        uv.spawn("phpcs", {
          args = {
            "--standard=" .. vim.fn.expand("~/.config/nvim/data/phpcs.xml"),
            filename
          }
        })
      end, { desc = "Format current buffer with LSP" })
    end,
  },
  {
    "nvimdev/guard.nvim",
    lazy = false,
    enabled = false,
    dependencies = {
      "williamboman/mason.nvim",
    },
    opts = {
      fmt_on_save = true,
    },
    config = function(_, opts)
      local ft = require("guard.filetype")
      local diag_fmt = require("guard.lint").diag_fmt

      ft("php"):fmt({
        cmd = "phpcbf",
        args = { "-", "--standard=" .. vim.fn.expand("~/.config/nvim/data/phpcs.xml") },
        stdin = true,
      }):lint({
        cmd = "phpcs",
        args = { "-", "--report=json", "--standard=" .. vim.fn.expand("~/.config/nvim/data/phpcs.xml") },
        stdin = true,
        output_fmt = function(result, buf)
          local severities = {
            WARNING = 2,
            ERROR = 1,
          }

          local messages = vim.json.decode(result).files.STDIN.messages
          local diags = {}

          if #messages < 1 then
            return {}
          end

          vim.tbl_map(function(mes)
            diags[#diags + 1] = diag_fmt(
              buf,
              tonumber(mes.line) - 1,
              tonumber(mes.column) - 1,
              (mes.fixable and "[x]" or "") .. mes.message,
              severities[mes.severity] or 2,
              "phpcs"
            )
          end, messages)

          return diags
        end,
      })

      ft("lua"):fmt("stylua")

      require("guard").setup(opts)
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "VimEnter",
    enabled = false,
    config = function(_, opts)
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.diagnostics.cspell,
          null_ls.builtins.code_actions.cspell,
          null_ls.builtins.diagnostics.phpcs.with({
            extra_args = { "--standard", vim.fn.expand("~/.config/nvim/data/phpcs.xml") },
          }),
          null_ls.builtins.formatting.phpcbf.with({
            extra_args = { "--standard", vim.fn.expand("~/.config/nvim/data/phpcs.xml") },
          }),
          null_ls.builtins.formatting.stylua.with({
            condition = function()
              return require("kickstart.util").is_program_in_path("stylua")
            end,
          }),
        },
      })
    end,
  },
  --{
  --  url = "https://gitlab.com/schrieveslaach/sonarlint.nvim",
  --  ft = { "php" },
  --  dependencies = {
  --    "williamboman/mason.nvim"
  --  },
  --  config = function()
  --    local sonar_language_server_path = require("mason-registry")
  --        .get_package("sonarlint-language-server")
  --        :get_install_path()
  --    local analyzers_path = sonar_language_server_path .. "/extension/analyzers"
  --    require("sonarlint").setup({
  --      server = {
  --        cmd = {
  --          sonar_language_server_path .. "/sonarlint-language-server.cmd",
  --          "-stdio",
  --          "-analyzers",
  --          vim.fn.expand(analyzers_path .. "/sonarphp.jar"),
  --        }
  --      },
  --      filetypes = {
  --        "php",
  --      }
  --    })
  --  end
  --},

}
