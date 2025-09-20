{ config
, pkgs
, lib
, ...
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
      qtile.enable = true;
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
      theme = "catppuccin-sddm-corners";
      wayland.enable = true;
    };
  };
  # Wayland support
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
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
    helix
    rofi
  ];

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
