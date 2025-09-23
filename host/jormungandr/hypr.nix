{pkgs, ...}: {
  xdg.configFile."hypr/hyprland.conf" = {
    enable = true;
    recursive = true;
    source = ./hypr/hyprland.conf;
  };
}
