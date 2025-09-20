{
  config,
  pkgs,
  lib,
  ...
}:
let
  dotsPath = ../../dots;
  
  # Helper function to conditionally create config file
  mkConfigFile = configPath: sourcePath:
    lib.mkIf (builtins.pathExists sourcePath) {
      "${configPath}".source = sourcePath;
    };
  
  # Helper for directories
  mkConfigDir = configPath: sourcePath:
    lib.mkIf (builtins.pathExists sourcePath) {
      "${configPath}".source = sourcePath;
      "${configPath}".recursive = true;
    };
    
in
{
  xdg.configFile = lib.mkMerge [
    # Files
    (mkConfigFile "starship.toml" "${dotsPath}/starship.toml")
    (mkConfigFile "hyfetch.json" "${dotsPath}/hyfetch.json")
    
    # Directories (recursive)
    (mkConfigDir "beets" "${dotsPath}/beets")
    (mkConfigDir "btop" "${dotsPath}/btop")
    (mkConfigDir "cava" "${dotsPath}/cava")
    (mkConfigDir "fastfetch" "${dotsPath}/fastfetch")
    (mkConfigDir "ghostty" "${dotsPath}/ghostty")
    (mkConfigDir "helix" "${dotsPath}/helix")
    (mkConfigDir "hypr" "${dotsPath}/hypr")
    (mkConfigDir "kew" "${dotsPath}/kew")
    (mkConfigDir "kitty" "${dotsPath}/kitty")
    (mkConfigDir "picom" "${dotsPath}/picom")
    (mkConfigDir "qtile" "${dotsPath}/qtile")
    (mkConfigDir "sysfetch" "${dotsPath}/sysfetch")
    (mkConfigDir "tut" "${dotsPath}/tut")
    (mkConfigDir "waybar" "${dotsPath}/waybar")
  ];

  home.activation = {
    makeScriptsExecutable = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      find "$HOME/.config" -name "scripts" -type d -exec find {} -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \; 2>/dev/null || true
      
      if [ -f "$HOME/.config/qtile/autostart.sh" ]; then
        chmod +x "$HOME/.config/qtile/autostart.sh"
      fi
    '';
  };
}
