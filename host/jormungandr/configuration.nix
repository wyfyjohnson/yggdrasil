{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
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
    ./sddm.nix
  ];

  # System basics
  system.stateVersion = "25.05";

  # Networking
  networking = {
    hostName = "jormungandr";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
  };

  # Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

  # Host-specific services
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    tree
  ];

  # File systems (host-specific)
  fileSystems."/home" = {
    device = "dev/mapper/HOME_VG-home";
    fsType = "ext4";
  };
}
