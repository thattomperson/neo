return {
  {
    -- Adds git releated signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns");

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map(
          "n",
          "<leader>gp",
          gs.prev_hunk,
          { desc = "[G]o to [P]revious Hunk" }
        )
        map(
          "n",
          "<leader>gn",
          gs.next_hunk,
          { desc = "[G]o to [N]ext Hunk" }
        )
        map(
          "n",
          "<leader>ph",
          gs.preview_hunk,
          { desc = "[P]review [H]unk" }
        )
        map(
          "v",
          "<leader>ga",
          function()
            gs.stage_hunk({vim.fn.line('.'), vim.fn.line('v')})
          end,
          { desc = "[G]it [a]dd hunk" }
        )
        map(
          "n",
          "<leader>ga",
          gs.stage_buffer,
          { desc = "[G]it [a]dd buffer" }
        )

        map("n", "<leader>gb", function() gs.blame_line{full=true} end, { desc = "[G]it [B]laim" })
      end,
    },
  },
}
