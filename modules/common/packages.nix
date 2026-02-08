{
  pkgs,
  huginn,
  wfetch,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # Development tools
    alejandra
    bash-language-server
    git
    nil

    # Terminal & Shell
    bat
    bottom
    btop-rocm
    cava
    curl
    eza
    fastfetch
    fzf
    hyfetch
    krabby
    onefetch
    starship
    tut
    wget
    yazi

    # Editors
    helix
    zed-editor

    # Browsers & Communication
    discord
    firefox
    signal-desktop
    vivaldi
    webcord

    # Media and utilities
    ascii-image-converter
    imagemagick
    kew
    mpv
    wf-recorder
    yt-dlp

    # Wayland/Hyprland tools
    cliphist
    dunst
    hyprlock
    hyprls
    hyprpicker
    hyprshot
    swww
    waybar
    wl-clipboard

    # Desktop tools
    kitty
    libreoffice
    mullvad-vpn
    nitrogen
    pamixer
    pavucontrol
    picom
    pinentry-curses
    playerctl

    # Programming languages
    nodejs
    python3

    # Language servers
    gopls
    marksman
    pyright
    ruff
    rust-analyzer
    vscode-langservers-extracted

    # Shell
    zsh-autosuggestions
    zsh-syntax-highlighting

    # Custom packages
    (pkgs.callPackage ../../yggdrasil.nix { })
    huginn.packages.${pkgs.system}.default
    wfetch.packages.${pkgs.system}.default
  ];
}
