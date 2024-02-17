local theme = require("julian.core.colorscheme")

-- import lualine plugin safely
local status, lualine = pcall(require, "lualine")
if not status then
  return
end

-- Configure theme

-- Gruvbox setup function
local function gruvbox()
  lualine.setup({
    options = {
      theme = "gruvbox",
    },
  })
end

-- Nightfly setup function
local function nightfly()
  -- get lualine nightfly theme
  local lualine_nightfly = require("lualine.themes.nightfly")

  -- new colors for theme
  local new_colors = {
    blue = "#65D1FF",
    green = "#3EFFDC",
    violet = "#FF61EF",
    yellow = "#FFDA7B",
    black = "#000000",
  }

  -- change nightlfy theme colors
  lualine_nightfly.normal.a.bg = new_colors.blue
  lualine_nightfly.insert.a.bg = new_colors.green
  lualine_nightfly.visual.a.bg = new_colors.violet
  lualine_nightfly.command = {
    a = {
      gui = "bold",
      bg = new_colors.yellow,
      fg = new_colors.black, -- black
    },
  }

  lualine.setup({
    options = {
      theme = lualine_nightfly,
    },
  })
end

local function vscode()
  lualine.setup({
    options = {
      theme = "material",
    },
  })
end

-- Configuration auxiliar function
local function configure_lualine(selected_theme)
  local themes = {
    gruvbox = gruvbox,
    nightfly = nightfly,
    vscode = vscode,
  }

  if not themes[selected_theme] then
    print("Error: Invalid theme for lualine")
    return nil
  end

  themes[selected_theme]()
end

configure_lualine(theme)
