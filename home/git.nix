{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName  = "Prudhvi Yalamanchili";
    userEmail = "prudhviy99@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
    };

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      lg = "log --oneline --graph --decorate -20";
    };

    ignores = [ ".DS_Store" "*.swp" ".direnv/" "result" "result-*" ];
  };
}
