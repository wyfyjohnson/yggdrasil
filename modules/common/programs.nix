{ ... }:
{
  programs.direnv.enable = true;
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
  };
  programs.nix-ld.enable = true;
}
