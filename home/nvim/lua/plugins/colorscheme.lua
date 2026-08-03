-- Kanagawa matches the system theme (stylix base16Scheme) that Ghostty's
-- ANSI colors are derived from. Transparent background lets Ghostty's own
-- background-opacity (0.85, black) show through, so nvim looks the same
-- as the terminal around it.
return {
  {
    "rebelot/kanagawa.nvim",
    opts = {
      transparent = true,
      dimInactive = false,
      -- kanagawa's `transparent` flag only clears Normal/NormalNC; the
      -- gutter keeps a solid bg by default, which breaks the transparent
      -- look, so clear it here too.
      overrides = function()
        return {
          SignColumn = { bg = "NONE" },
          LineNr = { bg = "NONE" },
          CursorLineNr = { bg = "NONE" },
          FoldColumn = { bg = "NONE" },
          -- Snacks (explorer sidebar, pickers) and LSP/completion floats
          -- default-link their background to NormalFloat, so clearing this
          -- one group also clears those.
          NormalFloat = { bg = "NONE" },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa",
    },
  },
}
