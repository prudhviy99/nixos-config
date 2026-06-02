{ config, pkgs, ... }:

{
  # ---- zsh ----
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    history.size = 100000;

    shellAliases = {
      ll  = "eza -l --git --icons";
      la  = "eza -la --git --icons";
      lt  = "eza --tree --level=2 --icons";
      cat = "bat --paging=never";
      g   = "git";
      lg  = "lazygit";

      # NixOS shortcuts you'll use constantly
      rebuild  = "sudo nixos-rebuild switch --flake ~/nixos-config#t14s";
      update   = "nix flake update ~/nixos-config";
      cleanup  = "sudo nix-collect-garbage --delete-older-than 14d";
    };

    initContent = ''
      # Paste your custom Mac zsh additions here, or use `source ~/.zshrc.local`
      # and put them in that file (untracked by git).
      [ -f ~/.zshrc.local ] && source ~/.zshrc.local
    '';
  };

  # ---- Starship prompt ----
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # Default starship config is great; tweak ~/.config/starship.toml later.
  };

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
