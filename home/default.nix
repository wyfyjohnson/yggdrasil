{ config
, pkgs
, lib
, ...
}:

{
  # Basic home manager settings
  home = {
    username = "wyatt";
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/wyatt" else "/home/wyatt";

    stateVersion = "25.05";
  };

  # Fixed imports - no conditional logic that depends on pkgs
  imports = [
    ./git.nix
    ./programs.nix
    ./shell.nix
    ./linux.nix
    ./dotfiles.nix
    ../modules/common/helix.nix
    # ./darwin.nix  # Comment out for now since you're testing on Linux
  ];

  # Basic programs
  programs = {
    home-manager.enable = true;
  };

  # Basic packages
  home.packages = with pkgs; [
    # Development tools
    bash-language-server
    git
    nil
    nixpkgs-fmt

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
    yaziPlugins.starship

    # Media and utilities
    kew
    yt-dlp

    # Programming languages and tools
    nodejs
    python3

    # Language servers
    gopls
    marksman
    pyright
    ruff
    rust-analyzer
    vscode-langservers-extracted
  ];
}
