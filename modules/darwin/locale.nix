{
  config,
  pkgs,
  lib,
  ...
}: {
  # Time zone configuration
  time.timeZone = "America/Los_Angeles";

  # Keyboard settings for macOS
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };
}
