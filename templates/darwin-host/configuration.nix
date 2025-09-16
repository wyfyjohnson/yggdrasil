{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    # Common modules
    # ../../modules/common/users.nix

    # Darwin-specific modules
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/system.nix
    ../../modules/darwin/fonts.nix
  ];

  # System basics
  system.stateVersion = 4;

  # Enable Nix daemon
  services.nix-daemon.enable = true;

  # Nix configuration
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';

    # Garbage collection
    gc = {
      automatic = true;
      interval = {
        Weekday = 7;
      }; # Run on Sundays
      options = "--delete-older-than 7d";
    };

    # Auto-optimize store
    settings.auto-optimise-store = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
    tree
    unzip
  ];

  # Programs
  programs = {
    zsh.enable = true;
    bash.enable = true;
  };

  # System defaults (macOS preferences)
  system.defaults = {
    # Dock settings
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.2;
      magnification = false;
      tilesize = 48;
      static-only = true;
      show-recents = false;
      show-process-indicators = true;
      orientation = "bottom";
      mineffect = "genie";
    };

    # Finder settings
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      CreateDesktop = false;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "clmv"; # Column view
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    # Login window settings
    loginwindow = {
      GuestEnabled = false;
      DisableConsoleAccess = true;
    };

    # Screen capture settings
    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
      disable-shadow = true;
    };

    # Trackpad settings
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };

    # Global settings
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      _HIHideMenuBar = false;
    };
  };

  # Keyboard settings
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # Users (defined in modules/common/users.nix)
  users.users.wyatt = {
    name = "wyatt";
    home = "/Users/wyatt";
    shell = pkgs.zsh;
  };

  # Security settings
  security.pam.enableSudoTouchIdAuth = true;
}
