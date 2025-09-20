{ config
, pkgs
, lib
, ...
}:
{
  # System-level macOS configuration

  # Enable automatic software updates
  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

  # Additional system defaults
  system.defaults = {
    # Menu bar
    menuExtraClock = {
      Show24Hour = true;
      ShowSeconds = false;
    };

    # Mission Control
    spaces.spans-displays = false; # Don't span spaces across displays

    # Hot corners
    dock = {
      # Disable all hot corners by default
      wvous-tl-corner = 1; # Top-left: disabled
      wvous-tr-corner = 1; # Top-right: disabled
      wvous-bl-corner = 1; # Bottom-left: disabled
      wvous-br-corner = 1; # Bottom-right: disabled
    };

    # Keyboard shortcuts
    CustomUserPreferences = {
      # Disable automatic termination of inactive apps
      NSGlobalDomain.NSDisableAutomaticTermination = true;

      # Set fast key repeat
      NSGlobalDomain.ApplePressAndHoldEnabled = false;
      NSGlobalDomain.KeyRepeat = 2;
      NSGlobalDomain.InitialKeyRepeat = 15;

      # Disable automatic spelling correction
      NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;

      # Disable automatic capitalization
      NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;

      # Show all filename extensions in Finder
      NSGlobalDomain.AppleShowAllExtensions = true;

      # Disable the "Are you sure you want to open this application?" dialog
      "com.apple.LaunchServices".LSQuarantine = false;
    };
  };

  # LaunchDaemons and LaunchAgents
  launchd.daemons = {
    # Example: Custom daemon
    # my-daemon = {
    #   serviceConfig = {
    #     Program = "${pkgs.my-package}/bin/my-program";
    #     RunAtLoad = true;
    #     KeepAlive = true;
    #   };
    # };
  };

  # System activation scripts
  system.activationScripts.postActivation.text = ''
    # Set some additional macOS preferences that can't be set via nix-darwin

    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" "

    # Disable Gatekeeper (optional, use with caution)
    # sudo spctl --master-disable

    # Set screenshots location
    mkdir -p ~/Pictures/Screenshots
    defaults write com.apple.screencapture location ~/Pictures/Screenshots

    # Restart affected applications
    killall Dock 2>/dev/null || true
    killall Finder 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true
  '';
}
