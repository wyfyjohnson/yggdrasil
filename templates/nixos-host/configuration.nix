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
    # ../../modules/nixos/desktop.nix
    # ../../modules/nixos/gaming.nix
    # ../../modules/nixos/server.nix
  ];

  # System basics
  system.stateVersion = "25.05";

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Networking
  networking = {
    hostName = "your-hostname"; # Change this
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
    vim
    wget
    curl
    git
    htop
    tree
    unzip
    firefox
  ];

  # Services
  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
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
    # bluetooth.enable = true;
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
}
