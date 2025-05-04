Theme = "gruvbox"

-- Nightfly

local nightfly = function()
  local status, _ = pcall(require, "gruvbox")
  if not status then
    print("Error: Couldn't load gruvbox theme")
    return false
  end

  -- Lua initialization file
  vim.g.nightflyCursorColor = false
  -- Lua initialization file
  vim.g.nightflyItalics = true
  -- Lua initialization file
  vim.g.nightflyNormalFloat = false
  -- Lua initialization file
  vim.g.nightflyTerminalColors = true
  -- Lua initialization file
  vim.g.nightflyTransparent = true
  -- Lua initialization file
  vim.g.nightflyUndercurls = true
  -- Lua initialization file
  vim.g.nightflyUnderlineMatchParen = false
  -- Lua initialization file
  vim.g.nightflyVirtualTextColor = false
  -- Lua initialization file
  vim.g.nightflyWinSeparator = 1

  return true
end

-- Gruvbox
local gruvbox = function()
  local status, theme = pcall(require, "gruvbox")
  if not status then
    print("Error: Couldn't load gruvbox theme")
    return false
  end

  theme.setup({
    terminal_colors = true,
    undercurl = true,
    underline = true,
    bold = true,
    italic = {
      strings = true,
      emphasis = true,
      comments = true,
      operators = false,
      folds = true,
    },
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = true, -- invert background for search, diffs, statuslines and errors
    contrast = "hard", -- can be "hard", "soft" or empty string
    palette_overrides = {},
    overrides = {},
    dim_inactive = false,
    transparent_mode = true,
  })

  function FixGruvbox()
    -- vim.api.nvim_set_hl(0, 'DiffviewDiffAddAsDelete', { bg = "#431313" })
    -- vim.api.nvim_set_hl(0, 'DiffDelete', { bg = "none", fg = "#504945" })
    -- vim.api.nvim_set_hl(0, 'DiffviewDiffDelete', { bg = "none", fg = "#504945" })
    -- vim.api.nvim_set_hl(0, 'DiffAdd', { bg = "#142a03" })
    -- vim.api.nvim_set_hl(0, 'DiffChange', { bg = "#3B3307" })

    vim.api.nvim_set_hl(0, 'DiffviewDiffAddAsDelete', { bg = "none" })
    vim.api.nvim_set_hl(0, 'DiffDelete', { bg = "none", fg = "none" })
    vim.api.nvim_set_hl(0, 'DiffviewDiffDelete', { bg = "none", fg = "none" })
    vim.api.nvim_set_hl(0, 'DiffAdd', { bg = "none" })
    vim.api.nvim_set_hl(0, 'DiffChange', { bg = "none" })
    vim.api.nvim_set_hl(0, 'DiffText', { bg = "#4D520D" })
  end
  FixGruvbox()

  vim.api.nvim_create_autocmd(
    "ColorScheme",
      { pattern = { "gruvbox" }, callback = FixGruvbox }
  )


  return true
end

-- VSCode

local function vscode()
  local status, theme = pcall(require, "vscode")
  if not status then
    print("Error: Couldn't load vscode theme")
    return false
  end

  local colors = nil
  status, colors = pcall(require, "vscode.colors")
  if not status then
    print("Error: Couldn't load vscode colors")
    return false
  end

  local c = colors.get_colors()

  theme.setup({
    -- Alternatively set style in setup
    -- style = 'light'

    -- Enable transparent background
    transparent = true,

    -- Enable italic comment
    italic_comments = true,

    -- Disable nvim-tree background color
    disable_nvimtree_bg = true,

    -- Override colors (see ./lua/vscode/colors.lua)
    -- color_overrides = {
    --   vscLineNumber = "#FFFFFF",
    -- },

    -- Override highlight groups (see ./lua/vscode/theme.lua)
    group_overrides = {
      -- this supports the same val table as vim.api.nvim_set_hl
      -- use colors from this colorscheme by requiring vscode.colors!
      Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
    },
  })

  theme.load()

  return true
end


local themes = {
  gruvbox = gruvbox,
  nightfly = nightfly,
  vscode = vscode,
}

local function configure_theme(theme)

  if not themes[theme] then
    print("Error: Theme " .. theme .. " not available")
    return
  end

  if not themes[theme]() then
    return
  end

  local status, _ = pcall(function(_)
    return vim.cmd("colorscheme " .. theme)
  end)

  if not status then
    print("Error: Couldn't set colorscheme " .. theme)
  end
end

configure_theme(Theme)

vim.api.nvim_create_user_command("Theme", function(opts)
  configure_theme(opts.args)
end, { nargs=1, complete=function()
    local keys = {}
    for key, _ in pairs(themes) do
      table.insert(keys, key)
    end
    return keys
end})

vim.api.nvim_create_user_command("SolveMerge", function(_)
  vim.cmd("Theme vscode")
  vim.cmd("DiffviewOpen")
end, {})

return Theme
