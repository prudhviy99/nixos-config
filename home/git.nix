{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    ignores = [ ".DS_Store" "*.swp" ".direnv/" "result" "result-*" ];

    settings = {
      user.name  = "Prudhvi Yalamanchili";
      user.email = "prudhviy99@gmail.com";

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";

      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        lg = "log --oneline --graph --decorate -20";
      };
    };
  };
}
