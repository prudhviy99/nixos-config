{ config, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    # Programming font with icons (waybar needs the icons, ghostty/nvim use the font)
    nerd-fonts.jetbrains-mono

    # General use
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk-sans

    # Icon font waybar/wofi configs commonly reference
    font-awesome
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Noto Sans" ];
      serif     = [ "Noto Serif" ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };
}
