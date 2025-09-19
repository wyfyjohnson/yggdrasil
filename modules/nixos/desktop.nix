{ 
  config,
  pkgs,
  lib,
  ...
}:
{
  # Desktop environment configuration

  # Enable X11 windowing system
  services.xserver = {
    enable = true;

    # Display manager
    displayManager = {
      # gdm.enable = true;
      lightdm.enable = true; # Alternative
    };

    # Window manager
    windowManager = {
      qtile.enable = true;
    };

    # Desktop environment (choose one)
    desktopManager = {
      cinnamon.enable = true;
      # gnome.enable = true;
      # plasma5.enable = true; # KDE Alternative
    };

    # Keyboard layout
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Wayland support (for modern compositors)
  programs.hyprland = {
    enable = true; # Set to true if you want Hyprland
    xwayland.enable = true;
  };

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
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
      # Add printer-specific drivers as needed
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
    enable32Bit = true; # For 32-bit applications
  };

  # NVIDIA drivers (uncomment if you have NVIDIA GPU)
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   open = false; # Use proprietary drivers
  #   nvidiaSettings = true;
  # };

  # AMD drivers (uncomment if you have AMD GPU)
  # services.xserver.videoDrivers = [ "amdgpu" ];

  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
    # File managers
    nemo
    # nautilus # GNOME file manager
    # dolphin     # KDE file manager

    # Image viewers
    eog # GNOME image viewer
    # gwenview    # KDE image viewer

    # Archive managers
    file-roller # GNOME archive manager

    # System monitors
    gnome-system-monitor

    # Text editors
    # gnome-text-editor

    # Media players
    # totem # GNOME video player
  ];

  # GNOME-specific configuration
  services.gnome = {
    gnome-keyring.enable = true;
    tinysparql.enable = true;
    localsearch.enable = true;
  };

  # Exclude some default GNOME applications (optional)
  # environment.gnome.excludePackages = with pkgs; [ 
  #   gnome-photos
  #   gnome-tour
  #   gnome-music
  #   epiphany # GNOME web browser
  #   geary # Email reader
  # ];

  # Flatpak support (optional)
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # AppImage support
  # programs.appimage = {
  #   enable = true;
  #   binfmt = true;
  # };
}
