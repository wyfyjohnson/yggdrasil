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

  services.hypridle = {
    enable = true;

    general = {
      lock_cmd = "pidof hyprlock || hyprlock";
      before_sleep_cmd = "loginctl lock-screen";
      after_sleep_cmd = "hyprctl dispatch dpms on";
    };

    listeners = [
      {
        timeout = 600;
        on-timeout = "loginctl lock-session";
      }
      {
        timeout = 900;
        on-timeout = "systemctl suspend";
      }
    ];
  };
}
