{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    ignores = [ 
      ".DS_Store" 
      "*.swp" 
      ".direnv/" 
      "result" 
      "result-*"
    ];

    settings = {
      user = {
        name = "Prudhvi Yalamanchili";
        email = "prudhviy99@gmail.com";
      };

      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        lg = "log --oneline --graph --decorate -20";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
      
      # This fixes your initial authentication problem securely using the GitHub CLI
      credential.helper = "${pkgs.gh}/bin/gh auth git-credential";
    };
  };
}
