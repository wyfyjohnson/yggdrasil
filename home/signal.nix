{
  config,
  pkgs,
  lib,
  ...
}: {
  # Signal desktop application
  programs.signal-desktop = {
    enable = true;
  };

  # Signal desktop entry with gnome-libsecret keyring
  xdg.desktopEntries.signal-desktop = lib.mkIf pkgs.stdenv.isLinux {
    name = "Signal";
    exec = "signal-desktop --password-store=gnome-libsecret %U";
    terminal = false;
    icon = "signal-desktop";
    categories = ["Network" "InstantMessaging"];
    mimeType = [
      "x-scheme-handler/sgnl"
      "x-scheme-handler/signalcaptcha"
    ];
    comment = "Private messaging from your desktop/lappy";
    genericName = "Instant Messaging";
  };
}
