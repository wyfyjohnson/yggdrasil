{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs = {
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
      };
    };
    bash.enable = true;

    # Terminal emulators - basic configs
    # ghostty = {
    #   enable = true;
    #   enableBashIntegration = true;
    # };
    kitty = {
      enable = true;
      settings = {
        font_family = "monospace";
        font_size = 12;
      };
    };

    # Development tools
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    # File utilities
    fzf = {
      enable = true;
      enableBashIntegration = true;
    };
    ssh = {
      enable = true;
    };
    starship = {
      enable = true;
    };
  };
}
