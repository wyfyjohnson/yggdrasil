{pkgs, ...}: {
  services.hypridle = {
    enable = true;
    general = {
      lock_cmd = "pidof hyprlock || hyprlock";
      before_sleep_cmd = "loginctl lock-session";
      after_sleep_cmd = "hyprctl dispatch dpms on";
      ignore_dbus_inhibit = false;
    };

    listener = [
      {
        timeout = 600;
        on-timeout = "loginctl lock-session";
      }
      {
        timeout = 660;
        on-timeout = "hyprctl dispatch dpms off";
        on-resume = "hyprctl dispatch dpms on";
      }
      {
        timeout = 900;
        on-timeout = "systemctl suspend";
      }
    ];
  };

  home.packages = with pkgs; [
    hypridle
    hyprlock
  ];
}
