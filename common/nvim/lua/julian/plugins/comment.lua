-- import comment plugin safely
local setup, comment = pcall(require, "Comment")
if not setup then
  print("ERROR: comment plugin not found")
  return
end

-- enable comment
comment.setup()
