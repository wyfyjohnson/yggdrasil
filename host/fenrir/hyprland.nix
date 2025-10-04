{
  config,
  pkgs,
  lib,
  ...
}: {
  # Fenrir-specific Hyprland configuration
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Link the fenrir-specific hyprland.conf
  environment.etc."xdg/hypr/hyprland.conf".source = ./hypr/hyprland.conf;
}
