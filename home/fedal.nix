{ config, pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./tmux.nix
    ./git.nix
    ./ghostty.nix
  ];

  home.username      = "fedal";
  home.homeDirectory = "/home/fedal";
  home.stateVersion  = "26.05";  # match configuration.nix; do not change

  programs.home-manager.enable = true;

  # ---- User packages ----
  home.packages = with pkgs; [
    # Browser
    chromium

    # Hyprland ecosystem
    waybar              # status bar
    hyprlock            # screen locker
    hypridle            # auto-lock daemon
    hyprpaper           # wallpaper
    hyprshot            # screenshots (like flameshot for Hyprland)
    hyprpicker          # color picker
    wofi                # app launcher (start here; switch to walker later if you want)
    mako                # notifications
    wl-clipboard        # wl-copy / wl-paste
    cliphist            # clipboard history
    brightnessctl       # brightness control
    playerctl           # media key control
    grim                # screenshot backend
    slurp               # region selector
    pavucontrol         # PulseAudio volume control GUI

    # Editor (config later)
    neovim

    # CLI essentials
    ripgrep             # rg: fast grep
    fd                  # find replacement
    bat                 # cat with syntax highlighting
    eza                 # ls replacement
    fzf                 # fuzzy finder
    zoxide              # smarter cd
    jq                  # JSON processor
    yq                  # YAML processor
    htop
    btop                # nicer htop
    lazygit             # git TUI
    gh                  # GitHub CLI
    tldr                # quick command examples
    tree
    unzip
    file
  ];

  # ---- Hyprland config: drop our hyprland.conf into ~/.config/hypr/ ----
  xdg.configFile."hypr/hyprland.conf".source = ./hypr/hyprland.conf;

  # ---- Waybar config ----
  xdg.configFile."waybar/config.jsonc".source = ./hypr/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source    = ./hypr/waybar/style.css;
}
