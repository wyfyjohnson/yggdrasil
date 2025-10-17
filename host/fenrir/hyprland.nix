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

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
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
  };
}
