{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
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

      # ---- Rosé Pine status bar — transparent, matches ghostty's translucent black bg ----
      # muted #6e6a86 · text #e0def4 · iris #c4a7e7 · foam #9ccfd8
      # gold #f6c177 · love #eb6f92

      set -g status-interval 5
      set -g status-style "bg=default,fg=#6e6a86"

      set -g status-left-length 20
      set -g status-right-length 30
      set -g status-left "#[fg=#c4a7e7] #S "
      set -g status-right "#[fg=#6e6a86]%H:%M "

      setw -g window-status-format "#[fg=#6e6a86] #I:#W "
      setw -g window-status-current-format "#[fg=#e0def4,bold] #I:#W "
      setw -g window-status-activity-style "fg=#eb6f92"
      setw -g window-status-bell-style "fg=#f6c177,bold"

      set -g pane-border-style "fg=#26233a"
      set -g pane-active-border-style "fg=#403d52"

      set -g message-style "fg=#e0def4,bg=default"
      set -g message-command-style "fg=#e0def4,bg=default"
      set -g mode-style "fg=#191724,bg=#c4a7e7"

      set -g clock-mode-colour "#9ccfd8"
      set -g clock-mode-style 24
    '';
  };
}
