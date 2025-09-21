{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.git = {
    enable = true;
    userName = "wyatt";
    userEmail = "johnson.wyatt.n@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;

      # Better diff and merge tools
      diff.tool = "vimdiff";
      merge.tool = "vimdiff";

      # Color settings
      color = {
        ui = true;
        branch = "auto";
        diff = "auto";
        status = "auto";
      };

      # Core settings
      core = {
        editor = "nvim";
        autocrlf = false;
        safecrlf = false;
      };
    };

    aliases = {
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";

      # Pretty log
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";

      # Show files in last commit
      dl = "diff --name-only HEAD~1 HEAD";

      # Undo last commit
      undo = "reset --soft HEAD~1";
    };

    ignores = [
      # OS generated files
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "ehthumbs.db"
      "Thumbs.db"

      # IDE files
      ".vscode/"
      ".idea/"
      "*.swp"
      "*.swo"
      "*~"

      # Build artifacts
      "result"
      "result-*"

      # Nix
      ".direnv/"
    ];
  };
}
