{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Bootloader configuration for desktop systems
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    grub.enable = lib.mkForce false; # Explicitly disable GRUB
  };

  # Desktop environment configuration
  services.xserver = {
    enable = true;
    displayManager = {
      lightdm.enable = false;
    };
    windowManager = {
      qtile = {
        enable = true;
      };
    };
    desktopManager = {
      cinnamon.enable = true;
    };
    xkb = {
      layout = "us";
      variant = "";
    };
  };
  # Display Manager - SDDM with Catppuccin theme
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # Audio - PipeWire as primary audio server
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true; # Optional: enable JACK support
  };

  # Disable PulseAudio to avoid conflicts
  services.pulseaudio.enable = lib.mkForce false;

  # Enable RealtimeKit for PipeWire
  security.rtkit.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Printing
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      hplip
      brgenml1lpr
      brgenml1cupswrapper
    ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Graphics drivers
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Desktop packages
  environment.systemPackages = with pkgs; [
    nemo
    eog
    file-roller
    gnome-system-monitor
    catppuccin-sddm-corners
    jq
    bitwarden-desktop
    rofi
    rofi-rbw
    xdotool
    xsel
    lutris
    flameshot
    ghostty
    prismlauncher

    # Catppuccin Macchiato theming
    (catppuccin-gtk.override {
      variant = "macchiato";
      accents = [ "mauve" ];
    })
    (catppuccin-kvantum.override {
      variant = "macchiato";
      accent = "mauve";
    })
    catppuccin-qt5ct
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GTK_USE_PORTAL = "0";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";

    # GTK theming - Catppuccin Macchiato
    GTK_THEME = "catppuccin-macchiato-mauve-standard";

    # QT theming - use Kvantum
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE = "kvantum";
  };

  # GTK3 theme configuration - Catppuccin Macchiato
  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=catppuccin-macchiato-mauve-standard
    gtk-icon-theme-name=Adwaita
    gtk-cursor-theme-name=Bibata-Modern-Ice
    gtk-cursor-theme-size=24
  '';

  # GTK4 theme configuration - Catppuccin Macchiato
  environment.etc."xdg/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=catppuccin-macchiato-mauve-standard
    gtk-icon-theme-name=Adwaita
    gtk-cursor-theme-name=Bibata-Modern-Ice
    gtk-cursor-theme-size=24
  '';

  # Kvantum theme configuration - Catppuccin Macchiato
  environment.etc."xdg/Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=catppuccin-macchiato-mauve
  '';

  # qt5ct configuration - use Kvantum as the style
  environment.etc."xdg/qt5ct/qt5ct.conf".text = ''
    [Appearance]
    style=kvantum
    color_scheme_path=
    custom_palette=false
    standard_dialogs=default
  '';

  # qt6ct configuration - use Kvantum as the style
  environment.etc."xdg/qt6ct/qt6ct.conf".text = ''
    [Appearance]
    style=kvantum
    color_scheme_path=
    custom_palette=false
    standard_dialogs=default
  '';

  # GNOME services
  services.gnome = {
    gnome-keyring.enable = true;
    tinysparql.enable = true;
    localsearch.enable = true;
  };

  # Flatpak support
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
