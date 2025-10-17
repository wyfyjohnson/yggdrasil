{
  config,
  pkgs,
  lib,
  ...
}: {
  # Jormungandr-specific Hyprland configuration
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Link the jormungandr-specific hyprland.conf
  environment.etc."xdg/hypr/hyprland.conf".source = ./hypr/hyprland.conf;
}
