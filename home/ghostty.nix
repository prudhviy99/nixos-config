{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    installVimSyntax = true;

    settings = {
      # Font (matches what fonts.nix installs at the system level)
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;

      # Catppuccin Mocha (ships with Ghostty, no manual install)
      theme = "catppuccin-mocha";

      # Visual
      background-opacity = 0.95;
      window-decoration  = false;
      window-padding-x   = 8;
      window-padding-y   = 8;

      # Behavior
      copy-on-select = true;
      shell-integration = "zsh";

      # Cursor
      cursor-style       = "block";
      cursor-style-blink = false;
    };
  };
}
