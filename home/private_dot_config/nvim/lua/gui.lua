-- Neovim GTK --
if vim.g.GtkGuiLoaded == 1 then
  vim.rpcnotify(1, "Gui", "Option", "Cmdline", 0)
  vim.rpcnotify(1, "Gui", "Option", "Popupmenu", 0)
  vim.rpcnotify(1, "Gui", "Option", "Tabline", 0)
  vim.rpcnotify(1, "Gui", "Option", "SetCursorBlink", 0)
  vim.rpcnotify(1, "Gui", "Font", "JetBrainsMono 10")
  vim.rpcnotify(1, "Gui", "Linespace", "2")
end
