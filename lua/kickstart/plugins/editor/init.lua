return {
  -- Detect tabstop and shiftwidth automatically
  "tpope/vim-sleuth",

  {
    "echasnovski/mini.files",
    version = false,
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open()
        end,
        desc = "Open File browser",
      },
    },
  },

  -- buffer remove
  {
    "echasnovski/mini.bufremove",
    -- stylua: ignore
    keys = {
      { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "Delete Buffer" },
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end,  desc = "Delete Buffer (Force)" },
    },
  },

  -- "gc" to comment visual regions/lines
  { "numToStr/Comment.nvim", opts = {} },

  require("kickstart.plugins.editor.lsp"),
  require("kickstart.plugins.editor.guard"),
  require("kickstart.plugins.editor.telescope"),
  -- require("kickstart.plugins.editor.git"),
  require("kickstart.plugins.editor.term"),
}
