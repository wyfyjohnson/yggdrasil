{
  config,
  pkgs,
  lib,
  ...
}: {
  # Jormungandr-specific SDDM monitor configuration
  services.displayManager.sddm.settings = {
    X11 = {
      ServerArguments = "-nolisten tcp -dpi 96";
      DisplayCommand = "${pkgs.xorg.xrandr}/bin/xrandr --output DP-1 --primary --mode 3840x2160 --pos 1080x0 --rotate normal --output DP-2 --mode 1920x1080 --pos 0x0 --rotate left";
    };
  };

  environment.systemPackages = with pkgs; [
    wlr-randr
  ];
}
