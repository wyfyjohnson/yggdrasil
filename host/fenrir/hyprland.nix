{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.etc."xdg/hypr/hyprland.conf".source = ./hypr/hyprland.conf;
}
