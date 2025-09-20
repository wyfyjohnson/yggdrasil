{ config, pkgs, lib, ... }:
{
  # Time zone configuration
  time.timeZone = "America/Los_Angeles";

  # Darwin-specific locale settings
  system.defaults = {
    NSGlobalDomain = {
      AppleLocale = "en_US";
      AppleMeasurementUnits = "Inches";
      AppleTemperatureUnit = "Fahrenheit";
      AppleICUForce24HourTime = true; # Use 24-hour time
    };

    # Regional settings
    ".GlobalPreferences" = {
      AppleLocale = "en_US";
      AppleLanguages = [ "en_US" ];
    };
  };

  # Keyboard settings for macOS
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };
}
