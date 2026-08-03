-- LazyVim's lualine uses theme = "auto", which (since lualine ships no
-- built-in "kanagawa" theme) generates a solid-color bar from the Normal/
-- StatusLine highlight groups. That solid bar breaks the transparent look,
-- so replace it with a theme that keeps the mode colors but drops the fill.
local colors = {
  normal = "#7E9CD8",
  insert = "#98BB6C",
  visual = "#957FB8",
  replace = "#E46876",
  command = "#E6C384",
  fg = "#DCD7BA",
  muted = "#727169",
}

local function mode(fg)
  return {
    a = { fg = fg, bg = "NONE", gui = "bold" },
    b = { fg = colors.muted, bg = "NONE" },
    c = { fg = colors.fg, bg = "NONE" },
  }
end

local theme = {
  normal = mode(colors.normal),
  insert = mode(colors.insert),
  visual = mode(colors.visual),
  replace = mode(colors.replace),
  command = mode(colors.command),
  inactive = mode(colors.muted),
}
theme.terminal = theme.command

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.theme = theme
      return opts
    end,
  },
}
