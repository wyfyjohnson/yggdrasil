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
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/locale.nix
    # NixOS-specific modules
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/gaming.nix
  ];

  # System basics
  system.stateVersion = "25.05";


  # Networking
  networking = {
    hostName = "jormungandr";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Host-specific services
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Host-specific overrides for desktop.nix
  services.displayManager = {
    defaultSession = "qtile";
    sddm = {
      enable = true;
      theme = "catppuccin-sddm-corners";
      wayland.enable = true;
    };
  };

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    catppuccin-sddm-corners
    tree
  ];

  # File systems (host-specific)
  fileSystems."/home" = {
    device = "dev/mapper/HOME_VG-home";
    fsType = "ext4";
  };
}
