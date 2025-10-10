# waybar/themes.nix
{lib, ...}:
with lib; {
  themeConfig = {
    Tokyo = {
      colors = {
        bg = "#1a1b26";
        bg-alt = "#16161e";
        bg-alt2 = "#24283b";
        bg-alt3 = "#414868";
        border = "#565f89";
        border2 = "#6183bb";
        text = "#c0caf5";
        text-dark = "#1a1b26";
        accent = "#7aa2f7";
        accent2 = "#bb9af7";
        red = "#f7768e";
      };
      kittyTheme = "Tokyo Night";
    };

    Catppuccin = {
      colors = {
        bg = "#1e1e2e";
        bg-alt = "#11111b";
        bg-alt2 = "#181825";
        bg-alt3 = "#313244";
        border = "#585b70";
        border2 = "#45475a";
        text = "#cdd6f4";
        text-dark = "#181825";
        accent = "#b4befe";
        accent2 = "#cba6f7";
        red = "#f38ba8";
      };
      kittyTheme = "Catppuccin-Mocha";
    };

    Rosepine = {
      colors = {
        bg = "#191724";
        bg-alt = "#1f1d2e";
        bg-alt2 = "#26233a";
        bg-alt3 = "#403d52";
        border = "#524f67";
        border2 = "#6e6a86";
        text = "#e0def4";
        text-dark = "#191724";
        accent = "#c4a7e7";
        accent2 = "#ebbcba";
        red = "#eb6f92";
      };
      kittyTheme = "Rosé Pine";
    };

    Oxocarbon = {
      colors = {
        bg = "#161616";
        bg-alt = "#0f1419";
        bg-alt2 = "#262626";
        bg-alt3 = "#393939";
        border = "#525252";
        border2 = "#6f6f6f";
        text = "#f2f4f8";
        text-dark = "#161616";
        accent = "#78a9ff";
        accent2 = "#be95ff";
        red = "#ff7eb6";
      };
      kittyTheme = "Carbonfox";
    };
  };

  generateColorsCss = theme: colors: ''
    @define-color bg ${colors.bg};
    @define-color bg-alt ${colors.bg-alt};
    @define-color bg-alt2 ${colors.bg-alt2};
    @define-color bg-alt3 ${colors.bg-alt3};
    @define-color border ${colors.border};
    @define-color border2 ${colors.border2};
    @define-color text ${colors.text};
    @define-color text-dark ${colors.text-dark};
    @define-color accent ${colors.accent};
    @define-color accent2 ${colors.accent2};
    @define-color red ${colors.red};
  '';

  generateRofiTheme = theme: colors: ''
    * {
        font: "Maple Mono NF 12";
        background: ${colors.bg};
        bg-alt: ${colors.bg-alt};
        background-alt: ${colors.bg-alt2};
        foreground: ${colors.text};
        selected: ${colors.accent};
        active: ${colors.accent2};
        urgent: ${colors.red};
    }
  '';
}
