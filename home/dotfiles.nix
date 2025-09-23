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
    "beets"
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

  #   # Combine configs based on platform
  #   configList = commonConfigs ++ (lib.optionals pkgs.stdenv.isLinux linuxConfigs);

  #   configDirs = lib.listToAttrs (
  #     lib.forEach configList
  #     (
  #       name:
  #         lib.nameValuePair name {
  #           source = dotsPath + "/${name}";
  #           recursive = true;
  #         }
  #     )
  #   );

  #   # Qtile files - Linux only
  #   qtileFiles = lib.optionalAttrs pkgs.stdenv.isLinux {
  #     "qtile/config.py".source = dotsPath + "/qtile/config.py";
  #     "qtile/autostart.sh" = {
  #       source = dotsPath + "/qtile/autostart.sh";
  #       executable = true;
  #     };
  #   };
  # in {
  #   # Use xdg.configFile on Linux, home.file on macOS
  #   xdg.configFile = lib.mkIf pkgs.stdenv.isLinux (configDirs // qtileFiles);

  #   home.file = lib.mkIf pkgs.stdenv.isDarwin (
  #     lib.mapAttrs' (name: value: {
  #       name = ".config/${name}";
  #       value = value;
  #     })
  #     configDirs
  #   );
  # }
  # Create directory mappings
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
