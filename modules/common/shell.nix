{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  users.users.wyatt.shell = pkgs.zsh;
}
