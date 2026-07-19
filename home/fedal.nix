{ config, pkgs, lib, inputs, ... }:

{
   # We manage these two by hand (raw hyprland.conf + manual waybar style),
   # so tell Stylix to leave them alone and avoid conflicts.
   stylix.targets.hyprland.enable = false;
   stylix.targets.waybar.enable = false;
   stylix.targets.fuzzel.enable = true;


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

  # Auto-restart changed user services (waybar, mako, hypr-clamshell, …) during a
  # `nixos-rebuild switch`, so an in-place rebuild picks up changes without a manual
  # `systemctl --user restart`. A fresh login already starts the current versions.
  systemd.user.startServices = "sd-switch";
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
    socat               # clamshell: reads Hyprland event socket for monitor hotplug
    cliphist            # clipboard history
    brightnessctl       # brightness control
    playerctl           # media key control
    grim                # screenshot backend
    slurp               # region selector
    pavucontrol         # PulseAudio volume control GUI
    fuzzel              # App launcher
    ollama              # local AI
    fastfetch           # display system information
    openrgb             # rgb control
    obsidian            # note taking

    # Editor (config later)
    neovim
    zed-editor
    awww                # Wallaper
    networkmanager_dmenu # wifi switcher (replaces nm-applet tray icon)
    bluetui              # bluetooth tui
    spotify
    discord
    vscode                   # use vscode-fhs instead if marketplace extensions misbehave
    claude-code
    codex
    antigravity
    jetbrains.idea       # intellij free
    nautilus                 # GUI file manager
    transmission_4-gtk       # torrent client (GTK GUI)
    localsend                # file sharing over network
    vlc                      # media player

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
    glow

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

    (pkgs.writeShellScriptBin "setwallpaper" ''
      if [ -n "$1" ]; then
        awww img "$1"
      else
        file=$(find ~/Pictures/wallpapers -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | fuzzel --dmenu --prompt "Wallpaper: ")
        [ -n "$file" ] && awww img "$file"
      fi
    '')
  ];

  home.file."Pictures/wallpapers/.keep".text = "";

  # Suppress tray icons for applets already represented by waybar modules
  xdg.configFile."autostart/blueman.desktop".text = "[Desktop Entry]\nHidden=true\n";

  # ---- Neovim / LazyVim config ----
  # Files are linked individually so ~/.config/nvim/ stays writable
  # (lazy-lock.json and new plugin files can be created freely).
  # To add plugins: create lua/plugins/myplugins.lua in this repo.
  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };

  # ---- Hyprland config: drop our hyprland.conf into ~/.config/hypr/ ----
  xdg.configFile."hypr/hyprland.conf".source = ./hypr/hyprland.conf;
  xdg.configFile."hypr/clamshell.sh" = {
    source = ./hypr/clamshell.sh;
    executable = true;
  };

  # hyprlock config
  xdg.configFile."hypr/hyprlock.conf".source = ./hypr/hyprlock.conf;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http"  = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
      "text/html"              = "google-chrome.desktop";
      "x-scheme-handler/zoommtg" = "Zoom.desktop";
      "text/markdown" = "google-chrome.desktop";
    };
  };


  # ---- Waybar config ----
  xdg.configFile."waybar/config.jsonc".source = ./hypr/waybar/config.jsonc;

  xdg.configFile."waybar/style.css".text = ''
    @define-color bg      ${config.lib.stylix.colors.withHashtag.base00};
    @define-color surface ${config.lib.stylix.colors.withHashtag.base02};
    @define-color muted   ${config.lib.stylix.colors.withHashtag.base03};
    @define-color text    ${config.lib.stylix.colors.withHashtag.base05};
    @define-color accent  ${config.lib.stylix.colors.withHashtag.base0D};
    @define-color red     ${config.lib.stylix.colors.withHashtag.base08};
    @define-color orange  ${config.lib.stylix.colors.withHashtag.base09};

    * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 11px;
        border: none;
        border-radius: 0;
        min-height: 0;
    }

    window#waybar {
        background: transparent;
        color: @text;
    }

    #workspaces, #window, #clock, #bluetooth, #network,
    #pulseaudio, #battery, #tray, #custom-tray-arrow {
        background: alpha(@bg, 0.55);
        border: 1px solid alpha(@surface, 0.6);
        border-radius: 8px;
        padding: 0 8px;
        margin: 1px 0;
    }

    #workspaces button { padding: 0 6px; color: @muted; background: transparent; border: none; }
    #workspaces button.active { color: @accent; }
    #workspaces button:hover { background: @surface; color: @text; }

    #custom-tray-arrow { color: @accent; }
    #bluetooth.connected { color: @accent; }
    #network.disconnected { color: @red; }
    #battery.warning  { color: @orange; }
    #battery.critical { color: @red; }
  '';


  xdg.configFile."networkmanager-dmenu/config.ini".text = ''
  [dmenu]
  dmenu_command = fuzzel --dmenu --prompt "Wi-Fi: "
  wifi_chars = ▂▄▆█
  list_saved = True
'';
  
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      targets = [ "graphical-session.target" ];
    };
  };
  services.mako.enable = true;

  # Clamshell/docking watcher: reconciles the internal panel when a monitor is
  # plugged in or unplugged (see home/hypr/clamshell.sh). The script is idempotent
  # so it cannot enter the disable<->enable feedback loop that a naive watcher does.
  systemd.user.services.hypr-clamshell = {
    Unit = {
      Description = "Hyprland clamshell/docking reconciler";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "%h/.config/hypr/clamshell.sh watch";
      Restart = "on-failure";
      RestartSec = "2s";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

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
        timeout = 300;                 # 5 min -> lock (skipped if media is playing)
        on-timeout = "playerctl status 2>/dev/null | grep -q Playing || loginctl lock-session";
      }
      {
        timeout = 360;                 # 6 min -> screen off (skipped if media is playing)
        on-timeout = "playerctl status 2>/dev/null | grep -q Playing || hyprctl dispatch dpms off";
        on-resume = "hyprctl dispatch dpms on";
      }
    ];
  };
};

}
