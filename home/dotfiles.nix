{ config
, pkgs
, lib
, ...
}:
let
  dotsPath = ../dots;
  # Create config entries for directories that exist (excluding qtile)
  configDirs = lib.listToAttrs (
    lib.forEach [
      "beets"
      "btop"
      "cava"
      "fastfetch"
      "ghostty"
      # "helix"
      "hypr"
      "kew"
      "kitty"
      "picom"
      "sysfetch"
      "tut"
      "waybar"
    ]
      (name:
        lib.nameValuePair name {
          source = dotsPath + "/${name}";  # Changed from string interpolation
          # source = "${dotsPath}/${name}";
          recursive = true;
        }
      )
  );

  # Qtile-specific files to avoid __pycache__ conflicts
  qtileFiles = {
    "qtile/config.py".source = dotsPath + "/qtile/config.py";
    # "qtile/config.py".source = "${dotsPath}/qtile/config.py";
    "qtile/autostart.sh" = {
      source = dotsPath + "/qtile/autostart.sh";
      # source = "${dotsPath}/qtile/autostart.sh";
      executable = true;
    };
    # Add any other qtile files here as needed
    # "qtile/other-script.py".source = "${dotsPath}/qtile/other-script.py";
  };
in
{
  xdg.configFile = configDirs // qtileFiles;
}
