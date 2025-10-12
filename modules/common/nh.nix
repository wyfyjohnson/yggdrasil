{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.nh = {
    enable = true;

    # Clean settings work on both platforms
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 5";

    # Point to your flake location
    # This will be different per host, but can be overridden in host configs
    flake = lib.mkDefault "/home/wyatt/yggdrasil"; # Linux default
  };
}
