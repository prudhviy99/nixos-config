{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    
    # These attributes are natively supported at the top level
    userName = "Prudhvi Yalamanchili";
    userEmail = "prudhviy99@gmail.com";
    
    ignores = [ 
      ".DS_Store" 
      "*.swp" 
      ".direnv/" 
      "result" 
      "result-*" 
    ];

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      lg = "log --oneline --graph --decorate -20";
    };

    # Custom options go into extraConfig using Nix's dot syntax
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
      
      # This fixes your initial authentication problem securely using the GitHub CLI
      credential.helper = "${pkgs.gh}/bin/gh auth git-credential";
    };
  };
}
