{
  config,
  pkgs,
  lib,
  ...
}: let
  dotsPath = ../dots;
  fileExists = path: builtins.pathExists path;

  # Cross-platform configs
  commonConfigDirs = [
    # "beets"
    "btop"
    "fastfetch"
    "ghostty"
    "kew"
    "kitty"
    "sysfetch"
    "tut"
  ];

  # Linux-only configs
  linuxConfigDirs = [
    "cava"
    "picom"
    "waybar"
  ];

  configDirs = lib.listToAttrs (
    lib.forEach (commonConfigDirs ++ (lib.optionals pkgs.stdenv.isLinux linuxConfigDirs))
    (
      name:
        lib.nameValuePair name {
          source = dotsPath + "/${name}";
          recursive = true;
        }
    )
  );
in {
  # Linux configuration
  xdg.configFile = lib.mkIf pkgs.stdenv.isLinux (configDirs
    // {
      # Qtile specific files
      "qtile/config.py" = lib.mkIf (fileExists "${dotsPath}/qtile/config.py") {
        source = dotsPath + "/qtile/config.py";
      };
      "qtile/autostart.sh" = lib.mkIf (fileExists "${dotsPath}/qtile/autostart.sh") {
        source = dotsPath + "/qtile/autostart.sh";
        executable = true;
      };
    });

  # macOS configuration
  home.file = lib.mkIf pkgs.stdenv.isDarwin (
    # Common directories
    (lib.mapAttrs' (name: value: {
        name = ".config/${name}";
        value = value;
      })
      configDirs)
    //
    # macOS-specific files
    {
      ".config/yabai/yabairc" = lib.mkIf (fileExists "${dotsPath}/yabai/yabairc") {
        source = dotsPath + "/yabai/yabairc";
        executable = true;
      };
      ".config/skhd/skhdrc" = lib.mkIf (fileExists "${dotsPath}/skhd/skhdrc") {
        source = dotsPath + "/skhd/skhdrc";
      };
    }
  );
}
