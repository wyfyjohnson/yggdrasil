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
    jetbrains.idea-oss

    # Browsers & Communication
    bitwarden-cli
    firefox
    rbw
    signal-desktop
    vivaldi

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
    jdk21
    nodejs
    python3

    # Language servers
    gopls
    marksman
    jdt-language-server
    pyright
    ruff
    rust-analyzer
    vscode-langservers-extracted

    # Shell
    zsh-autosuggestions
    zsh-syntax-highlighting

    # Custom packages
    (pkgs.callPackage ../../yggdrasil.nix { })
    huginn.packages.${pkgs.stdenv.hostPlatform.system}.default
    wfetch.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
