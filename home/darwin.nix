{
  config,
  pkgs,
  lib,
  ...
}: let
  dotsPath = ../dots;
  fileExists = path: builtins.pathExists path;
in
  lib.mkIf pkgs.stdenv.isDarwin {
    # macOS-specific program configurations
    programs = {
      # macOS-specific terminal settings (basic)
      alacritty =
        lib.mkIf (fileExists "${dotsPath}/alacritty.yml" || fileExists "${dotsPath}/alacritty.toml")
        {
          enable = true;
          # Config is handled by dotfiles.nix
          settings = {
            window.decorations = "buttonless";
            font.normal.family = "Maple Mono NF";
            font.size = 14;

            window.option_as_alt = "both";
          };
        };
    };

    # macOS-specific home configuration
    home = {
      # macOS-specific session variables
      sessionVariables = {
        # Add other macOS-specific variables here if needed
      };
    };
  }
