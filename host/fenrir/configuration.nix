{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-ac4dc206-5a6e-4750-81bb-7c537fa1fdc8".device =
    "/dev/disk/by-uuid/ac4dc206-5a6e-4750-81bb-7c537fa1fdc8";
  networking.hostName = "fenrir"; # Define your hostname.

<<<<<<< HEAD
  nix.settings.experimental-features = ["nix-command" "flakes"];
=======
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
>>>>>>> 67505a7 (attempting a refactor)

  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

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

  services.xserver.enable = true;
  services.emacs.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;
  services.xserver.windowManager.qtile.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.brgenml1lpr
    pkgs.brgenml1cupswrapper
  ];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.ipp-usb.enable = true;
  services.system-config-printer.enable = true;
  programs.system-config-printer.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.wyatt = {
    isNormalUser = true;
    description = "wyatt";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "video"
      "input"
    ];
    packages = with pkgs; [
    ];
  };

  programs = {
    git.enable = true;
    firefox.enable = true;
    kdeconnect.enable = true;
    niri.enable = true;
    steam.enable = true;
  };
<<<<<<< HEAD
=======
  # programs.bash = {
  #   shellAliases = {
  #     ls = "eza -1 --icons";
  #     ff = "fastfetch --percent-type 10";
  #     hf = "hyfetch";
  #     jormungandr = "ssh wyatt@192.168.69.100";
  #     yt-music = "yt-dlp -x --audio-format opus --replace-in-metadata uploader ' - Topic' '' --parse-metadata '%(playlist_index)s:%(meta_track)s' --parse-metadata '%(uploader)s:%(meta_album_artist)s' --embed-metadata  --format 'bestaudio/best' --audio-quality 0 -o '~/Downloads/Music/%(uploader)s/%(album)s/%(playlist_index)s - %(title)s.%(ext)s' --print '%(uploader)s - %(album)s - %(playlist_index)s %(title)s' --no-simulate";
  #     ":q" = "exit";
  #     lerebuild = "sudo nixos-rebuild switch";
  #     jctl = "journalctl -p 3 -xb";
  #     bimp = "beet import";
  #     sysfetch = "~/.config/sysfetch/sysfetch";
  #   };
  # };
>>>>>>> 67505a7 (attempting a refactor)

  nixpkgs.config.allowUnfree = true;

  environment.variables = {
    EDITOR = "hx";
  };
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

  programs.starship.enable = true;
<<<<<<< HEAD
  
=======
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

>>>>>>> 67505a7 (attempting a refactor)
  ### Flatpak ###
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  ### fonts ###
  fonts.packages = with pkgs; [
    liberation_ttf
    nerd-fonts.jetbrains-mono
  ];

  services.openssh.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment?

}
