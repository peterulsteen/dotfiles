-- Seamless navigation between Neovim splits and Zellij panes.
--
-- This is the Neovim half of the pair; the Zellij half is vim-zellij-navigator,
-- configured in ~/.config/zellij/config.kdl. With `multiplexer_integration =
-- "zellij"`, pressing <C-h/j/k/l> at the edge of the Neovim split grid hands
-- focus off to the adjacent Zellij pane (and vice-versa) using one keymap.
--
-- The <C-h/j/k/l> mappings themselves live in lua/config/keymaps.lua, NOT here:
-- that file loads after LazyVim's default window-nav maps, so it reliably wins.
-- We load eagerly (lazy = false) so setup() runs at startup and the maps work on
-- the very first keypress.
return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  opts = {
    multiplexer_integration = "zellij",
  },
}
