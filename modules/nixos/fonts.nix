{
  config,
  pkgs,
  lib,
  ...
}:
{
  fonts = {
    packages = with pkgs; [
      # Programming fonts
      fira-code
      jetbrains-mono
      source-code-pro
      maple-mono.NF

      # System fonts
      liberation_ttf

      # Noto fonts for better Unicode coverage
      noto-fonts
      noto-fonts-color-emoji

      # Arabic fonts
      kawkab-mono-font

      # Icon fonts
      font-awesome

      # Selective Nerd Fonts
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];

    # Font configuration - uncommented and updated for your font selection
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Liberation Serif"
          "Noto Serif"
          "Noto Naskh Arabic"
        ];
        sansSerif = [
          "Liberation Sans"
          "Noto Sans"
          "Noto Sans Arabic"
        ];
        monospace = [
          "Maple Mono NF"
          "Kawkab Mono"
          "FiraCode Nerd Font"
          "JetBrainsMono Nerd Font"
          "Liberation Mono"
        ];
        emoji = [ "Noto Color Emoji" ];
      };

      # Font priority configuration
      localConf = ''
        <alias>
          <family>monospace</family>
          <prefer>
            <family>Maple Mono NF</family>
            <family>Kawkab Mono</family>
            <family>FiraCode Nerd Font</family>
            <family>JetBrainsMono Nerd Font</family>
            <family>Liberation Mono</family>
          </prefer>
        </alias>
      '';
    };
  };
}
