-- import lspsaga safely
local saga_status, saga = pcall(require, "lspsaga")
if not saga_status then
  return
end

saga.setup({
  -- keybinds for navigation in lspsaga window
  scroll_preview = { scroll_down = "<C-f>", scroll_up = "<C-b>" },
  -- use enter to open file with definition preview
  request_timeout = 2000,
  -- definition = {
  --   edit = "<CR>",
  -- },
  ui = {
    colors = {
      normal_bg = "#022746",
    },
  },
  -- For default options for each command, see below
  finder = {
    keys = {
      jump_to = "p",
      expand_or_jump = "<CR>",
      vsplit = "v",
      split = "s",
      tabe = "t",
      tabnew = "r",
      quit = { "q", "<ESC>" },
      close_in_preview = "<ESC>",
    },
  },
  code_action = { ... },
})
