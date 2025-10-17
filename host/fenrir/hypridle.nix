{pkgs, ...}: {
  xdg.configFile."hypridle/hypridle.conf".text = ''
    general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = hyprctl dispatch dpms on
    }

    listener {
        timeout = 600
        on-timeout = loginctl lock-session
    }

    listener {
        timeout = 900
        on-timeout = systemctl suspend
    }
  '';

  systemd.user.services.hypridle = {
    Unit = {
      Description = "Hyprland Idle Management Daemon";
      PartOf = ["hyprland-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.hypridle}/bin/hypridle";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["hyprland-session.target"];
    };
  };
}
