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

      # Visual
      background         = "000000";
      background-opacity = 0.85;
      window-decoration  = false;
      window-padding-x   = 8;
      window-padding-y   = 8;

      # Behavior
      copy-on-select = true;
      shell-integration = "zsh";
      mouse-hide-while-typing = true;
      resize-overlay = "never";

      # Cursor
      cursor-style       = "block";
      cursor-style-blink = false;
    };
  };
}
