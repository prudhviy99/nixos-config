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
  # Official `starship preset tokyo-night` (Nerd Font required), with $time
  # moved into right_format (date + time, right-aligned) instead of the left
  # chain. Full config lives in ~/.config/starship.toml (managed below),
  # identical to the hand-ported copy on non-NixOS machines.
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  home.file.".config/starship.toml".text = ''
    "$schema" = 'https://starship.rs/config-schema.json'

    format = """
    [░▒▓](#a3aed2)\
    $os\
    [](bg:#769ff0 fg:#a3aed2)\
    $directory\
    [](fg:#769ff0 bg:#394260)\
    $git_branch\
    $git_status\
    [](fg:#394260 bg:#212736)\
    $nodejs\
    $bun\
    $rust\
    $golang\
    $php\
    [ ](fg:#212736)\
    \n$character"""

    right_format = "$time"

    [directory]
    style = "fg:#e3e5e5 bg:#769ff0"
    format = "[ $path ]($style)"
    truncation_length = 3
    truncation_symbol = "…/"

    [directory.substitutions]
    "Documents" = "󰈙 "
    "Downloads" = " "
    "Music" = " "
    "Pictures" = " "

    [git_branch]
    symbol = ""
    style = "bg:#394260"
    format = '[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)'

    [git_status]
    style = "bg:#394260"
    format = '[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)'

    [nodejs]
    symbol = ""
    style = "bg:#212736"
    format = '[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)'

    [bun]
    symbol = ""
    style = "bg:#212736"
    format = '[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)'

    [rust]
    symbol = ""
    style = "bg:#212736"
    format = '[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)'

    [golang]
    symbol = ""
    style = "bg:#212736"
    format = '[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)'

    [php]
    symbol = ""
    style = "bg:#212736"
    format = '[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)'

    [time]
    disabled = false
    time_format = "%a %d %b  %R" # e.g. "Sun 05 Jul  01:15"
    style = "bg:#1d2230"
    format = '[[  $time ](fg:#a0a9cb bg:#1d2230)]($style)'

    [os]
    style = "bg:#a3aed2 fg:#090c0c"
    format = "[ $symbol ]($style)"
    disabled = false

    [os.symbols]
    Windows = "󰍲"
    Ubuntu = "󰕈"
    SUSE = ""
    Raspbian = "󰐿"
    Mint = "󰣭"
    Macos = "󰀵"
    Manjaro = ""
    Linux = "󰌽"
    Gentoo = "󰣨"
    Fedora = "󰣛"
    Alpine = ""
    Amazon = ""
    Android = ""
    AOSC = ""
    Arch = "󰣇"
    Artix = "󰣇"
    EndeavourOS = ""
    CentOS = ""
    Debian = "󰣚"
    Redhat = "󱄛"
    RedHatEnterprise = "󱄛"
    Pop = ""
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
