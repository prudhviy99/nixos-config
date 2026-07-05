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
  # Full config lives in ~/.config/starship.toml (managed below), so it's
  # identical to the hand-ported copy on non-NixOS machines.
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  home.file.".config/starship.toml".text = ''
    "$schema" = 'https://starship.rs/config-schema.json'

    # Minimal two-line prompt: context on line 1 (left) + time (right), arrow on line 2.
    add_newline = true
    command_timeout = 1000

    format = """
    $username\
    $hostname\
    $directory\
    $git_branch\
    $git_status\
    $nix_shell\
    $package\
    $nodejs\
    $python\
    $rust\
    $golang\
    $java\
    $lua\
    $docker_context\
    $cmd_duration\
    $jobs\
    $battery\
    $line_break\
    $character"""

    right_format = "$time"

    [character]
    success_symbol = "[❯](bold green)"
    error_symbol = "[❯](bold red)"
    vimcmd_symbol = "[❮](bold green)"

    [directory]
    style = "bold cyan"
    format = "[ $path]($style)[$read_only]($read_only_style) "
    truncation_length = 3
    truncate_to_repo = true
    truncation_symbol = "…/"
    read_only = " 󰌾"
    read_only_style = "red"

    [git_branch]
    symbol = " "
    style = "bold purple"
    format = "[on](dimmed white) [$symbol$branch]($style) "

    [git_status]
    style = "bold yellow"
    format = '([$all_status$ahead_behind]($style)) '

    [nix_shell]
    disabled = false
    symbol = " "
    style = "bold blue"
    format = "[$symbol$state]($style) "

    [package]
    symbol = "󰏗 "
    style = "bold 208"
    format = "[$symbol$version]($style) "

    [nodejs]
    symbol = " "
    style = "bold green"

    [python]
    symbol = " "
    style = "yellow"
    format = '[$symbol$version(\($virtualenv\))]($style) '

    [rust]
    symbol = " "
    style = "bold red"

    [golang]
    symbol = " "
    style = "bold cyan"

    [java]
    symbol = " "
    style = "bold red"

    [lua]
    symbol = " "
    style = "bold blue"

    [docker_context]
    symbol = " "
    style = "blue"
    format = "[$symbol$context]($style) "
    only_with_files = true

    [cmd_duration]
    min_time = 2000
    format = "took [$duration]($style) "
    style = "bold yellow"

    [jobs]
    symbol = "✦ "
    style = "bold blue"
    number_threshold = 1

    [battery]
    format = "[$symbol$percentage]($style) "
    [[battery.display]]
    threshold = 30
    style = "bold red"
    [[battery.display]]
    threshold = 100
    style = "dimmed green"
    charging_symbol = "󰂄"
    discharging_symbol = "󰁽"

    [username]
    show_always = false
    style_user = "bold dimmed blue"
    style_root = "bold red"
    format = "[$user]($style)"

    [hostname]
    ssh_only = true
    style = "bold green"
    format = "[@$hostname]($style) "

    [time]
    disabled = false
    time_format = "%a %H:%M"
    style = "dimmed white"
    format = "[ $time]($style)"

    [status]
    disabled = false
    symbol = "✗"
    style = "bold red"
    format = '[$symbol]($style) '
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
