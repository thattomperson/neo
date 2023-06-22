-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
    return vim.api.nvim_create_augroup("four_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        vim.notify('Installing PHP extensions...', 'Info')
        io.popen("four-php-dev php:install-extensions")
        vim.notify('PHP extensions Installed!', 'Info')
    end,
})
