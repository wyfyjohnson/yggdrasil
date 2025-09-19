{ config, pkgs, lib, ... }:
{
  # User configuration that works across NixOS and Darwin
  users.users.wyatt = {
    description = "Wyatt";
    shell = pkgs.zsh;
    
    # Platform-specific settings using conditional logic
    home = if pkgs.stdenv.isDarwin then "/Users/wyatt" else "/home/wyatt";
    
    # NixOS-specific user settings
    isNormalUser = lib.mkIf pkgs.stdenv.isLinux true;
    extraGroups = lib.mkIf pkgs.stdenv.isLinux [ 
      "wheel"          
      "networkmanager" 
      "audio"          
      "video"          
    ];
    
    # Darwin-specific settings  
    name = lib.mkIf pkgs.stdenv.isDarwin "wyatt";
  };
  
  # Enable zsh system-wide on both platforms
  programs.zsh.enable = true;
  
  # Platform-specific sudo configuration
  security = lib.mkMerge [
    # NixOS sudo configuration
    (lib.mkIf pkgs.stdenv.isLinux {
      sudo = {
        enable = true;
        wheelNeedsPassword = false; # Passwordless sudo for wheel group
      };
    })
    
    # Darwin sudo configuration  
    (lib.mkIf pkgs.stdenv.isDarwin {
      pam.services.sudo_local.touchIdAuth = true; # Touch ID for sudo
    })
  ];
}
