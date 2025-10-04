{
  config,
  pkgs,
  lib,
  hostname ? "unknown",
  ...
}: let
  dotsPath = ../dots;
  fileExists = path: builtins.pathExists path;
in
  lib.mkIf pkgs.stdenv.isLinux {
    # Linux-specific programs
    programs = {
      firefox = {
        enable = true;
        profiles.wyatt = lib.mkIf (fileExists "${dotsPath}/firefox") {
          # Firefox dotfiles would be handled by dotfiles.nix
          settings = {
            # Basic privacy settings if no custom user.js
            "privacy.donottrackheader.enabled" = lib.mkDefault true;
            "privacy.trackingprotection.enabled" = lib.mkDefault true;
            "dom.security.https_only_mode" = lib.mkDefault true;
          };
        };
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
      bluez
      cava
      discord
      dunst
      gcr
      grim
      mullvad-vpn
      libreoffice-fresh
      nitrogen
      signal-desktop
      picom
      pamixer
      hyprshot
      wf-recorder
      cliphist
      wl-clipboard
      pavucontrol
      rofi-wayland
      upower
      vivaldi
      waybar
      webcord
      swww
      xxHash
      imagemagick
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

    xdg.configFile."hypr/hyprland.conf".source =
      if hostname == "fenrir"
      then ../host/fenrir/hypr/hyprland.conf
      else if hostname == "jormungandr"
      then ../host/jormungandr/hypr/hyprland.conf
      else ../host/fenrir/hypr/hyprland.conf;
    # XDG user directories (Linux-specific)
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
    };
  }
