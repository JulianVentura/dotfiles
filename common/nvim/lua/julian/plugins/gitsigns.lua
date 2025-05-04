-- import gitsigns plugin safely
local setup, gitsigns = pcall(require, "gitsigns")
if not setup then
  print("ERROR: gitsigns plugin not found")
  return
end

-- configure/enable gitsigns
gitsigns.setup()
