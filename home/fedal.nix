{ config, pkgs, lib, inputs, ... }:

{
   # We manage these two by hand (raw hyprland.conf + manual waybar style),
   # so tell Stylix to leave them alone and avoid conflicts.
   stylix.targets.hyprland.enable = false;
   stylix.targets.waybar.enable = false;
   stylix.targets.fuzzel.enable = false;


  imports = [
    ./shell.nix
    ./tmux.nix
    ./git.nix
    ./ghostty.nix
    inputs.spicetify-nix.homeManagerModules.default
  ];

  home.username      = "fedal";
  home.homeDirectory = "/home/fedal";
  home.stateVersion  = "26.05";  # match configuration.nix; do not change
  
  programs.home-manager.enable = true;
  programs.spicetify.enable = true;

  # ---- User packages ----
  home.packages = with pkgs; [
    # Browser
    google-chrome

    # Hyprland ecosystem
    waybar              # status bar
    hyprlock            # screen locker
    hypridle            # auto-lock daemon
    hyprpaper           # wallpaper
    hyprshot            # screenshots (like flameshot for Hyprland)
    hyprpicker          # color picker
    mako                # notifications
    wl-clipboard        # wl-copy / wl-paste
    cliphist            # clipboard history
    brightnessctl       # brightness control
    playerctl           # media key control
    grim                # screenshot backend
    slurp               # region selector
    pavucontrol         # PulseAudio volume control GUI
    fuzzel              # App launcher
    snixembed           # waybar tray

    # Editor (config later)
    neovim
    awww                # Wallaper
    networkmanagerapplet # wifi
    bluetui              # bluetooth tui
    vesktop                  # Discord (Wayland screenshare + themeable)
    vscode                   # use vscode-fhs instead if marketplace extensions misbehave
    claude-code
    antigravity
    nautilus                 # GUI file manager
    transmission_4-gtk       # torrent client (GTK GUI)
    localsend                # file sharing over network

    # neovim/LazyVim runtime deps (for group 5):
    gcc
    gnumake
    nodejs
    tree-sitter
    unzip

    python3
    jdk21
    maven

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
    (btop.override { cudaSupport = true; })                # nicer htop
    lazygit             # git TUI
    gh                  # GitHub CLI
    tldr                # quick command examples
    tree
    unzip
    file

    docker-compose
    lazydocker

    kubectl
    kubernetes-helm
    k9s
    kubectx

    awscli2
    ssm-session-manager-plugin


    postgresql
    pgcli
    redis

    (pkgs.writeShellScriptBin "powermenu" ''
      choice=$(printf "Lock\nSuspend\nLogout\nScreenshot\nReboot\nShutdown" | fuzzel --dmenu --prompt "Power: ")
      case "$choice" in
        Lock)       hyprlock ;;
        Suspend)    systemctl suspend ;;
        Logout)     hyprctl dispatch exit ;;
        Screenshot) sleep 0.3 && hyprshot -m region ;;
        Reboot)     systemctl reboot ;;
        Shutdown)   systemctl poweroff ;;
      esac
    '')
  ];

  # ---- Hyprland config: drop our hyprland.conf into ~/.config/hypr/ ----
  xdg.configFile."hypr/hyprland.conf".source = ./hypr/hyprland.conf;

  # hyprlock config
  xdg.configFile."hypr/hyprlock.conf".source = ./hypr/hyprlock.conf;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http"  = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
      "text/html"              = "google-chrome.desktop";
      "x-scheme-handler/zoommtg" = "Zoom.desktop";
    };
  };


  # ---- Waybar config ----
  xdg.configFile."waybar/config.jsonc".source = ./hypr/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source    = ./hypr/waybar/style.css;

  xdg.configFile."networkmanager-dmenu/config.ini".text = ''
  [dmenu]
  dmenu_command = fuzzel --dmenu --prompt "Wi-Fi: "
  wifi_chars = ▂▄▆█
  list_saved = True
'';
  
  programs.waybar.enable = true;
  services.mako.enable = true;


  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "ghostty";
        layer = "overlay";
        width = 45;
        lines = 12;
        horizontal-pad = 24;
        vertical-pad = 20;
        inner-pad = 12;
        font = lib.mkForce "JetBrainsMono Nerd Font:size=13";
      };
      border = {
        width = 2;
        radius = 14;
      };
      colors = {
        background = "1e1e2ef2";
        text = "cdd6f4ff";
        prompt = "cba6f7ff";
        input = "cdd6f4ff";
        match = "f38ba8ff";
        selection = "313244ff";
        selection-text = "cdd6f4ff";
        selection-match = "f38ba8ff";
        border = "cba6f7ff";
      };
    };
  };


services.hypridle = {
  enable = true;
  settings = {
    general = {
      lock_cmd = "pidof hyprlock || hyprlock";   # don't stack instances
      before_sleep_cmd = "loginctl lock-session"; # lock before suspend
      after_sleep_cmd = "hyprctl dispatch dpms on";
    };
    listener = [
      {
        timeout = 300;                 # 5 min -> lock
        on-timeout = "loginctl lock-session";
      }
      {
        timeout = 360;                 # 6 min -> screen off
        on-timeout = "hyprctl dispatch dpms off";
        on-resume = "hyprctl dispatch dpms on";
      }
    ];
  };
};

}
