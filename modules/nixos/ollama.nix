{
  config,
  lib,
  pkgs,
  ...
}:
{
  services = {
    ollama = {
      openFirewall = true;
      enable = true;
      package = pkgs.ollama-rocm;
      host = "0.0.0.0";
      port = 11434;
      rocmOverrideGfx = "11.0.0";
      environmentVariables = {
        ROCR_VISIBLE_DEVICES = "0";
      };
    };
    open-webui.enable = true;
  };
}
