{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./hypr.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "jormungandr";
 
  networking.networkmanager.enable = true;

  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
  services.xserver.desktopManager.cinnamon.enable = true;

  
   time.timeZone = "America/Los_Angeles";

  # Enable the X11 windowing system.
  services.xserver = {
     enable = true;
     autoRepeatDelay = 200;
     autoRepeatInterval = 35;
     windowManager.qtile.enable = true;
   #   displayManager = {
   #     lightdm.enable = true;
   #     setupCommands= ''
   #       LEFT='DP-2'
   #       RIGHT='DP-1'
   #       ${pkgs.xorg.xrandr}/bin/xrandr --output $RIGHT --rotate normal --output $LEFT --rotate left
   #      '';
   # };
  };

  services.displayManager = {
    defaultSession = "qtile";
    sddm = {
      enable = true;
      theme = "catppuccin-sddm-corners";
      wayland.enable = true;
    };
  };


  fileSystems."/home" = {
    device = "dev/mapper/HOME_VG-home";
    fsType = "ext4";
  };
  
  services = {
    printing = {
      enable = true;
      drivers = [pkgs.brgenml1lpr pkgs.brgenml1cupswrapper];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable =true;
    system-config-printer.enable = true;
  };
  programs.system-config-printer.enable = true;
  
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.wyatt = {
     isNormalUser = true;
     extraGroups = [ "wheel" ];
     packages = with pkgs; [
       flatpak
       tree
     ];
   };

   programs = {
     firefox.enable = true;
     kdeconnect.enable = true;
     steam.enable = true;
   };

  environment.systemPackages = with pkgs; [
    catppuccin-sddm-corners    
  ];
  
  fonts.packages = with pkgs; [
    liberation_ttf
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  system.stateVersion = "25.05";

}

