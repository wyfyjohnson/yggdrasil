{ config, pkgs, lib, ... }:
{
  # Time zone configuration
  time.timeZone = "America/Los_Angeles";

  # Internationalization settings
  i18n = {
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

  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # Use xkb settings in console
  };

  # Keyboard layout
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
      options = "caps:escape"; # Map Caps Lock to Escape
    };
  };
}
