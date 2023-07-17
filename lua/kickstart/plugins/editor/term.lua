local function change_direction(direction, size)
  local terminal = require("toggleterm.terminal")
  local term_id = terminal.get_focused_id()

  if term_id then
    local term = terminal.get(term_id, true)
    if term then
      term:close()
      term:open(size, direction)
      vim.schedule(function()
        vim.cmd("startinsert!")
      end)
    end
  end
end

return {
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    keys = {
      { "<C-`>", "<cmd> ToggleTerm <cr>", mode = { "t", "n" } },
      {
        "<C-l>",
        function()
          change_direction("vertical", vim.o.columns * 0.4)
        end,
        mode = "t",
      },
      {
        "<C-j>",
        function()
          change_direction("horizontal", 20)
        end,
        mode = "t",
      },
      {
        "<C-k>",
        function()
          change_direction("tab")
        end,
        mode = "t",
      },
      {
        "<C-h>",
        function()
          change_direction("float")
        end,
        mode = "t",
      },
      {
        "<Esc><Esc>",
        function()
          require("toggleterm.ui").stopinsert()
        end,
        mode = "t",
      },
    },
    version = "*",
    opts = {},
  },
}
