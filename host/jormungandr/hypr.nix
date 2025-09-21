{pkgs, ...}: {
  xdg.configFile."hypr/hyprland.conf" = {
    enable = true;
    recursive = true;
    source = ./hypr/hyprland.conf;
  };

  programs.hyprland = {
    enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };
}
