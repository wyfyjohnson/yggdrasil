{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan
    ./hardware-configuration.nix

    # Common modules
    ../../modules/common/fonts.nix
    ../../modules/common/locale.nix
    ../../modules/common/users.nix

    # NixOS-specific modules (uncomment as needed)
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/gaming.nix
    # ../../modules/nixos/server.nix
  ];

  # System basics
  system.stateVersion = "25.05";

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  fileSystems."/home" = {
    device = "dev/mapper/HOME_VG-home";
    fsType = "ext4";
  };
  # Networking
  networking = {
    hostName = "jormungandr"; # Change this
    networkmanager.enable = true;

    # Firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  # Enable flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Auto-optimize store
    settings.auto-optimise-store = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    catppuccin-sddm-corners
    vim
    htop
    tree
    unzip
  ];
  # Programs
  programs = {
    hyprland = {
      enable = true;
      protalPackage = pkgs.xdg-desktop-portal-hyprland;
      xwayland.enable = true;
    };
  };
  # Services
  services = {
    displayManager = {
      defaultSession = "qtile";
      sddm = {
        enable = true;
        theme = "catppuccin-sddm-corners";
        wayland.enable = true;
      };
    };
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
      xserver = {
        enable = true;
        autoRepeatDelay = 200;
        autoRepeatInterval = 35;
        windowManager.qtile.enable = true;
      };
    };

    # Printing support (uncomment if needed)
    # printing.enable = true;

    # Sound with PipeWire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  # Hardware
  hardware = {
    # Enable sound
    pulseaudio.enable = false; # Using PipeWire instead

    # Enable bluetooth (uncomment if needed)
    bluetooth.enable = true;
  };

  # Security
  security = {
    rtkit.enable = true; # For PipeWire
    sudo.wheelNeedsPassword = false; # Optional: passwordless sudo for wheel group
  };

  # Users (defined in modules/common/users.nix)
  # users.users.wyatt = {
  #   isNormalUser = true;
  #   description = "Wyatt";
  #   extraGroups = [ "networkmanager" "wheel" ];
  # };
  
  nixpkgs.config.allowUnfree = true;
}
