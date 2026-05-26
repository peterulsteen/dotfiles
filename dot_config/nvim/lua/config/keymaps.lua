-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Seamless split/pane navigation: Neovim splits <-> Zellij panes (smart-splits.nvim).
-- These INTENTIONALLY override LazyVim's default <C-h/j/k/l> window-navigation maps so
-- the same keys cross the Neovim/Zellij boundary. The Zellij half is vim-zellij-navigator
-- (see ~/.config/zellij/config.kdl). This file loads after LazyVim's defaults, so it wins.
local function ss(dir)
  return function()
    require("smart-splits")["move_cursor_" .. dir]()
  end
end
vim.keymap.set("n", "<C-h>", ss("left"), { desc = "Move to left split / Zellij pane" })
vim.keymap.set("n", "<C-j>", ss("down"), { desc = "Move to below split / Zellij pane" })
vim.keymap.set("n", "<C-k>", ss("up"), { desc = "Move to above split / Zellij pane" })
vim.keymap.set("n", "<C-l>", ss("right"), { desc = "Move to right split / Zellij pane" })
