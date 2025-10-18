{
  config,
  lib,
  pkgs,
  ...
}: {
  services = {
    ollama = {
      acceleration = "rocm";
      enable = true;
    };
    open-webui.enable = true;
  };
}
