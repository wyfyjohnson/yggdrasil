{
  pkgs,
  huginn,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Development tools
    alejandra
    bash-language-server
    git
    nil

    # Terminal utilities
    bottom
    curl
    eza
    fastfetch
    hyfetch
    krabby
    onefetch
    tut
    wget
    yazi

    # Media and utilities
    kew
    yt-dlp

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

    # Custom packages
    (pkgs.callPackage ../../yggdrasil.nix {})
    huginn.packages.${pkgs.system}.default
  ];
}
