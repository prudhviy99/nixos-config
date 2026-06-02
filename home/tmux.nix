{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shortcut = "a";          # prefix is Ctrl+a instead of Ctrl+b
    baseIndex = 1;           # windows start at 1, not 0 (easier to reach)
    keyMode = "vi";
    mouse = true;
    historyLimit = 50000;
    terminal = "tmux-256color";
    escapeTime = 10;

    plugins = with pkgs.tmuxPlugins; [
      sensible              # community sensible defaults
      yank                  # better copy-to-system-clipboard
    ];

    extraConfig = ''
      # Reload config: prefix + r
      bind r source-file ~/.config/tmux/tmux.conf \; display "reloaded"

      # Split panes using | and -, keep CWD
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  };
}
