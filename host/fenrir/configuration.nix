# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-ac4dc206-5a6e-4750-81bb-7c537fa1fdc8".device = "/dev/disk/by-uuid/ac4dc206-5a6e-4750-81bb-7c537fa1fdc8";
  networking.hostName = "fenrir"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.emacs.enable = true;

  # Enable the Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  # services.displayManager.cosmic-greeter.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;
  services.xserver.windowManager.qtile.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [pkgs.brgenml1lpr pkgs.brgenml1cupswrapper];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.ipp-usb.enable = true;
  services.system-config-printer.enable = true;
  programs.system-config-printer.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.wyatt = {
    isNormalUser = true;
    description = "wyatt";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "video" "input" ];
    packages = with pkgs; [
    ];
  };

  # Install firefox.
  programs = {
    git.enable = true;
    firefox.enable = true;
    kdeconnect.enable = true;
    niri.enable = true;
    steam.enable = true;
  };
  programs.bash = {
    shellAliases = {
      ls = "eza -1 --icons";
      ff = "fastfetch --percent-type 10";
      hf = "hyfetch";
      jormungandr = "ssh wyatt@192.168.69.100";
      yt-music = "yt-dlp -x --audio-format opus --replace-in-metadata uploader ' - Topic' '' --parse-metadata '%(playlist_index)s:%(meta_track)s' --parse-metadata '%(uploader)s:%(meta_album_artist)s' --embed-metadata  --format 'bestaudio/best' --audio-quality 0 -o '~/Downloads/Music/%(uploader)s/%(album)s/%(playlist_index)s - %(title)s.%(ext)s' --print '%(uploader)s - %(album)s - %(playlist_index)s %(title)s' --no-simulate";
      ":q" = "exit";
      lerebuild = "sudo nixos-rebuild switch";
      jctl = "journalctl -p 3 -xb";
      bimp = "beet import";
      sysfetch = "~/.config/sysfetch/sysfetch";
    }; 
   };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  environment.variables = {
    EDITOR = "hx";
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bash-language-server
    beets-unstable
    bottom
    btop-rocm
    cava
    cmus
    discord
    eza
    fastfetch
    flameshot
    ghostty
    gopls
    helix
    hyfetch
    kew
    krabby
    libreoffice
    marksman
    mullvad-vpn
    nil
    nitrogen
    picom
    protonup-qt
    pyright
    rofi
    ruff
    rust-analyzer
    signal-desktop
    swww
    tut
    vivaldi
    vscode-langservers-extracted
    # webcord
    wget
    yt-dlp
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.starship.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  
  ### Flatpak ###
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  }; 

  ### Virt-Manager ###
  programs.virt-manager.enable = true;
  # user.groups.libvirtd.members = ["wyatt"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  ### fonts ###
  fonts.packages = with pkgs; [
    liberation_ttf
    nerd-fonts.jetbrains-mono
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # services.envfs.enable =true;

  # Open ports in the firewall.
  # # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
