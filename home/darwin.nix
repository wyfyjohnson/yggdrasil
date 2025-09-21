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
    alacritty = {
      enable = true;
      settings = {
        window.decorations = "buttonless";
        font.normal.family = "monospace";
        font.size = 12;
      };
    };
  };

  # macOS-specific home configuration
  home = {
    # macOS-specific session variables (removed BROWSER since it's set in main config)
    sessionVariables = {
      # Add other macOS-specific variables here if needed
    };
  };
}
