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
      {
        plugin = resurrect;   # save/restore session layout (windows, panes, cwd)
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;   # auto-saves resurrect state + auto-restores/auto-starts tmux
        # Must live in this plugin's own `extraConfig`, not the top-level one below:
        # continuum's run-shell reads these @continuum-* options the instant it
        # loads, and home-manager sources the top-level extraConfig only *after*
        # all plugin run-shell lines - by then it's too late, continuum has
        # already read the (unset) defaults.
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5'
          # Installs + enables a systemd --user unit (tmux.service) that starts
          # a detached tmux server at login, so there's always a server for
          # continuum-restore to restore into after a reboot.
          set -g @continuum-boot 'on'
        '';
      }
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

  # ---- Boot-time tmux server for continuum-restore ----
  # continuum's own `@continuum-boot` writes this same unit imperatively, but
  # without TMUX_TMPDIR it lands on the wrong socket: programs.tmux sets
  # secureSocket (default on Linux), which points interactive shells at
  # $XDG_RUNTIME_DIR/tmux-$UID/ via TMUX_TMPDIR - but a plain systemd user
  # service doesn't inherit that, so it falls back to /tmp/tmux-$UID/,
  # a different, invisible-to-your-shell server. Declaring it here with
  # TMUX_TMPDIR=%t (systemd specifier for the runtime dir) keeps both on the
  # same socket. continuum sees this file already exists and just enables it.
  systemd.user.services.tmux = {
    Unit.Description = "tmux default session (detached)";
    Install.WantedBy = [ "default.target" ];
    Service = {
      Type = "forking";
      Environment = [ "DISPLAY=:0" "TMUX_TMPDIR=%t" ];
      ExecStart = "${pkgs.tmux}/bin/tmux new-session -d";
      ExecStop = [
        "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh"
        "${pkgs.tmux}/bin/tmux kill-server"
      ];
      KillMode = "none";
      RestartSec = 2;
    };
  };
}
