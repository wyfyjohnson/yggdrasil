{ pkgs, ... }: {

  xdg.configFile."hypr" = {
    enable = true;
    recursive = true;
    source = ./hypr;
  };

  programs.hyprland = {
    enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };
}
