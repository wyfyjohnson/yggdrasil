{ config, pkgs, lib, ... }:
let
  dotsPath = ../../dots;
  
  # macOS-specific configs that should be managed at system level
  systemConfigs = [
    "ghostty"
    "kitty"
    # Add other configs that should be system-wide
  ];
  
  configFiles = lib.listToAttrs (
    lib.forEach systemConfigs
      (name:
        lib.nameValuePair "etc/${name}" {
          source = dotsPath + "/${name}";
        }
      )
  );
in
{
  # System-wide file management (goes to /etc/)
  environment.etc = configFiles;
  
}
