{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    # Common modules
    # ../../modules/common/users.nix
    # ../../home/dotfiles.nix

    # Darwin-specific modules
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/system.nix
    ../../modules/darwin/fonts.nix
    ../../modules/darwin/locale.nix
    ../../modules/darwin/dotfiles.nix
  ];

  # System basics
  system.stateVersion = 4;
  ids.gids.nixbld = 350;

  # Primary User
  system.primaryUser = "wyatt";

  # Nix configuration
  nix = {
    package = pkgs.nixVersions.latest;
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

    # Opimise nix-store
    optimise.automatic = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    bottom
    curl
    git
    helix
    tree
    # raycast
    unzip
    vim
    wget
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
      AppleFontSmoothing = 1;
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
  security.pam.services.sudo_local.touchIdAuth = true;
}
