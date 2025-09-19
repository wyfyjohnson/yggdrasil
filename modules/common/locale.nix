{ config, pkgs, lib, ... }:
{
  # Time zone configuration (works on both platforms)
  time.timeZone = "America/Los_Angeles";

  # Internationalization settings (NixOS only)
  i18n = lib.mkIf pkgs.stdenv.isLinux {
    defaultLocale = "en_US.UTF-8";
    
    extraLocaleSettings = {
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
    
    # Input method support (optional - uncomment if needed)
    # inputMethod = {
    #   enabled = "ibus";
    #   ibus.engines = with pkgs.ibus-engines; [ libpinyin ];
    # };
  };

  # Console configuration (NixOS only)
  console = lib.mkIf pkgs.stdenv.isLinux {
    font = "Lat2-Terminus16";
    keyMap = "us";
    useXkbConfig = true; # Use xkb settings in console
  };

  # Keyboard layout (NixOS only)
  services.xserver = lib.mkIf pkgs.stdenv.isLinux {
    xkb = {
      layout = "us";
      variant = "";
      options = "caps:escape"; # Map Caps Lock to Escape
    };
  };

  # Darwin-specific locale settings
  system = lib.mkIf pkgs.stdenv.isDarwin {
    defaults = {
      NSGlobalDomain = {
        AppleLocale = "en_US";
        AppleMeasurementUnits = "Inches";
        AppleTemperatureUnit = "Fahrenheit";
        AppleICUForce24HourTime = false; # Use 12-hour time
      };
      
      # Regional settings
      ".GlobalPreferences" = {
        AppleLocale = "en_US";
        AppleLanguages = [ "en_US" ];
      };
    };
    
    # Keyboard settings for macOS
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };
}
