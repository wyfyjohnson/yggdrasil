{
  config,
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  # macOS-specific program configurations
  programs = {
    # macOS-specific terminal settings (basic)
    alacritty =
      lib.mkIf (fileExists "${dotsPath}/alacritty.yml" || fileExists "${dotsPath}/alacritty.toml")
      {
        enable = true;
        # Config is handled by dotfiles.nix
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
