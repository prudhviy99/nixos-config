{ config, pkgs, ... }:

{
  # ---- zsh ----
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    history = {
      size = 100000;
      extended = true;   # timestamps in history
      ignoreSpace = true;
    };

    shellAliases = {
      ll  = "eza -l --git --icons";
      la  = "eza -la --git --icons";
      lt  = "eza --tree --level=2 --icons";
      cat = "bat --paging=never";
      g   = "git";
      lg  = "lazygit";
      ".."    = "cd ..";
      "..."   = "cd ../..";
      "...." = "cd ../../..";
      reload = "exec zsh";

      # NixOS shortcuts you'll use constantly
      rebuild  = "sudo nixos-rebuild switch --flake ~/nixos-config#t14s";
      update   = "nix flake update ~/nixos-config";
      cleanup  = "sudo nix-collect-garbage --delete-older-than 14d";
    };

    initContent = ''
      # Quick system banner — only on the outermost interactive shell, so it
      # doesn't fire again for every nested shell (lazygit, subshells, etc.)
      if [[ -o interactive && $SHLVL -eq 1 ]]; then
        fastfetch 2>/dev/null
      fi

      setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
      setopt INTERACTIVE_COMMENTS NO_BEEP HIST_REDUCE_BLANKS HIST_VERIFY

      # Completion styling: case-insensitive, colorized, menu-driven
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion:*' group-name '''

      # Keybindings: filter history by what's already typed, jump by word
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward
      bindkey '^[[1;5D' backward-word    # ctrl+left
      bindkey '^[[1;5C' forward-word     # ctrl+right
      bindkey '^[[3~' delete-char        # delete key

      # mkdir + cd in one go
      mkcd() { mkdir -p "$1" && cd "$1"; }

      export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border=rounded --info=inline \
      --color=bg+:#1a1a1a,bg:-1,fg:#cdcdcd,fg+:#ffffff,hl:#5fafff,hl+:#5fafff,pointer:#ff5f87,marker:#5fff87,prompt:#af87ff,spinner:#af87ff,border:#444444"
      export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:100 {} 2>/dev/null || eza -la --icons {}'"
      export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons {}'"

      # Paste your custom Mac zsh additions here, or use `source ~/.zshrc.local`
      # and put them in that file (untracked by git).
      [ -f ~/.zshrc.local ] && source ~/.zshrc.local
    '';
  };

  # ---- Starship prompt ----
  # Catppuccin Mocha powerline preset (Nerd Font required), adapted from
  # https://gist.github.com/flexiondotorg/d823f23a2c0b2f1f4fd181e521b1618f
  # with $time enabled. Full config lives in ~/.config/starship.toml
  # (managed below), identical to the hand-ported copy on non-NixOS machines.
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  home.file.".config/starship.toml".text = ''
    add_newline = false
    command_timeout = 1000
    format = "[](surface1)$os[](bg:surface2 fg:surface1)$username$sudo[](bg:overlay0 fg:surface2)$hostname[](bg:mauve fg:overlay0)$directory[](fg:mauve bg:peach)$c$dart$dotnet$elixir$elm$erlang$golang$haskell$haxe$java$julia$kotlin$lua$nim$nodejs$rlang$ruby$rust$perl$php$python$scala$swift$zig$package$git_branch[](fg:peach bg:yellow)$git_status[](fg:yellow bg:teal)$container$direnv$nix_shell$cmd_duration$jobs$shlvl$status[](fg:teal bg:base)$time[](fg:base)$character"
    palette = "catppuccin_mocha"

    [c]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [character]
    disabled = false
    error_symbol = "(fg:red bg:pink)[](fg:pink) "
    format = "$symbol"
    success_symbol = "[](fg:blue) "

    [cmd_duration]
    format = "[  $duration]($style)"
    min_time = 2500
    min_time_to_notify = 60000
    show_notifications = false
    style = "fg:base bg:teal"

    [container]
    format = "[ $symbol $name]($style)"
    style = "fg:base bg:teal"
    symbol = "󱋩"

    [dart]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [directory]
    format = "[ $path]($style)[$read_only]($read_only_style)"
    home_symbol = ""
    read_only = " 󰈈"
    read_only_style = "bold fg:crust bg:mauve"
    style = "fg:base bg:mauve"
    truncation_length = 3
    truncation_symbol = "…/"

    [directory.substitutions]
    Apps = "󰵆"
    Audio = ""
    Crypt = "󰌾"
    Desktop = ""
    Development = ""
    Documents = "󰈙"
    Downloads = "󰉍"
    Dropbox = ""
    Games = "󰊴"
    Keybase = "󰯄"
    Music = "󰎄"
    Pictures = ""
    Public = ""
    Quickemu = ""
    Studio = "󰡇"
    Vaults = "󰌿"
    Videos = ""
    Volatile = "󱪃"
    Websites = "󰖟"
    Zero = "󰎡"
    nix-config = "󱄅"

    [direnv]
    allowed_msg = ""
    denied_msg = ""
    disabled = false
    format = "[ $loaded]($style)"
    loaded_msg = "󰐍"
    not_allowed_msg = ""
    style = "fg:base bg:teal"
    symbol = ""
    unloaded_msg = "󰙧"

    [dotnet]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [elixir]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [elm]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [erlang]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [git_branch]
    format = "[ $symbol $branch]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [git_status]
    ahead = "󰜹"
    behind = "󰜰"
    conflicted = "󰳤 "
    deleted = " "
    diverged = ""
    format = "[ $all_status$ahead_behind]($style)"
    modified = " "
    renamed = " "
    staged = " "
    stashed = " "
    style = "fg:base bg:yellow"
    typechanged = " "
    untracked = " "
    up_to_date = "󰤓"

    [golang]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [haskell]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = "󰲒"

    [haxe]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [hostname]
    disabled = false
    format = "[ $hostname]($style)[$ssh_symbol](bg:overlay0 fg:maroon)"
    ssh_only = false
    ssh_symbol = " 󰖈"
    style = "bg:overlay0 fg:red"

    [java]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = "󰬷"

    [jobs]
    format = "[ $symbol $number]($style)"
    style = "fg:base bg:teal"
    symbol = "󰣖"

    [julia]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [kotlin]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [lua]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [nim]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [nix_shell]
    format = "[ $symbol]($style)"
    style = "fg:base bg:teal"
    symbol = "󱄅"

    [nodejs]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [os]
    disabled = false
    format = "$symbol"
    style = ""

    [os.symbols]
    AlmaLinux = "[](fg:text bg:surface1)"
    Alpine = "[](fg:blue bg:surface1)"
    Amazon = "[](fg:peach bg:surface1)"
    Android = "[](fg:green bg:surface1)"
    Arch = "[󰣇](fg:sapphire bg:surface1)"
    Artix = "[](fg:sapphire bg:surface1)"
    CentOS = "[](fg:mauve bg:surface1)"
    Debian = "[](fg:red bg:surface1)"
    DragonFly = "[](fg:teal bg:surface1)"
    EndeavourOS = "[](fg:mauve bg:surface1)"
    Fedora = "[](fg:blue bg:surface1)"
    FreeBSD = "[](fg:red bg:surface1)"
    Garuda = "[](fg:sapphire bg:surface1)"
    Gentoo = "[](fg:lavender bg:surface1)"
    Illumos = "[](fg:peach bg:surface1)"
    Kali = "[](fg:blue bg:surface1)"
    Linux = "[](fg:yellow bg:surface1)"
    Macos = "[](fg:text bg:surface1)"
    Manjaro = "[](fg:green bg:surface1)"
    Mint = "[󰣭](fg:teal bg:surface1)"
    NixOS = "[](fg:sky bg:surface1)"
    OpenBSD = "[](fg:yellow bg:surface1)"
    Pop = "[](fg:sapphire bg:surface1)"
    Raspbian = "[](fg:maroon bg:surface1)"
    RedHatEnterprise = "[](fg:red bg:surface1)"
    Redhat = "[](fg:red bg:surface1)"
    RockyLinux = "[](fg:green bg:surface1)"
    SUSE = "[](fg:green bg:surface1)"
    Solus = "[](fg:blue bg:surface1)"
    Ubuntu = "[](fg:peach bg:surface1)"
    Unknown = "[](fg:text bg:surface1)"
    Void = "[](fg:green bg:surface1)"
    Windows = "[󰖳](fg:sky bg:surface1)"
    openSUSE = "[](fg:green bg:surface1)"

    [package]
    format = "[ $version]($style)"
    style = "fg:base bg:peach"
    version_format = "$raw"

    [palettes.catppuccin_mocha]
    base = "#1e1e2e"
    blue = "#89b4fa"
    crust = "#11111b"
    flamingo = "#f2cdcd"
    green = "#a6e3a1"
    lavender = "#b4befe"
    mantle = "#181825"
    maroon = "#eba0ac"
    mauve = "#cba6f7"
    overlay0 = "#6c7086"
    overlay1 = "#7f849c"
    overlay2 = "#9399b2"
    peach = "#fab387"
    pink = "#f5c2e7"
    red = "#f38ba8"
    rosewater = "#f5e0dc"
    sapphire = "#74c7ec"
    sky = "#89dceb"
    subtext0 = "#a6adc8"
    subtext1 = "#bac2de"
    surface0 = "#313244"
    surface1 = "#45475a"
    surface2 = "#585b70"
    teal = "#94e2d5"
    text = "#cdd6f4"
    yellow = "#f9e2af"

    [perl]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [php]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = "󰌟"

    [python]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [rlang]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [ruby]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [rust]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [scala]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [shlvl]
    disabled = false
    format = "[ $symbol]($style)"
    repeat = false
    style = "fg:surface1 bg:teal"
    symbol = "󱆃"
    threshold = 3

    [status]
    disabled = false
    format = "$symbol"
    map_symbol = true
    not_executable_symbol = "[](fg:teal bg:pink)[  $common_meaning](fg:red bg:pink)"
    not_found_symbol = "[](fg:teal bg:pink)[ 󰩌 $common_meaning](fg:red bg:pink)"
    sigint_symbol = "[](fg:teal bg:pink)[  $signal_name](fg:red bg:pink)"
    signal_symbol = "[](fg:teal bg:pink)[ ⚡ $signal_name](fg:red bg:pink)"
    style = ""
    success_symbol = "[](fg:teal bg:blue)"
    symbol = "[](fg:teal bg:pink)[  $status](fg:red bg:pink)"

    [sudo]
    disabled = false
    format = "[ $symbol]($style)"
    style = "fg:rosewater bg:surface2"
    symbol = "󰌋"

    [swift]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""

    [time]
    disabled = false
    format = "[ $time]($style)"
    style = "fg:text bg:base"
    time_format = "%H:%M"

    [username]
    format = "[ $user]($style)"
    show_always = true
    style_root = "fg:red bg:surface2"
    style_user = "fg:green bg:surface2"
    [username.aliases]
    root = "󰱯"

    [zig]
    format = "[ $symbol]($style)"
    style = "fg:base bg:peach"
    symbol = ""
  '';

  # ---- fastfetch: compact system banner on shell start ----
  home.file.".config/fastfetch/config.jsonc".text = ''
    {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {
            "type": "small",
            "padding": { "top": 1 }
        },
        "display": {
            "separator": "  "
        },
        "modules": [
            "title",
            "separator",
            "os",
            "kernel",
            "uptime",
            "packages",
            "shell",
            "wm",
            "terminal",
            "cpu",
            "memory",
            "disk",
            "break",
            "colors"
        ]
    }
  '';

  # ---- direnv: per-project env management. Worth it from day one. ----
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # ---- fzf, zoxide: shell-integrated tools ----
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat.enable = true;
  programs.eza.enable = true;
}
