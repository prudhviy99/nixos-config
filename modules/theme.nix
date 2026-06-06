{ config, pkgs, ... }:

{
  stylix = {
    enable = true;
    polarity = "dark";

    targets.kmscon.enable = false;

    # Wallpaper (required) + the color scheme derived from Catppuccin Mocha
    image = ../wallpapers/wall.jpg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";

    # Fonts
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = { package = pkgs.noto-fonts; name = "Noto Sans"; };
      serif     = { package = pkgs.noto-fonts; name = "Noto Serif"; };
      emoji     = { package = pkgs.noto-fonts-color-emoji; name = "Noto Color Emoji"; };
      sizes = { applications = 11; terminal = 12; desktop = 11; popups = 11; };
    };

    # Cursor (Stylix manages it now — remove the old home.pointerCursor, see Step 4)
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

  };
}
