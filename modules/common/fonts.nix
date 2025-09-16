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
      fira-code-nerdfont
      jetbrains-mono
      source-code-pro

      # System fonts
      inter
      roboto
      open-sans
      liberation_ttf

      # Noto fonts for better Unicode coverage
      noto-fonts
      noto-fonts-emoji

    ];

    # Font configuration
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Liberation Serif"
          "DejaVu Serif"
        ];
        sansSerif = [
          "Inter"
          "Liberation Sans"
          "DejaVu Sans"
        ];
        monospace = [
          "FiraCode Nerd Font"
          "Liberation Mono"
          "DejaVu Sans Mono"
        ];
      };

      # Additional font configuration
      localConf = ''
        <alias>
          <family>monospace</family>
          <prefer>
            <family>FiraCode Nerd Font</family>
            <family>JetBrainsMono Nerd Font</family>
          </prefer>
        </alias>
      '';
    };
  };
}
