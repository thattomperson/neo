return {
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
}
