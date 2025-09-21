{
  config,
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isLinux {
  # Linux-specific programs
  programs = {
    firefox = {
      enable = true;
    };
  };

  # Linux-specific services
  services = {
    # GPG agent for key management
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-curses;
    };
  };

  # Linux-specific packages
  home.packages = with pkgs; [
    firefox
    beets-unstable
    cava
    discord
    dunst
    gcr
    grim
    mullvad-vpn
    nitrogen
    signal-desktop
    upower
    vivaldi
    waybar
    webcord
    # System monitoring
    btop-rocm
    neofetch
    # File management
    yazi
  ];

  # GTK theming (for GUI applications)
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  # Linux-specific environment variables
  home.sessionVariables = {
    BROWSER = "vivaldi";
    TERMINAL = "ghostty";
  };

  # XDG user directories (Linux-specific)
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
