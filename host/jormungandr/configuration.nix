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
    ../../modules/nixos/ollama.nix
    ./sddm.nix
    ./hyprland.nix
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
  nixpkgs.config.permittedInsecurePackages = [
    "mbedtls-2.28.10"
  ];
  hardware.amdgpu.opencl.enable = true;
  hardware.graphics = {
    enable = true;
  };
  systemd.services.ollama = {
    serviceConfig = {
      Environment = "ROCR_VISIBLE_DEVICES=0";
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
