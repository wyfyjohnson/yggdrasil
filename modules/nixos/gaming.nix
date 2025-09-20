# modules/nixos/gaming.nix
{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Gaming-related configuration

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # GameMode for better gaming performance
  programs.gamemode.enable = true;

  # Gaming packages
  environment.systemPackages = with pkgs; [
    # Game launchers
    lutris
    heroic
    bottles

    # Emulation
    retroarch

    # Game development
    godot_4

    # Gaming utilities
    mangohud # Performance overlay
    goverlay # MangoHud GUI
    gamemode # Gaming optimizations

    # Controllers
    jstest-gtk # Joystick testing
  ];

  # Hardware support for gaming
  hardware = {
    # Enable Xbox controller support
    xone.enable = true;

    # Enable PlayStation controller support
    steam-hardware.enable = true; # Uncomment for Steam Controller
  };

  # Kernel modules for controllers
  boot.extraModulePackages = with config.boot.kernelPackages; [
    xone # Xbox One/Series controller driver
  ];

  # Performance tweaks
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642; # Increase map count for some games
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable 32-bit libraries for gaming
  hardware.graphics.enable32Bit = true;
  services.pulseaudio.support32Bit = true;
}
