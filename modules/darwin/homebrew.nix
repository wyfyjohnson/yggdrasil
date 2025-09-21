{
  config,
  pkgs,
  lib,
  ...
}: {
  # Homebrew configuration for macOS
  homebrew = {
    enable = true;

    # Homebrew behavior
    onActivation = {
      autoUpdate = false; # Don't auto-update during rebuild
      upgrade = false; # Don't auto-upgrade during rebuild
      cleanup = "zap"; # Uninstall packages not listed
    };

    # Homebrew taps
    taps = [
      # Add more taps as needed
    ];

    # CLI tools from Homebrew (things not available in nixpkgs)
    brews = [
      # Add Homebrew formulas that aren't available in nixpkgs
    ];

    # GUI applications from Homebrew Cask
    casks = [
      # Browsers
      "firefox"
      "google-chrome"

      # Development
      "docker"
      "postman"

      # Communication
      "discord"
      "signal"

      # Utilities
      "alfred"
      "rectangle"
      "the-unarchiver"
      "appcleaner"
      "istat-menus"

      # Media
      "vlc"
      "handbrake"

      # Terminal
      "kitty"

      # Add more applications as needed
    ];

    # Mac App Store applications
    masApps = {
      # Example: "Xcode" = 497799835;
      # Find app IDs with: mas search "App Name"
    };
  };
}
