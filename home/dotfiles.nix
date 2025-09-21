{ config
, pkgs
, lib
, ...
}:
let
  dotsPath = ../dots;
  
  # Cross-platform configs
  commonConfigs = [
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
  linuxConfigs = [
    "cava"
    "hypr"
    "picom"
    "waybar"
  ];
  
  # Combine configs based on platform
  configList = commonConfigs ++ (lib.optionals pkgs.stdenv.isLinux linuxConfigs);
  
  configDirs = lib.listToAttrs (
    lib.forEach configList
      (name:
        lib.nameValuePair name {
          source = dotsPath + "/${name}";
          recursive = true;
        }
      )
  );

  # Qtile files - Linux only
  qtileFiles = lib.optionalAttrs pkgs.stdenv.isLinux {
    "qtile/config.py".source = dotsPath + "/qtile/config.py";
    "qtile/autostart.sh" = {
      source = dotsPath + "/qtile/autostart.sh";
      executable = true;
    };
  };
in
{
  # Use xdg.configFile on Linux, home.file on macOS
  xdg.configFile = lib.mkIf pkgs.stdenv.isLinux (configDirs // qtileFiles);
  
  home.file = lib.mkIf pkgs.stdenv.isDarwin (
    lib.mapAttrs' (name: value: {
      name = ".config/${name}";
      value = value;
    }) configDirs
  );
}
