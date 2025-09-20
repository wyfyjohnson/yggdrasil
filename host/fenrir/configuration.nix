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
    ../../modules/common/users.nix

    # NixOS-specific modules (uncomment as needed)
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/locale.nix
    # ../../modules/nixos/server.nix
  ];

  # System basics
  system.stateVersion = "25.05";
  nixpkgs.config.allowUnfree = true;

  boot.initrd.luks.devices."luks-ac4dc206-5a6e-4750-81bb-7c537fa1fdc8".device =
    "/dev/disk/by-uuid/ac4dc206-5a6e-4750-81bb-7c537fa1fdc8";
    
  # Networking
  networking = {
    hostName = "fenrir";
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
    package = pkgs.nixVersions.stable;
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

    # Sound with PipeWire
    
    # Printing support (uncomment if needed)
    printing = {
      enable = true;
      drivers = [
    pkgs.brgenml1lpr
    pkgs.brgenml1cupswrapper
      ];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable = true;
    system-config-printer.enable = true;
  };

  programs.system-config-printer.enable = true;

  # Users (defined in modules/common/users.nix)
  # users.users.wyatt = {
  #   isNormalUser = true;
  #   description = "Wyatt";
  #   extraGroups = [ "networkmanager" "wheel" ];
  # };
}
