-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Omarchy's Neovim defaults, applied only on Omarchy. remote_clipboard.lua is
-- Omarchy's own file (installed and updated by its migrations), not this repo's.
-- Its migration only adds a require when this file lacks the string
-- "config.remote_clipboard", which the line below contains, so it won't add a
-- second, unguarded one.
if vim.fn.isdirectory("/usr/share/omarchy") == 1 then
  local ok, remote_clipboard = pcall(require, "config.remote_clipboard")
  if ok then
    remote_clipboard.setup()
  end

  vim.opt.relativenumber = false
  vim.g.autoformat = false
end
