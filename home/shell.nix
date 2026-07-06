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
      rebuild  = "sudo nixos-rebuild switch --flake ~/nixos-config#t14g3p";
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
      --color=bg+:#223249,bg:-1,fg:#727169,fg+:#DCD7BA,hl:#C0A36E,hl+:#C0A36E,pointer:#FFA066,marker:#76946A,prompt:#957FB8,spinner:#957FB8,border:#54546D"
      export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:100 {} 2>/dev/null || eza -la --icons {}'"
      export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons {}'"

      # Paste your custom Mac zsh additions here, or use `source ~/.zshrc.local`
      # and put them in that file (untracked by git).
      [ -f ~/.zshrc.local ] && source ~/.zshrc.local
    '';
  };

  # ---- Starship prompt ----
  # Powerline layout ported from the `tokyo-night` preset, recolored to match
  # the Kanagawa base16 scheme Stylix applies everywhere else (modules/theme.nix)
  # so the prompt doesn't clash with the rest of the terminal. $time lives in
  # right_format (date + time, right-aligned) instead of the left chain. Full
  # config lives in ~/.config/starship.toml (managed below), identical to the
  # hand-ported copy on non-NixOS machines.
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Stylix's own starship target would otherwise generate a competing
  # ~/.config/starship.toml and conflict with the hand-managed one below.
  stylix.targets.starship.enable = false;

  home.file.".config/starship.toml".text = ''
    "$schema" = 'https://starship.rs/config-schema.json'

    format = """
    [░▒▓](#16161D)\
    $os\
    [](bg:#1F1F28 fg:#16161D)\
    $directory\
    [](fg:#1F1F28 bg:#223249)\
    $git_branch\
    $git_status\
    [](fg:#223249 bg:#16161D)\
    $nodejs\
    $bun\
    $rust\
    $golang\
    $php\
    [ ](fg:#16161D)\
    \n$character"""

    right_format = "$time"

    [directory]
    style = "fg:#DCD7BA bg:#1F1F28"
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
    style = "bg:#223249"
    format = '[[ $symbol $branch ](fg:#76946A bg:#223249)]($style)'

    [git_status]
    style = "bg:#223249"
    format = '[[($all_status$ahead_behind )](fg:#76946A bg:#223249)]($style)'

    [nodejs]
    symbol = ""
    style = "bg:#16161D"
    format = '[[ $symbol ($version) ](fg:#7E9CD8 bg:#16161D)]($style)'

    [bun]
    symbol = ""
    style = "bg:#16161D"
    format = '[[ $symbol ($version) ](fg:#7E9CD8 bg:#16161D)]($style)'

    [rust]
    symbol = ""
    style = "bg:#16161D"
    format = '[[ $symbol ($version) ](fg:#7E9CD8 bg:#16161D)]($style)'

    [golang]
    symbol = ""
    style = "bg:#16161D"
    format = '[[ $symbol ($version) ](fg:#7E9CD8 bg:#16161D)]($style)'

    [php]
    symbol = ""
    style = "bg:#16161D"
    format = '[[ $symbol ($version) ](fg:#7E9CD8 bg:#16161D)]($style)'

    [time]
    disabled = false
    time_format = "%a %d %b  %R" # e.g. "Sun 05 Jul  01:15"
    style = "bg:#1F1F28"
    format = '[[  $time ](fg:#727169 bg:#1F1F28)]($style)'

    [os]
    style = "bg:#16161D fg:#7E9CD8"
    format = "[ $symbol ]($style)"
    disabled = false

    [os.symbols]
    NixOS = "󱄅"
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
