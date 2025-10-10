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

    Gruvbox = {
      colors = {
        bg = "#282828";
        bg-alt = "#1d2021";
        bg-alt2 = "#32302f";
        bg-alt3 = "#3c3836";
        border = "#504945";
        border2 = "#665c54";
        text = "#ebdbb2";
        text-dark = "#282828";
        accent = "#98971a";
        accent2 = "#fe8019";
        red = "#cc241d";
      };
      kittyTheme = "Gruvbox Dark";
    };

    Nord = {
      colors = {
        bg = "#2e3440";
        bg-alt = "#3b4252";
        bg-alt2 = "#434c5e";
        bg-alt3 = "#4c566a";
        border = "#5e81ac";
        border2 = "#81a1c1";
        text = "#eceff4";
        text-dark = "#2e3440";
        accent = "#81A1C1";
        accent2 = "#8FBCBB";
        red = "#bf616a";
      };
      kittyTheme = "Nord";
    };

    Dracula = {
      colors = {
        bg = "#282a36";
        bg-alt = "#21222c";
        bg-alt2 = "#44475a";
        bg-alt3 = "#44475A";
        border = "#44475a";
        border2 = "#ff79c6";
        text = "#f8f8f2";
        text-dark = "#282a36";
        accent = "#bd93f9";
        accent2 = "#50FA7B";
        red = "#ff5555";
      };
      kittyTheme = "Dracula";
    };

    Everforest = {
      colors = {
        bg = "#2d353b";
        bg-alt = "#232a2e";
        bg-alt2 = "#343f44";
        bg-alt3 = "#3d484d";
        border = "#495156";
        border2 = "#d3c6aa";
        text = "#d3c6aa";
        text-dark = "#2d353b";
        accent = "#a7c080";
        accent2 = "#83c092";
        red = "#e67e80";
      };
      kittyTheme = "Everforest Dark Hard";
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

    Onedark = {
      colors = {
        bg = "#282c34";
        bg-alt = "#21252b";
        bg-alt2 = "#2c313c";
        bg-alt3 = "#3e4451";
        border = "#4b5263";
        border2 = "#5c6370";
        text = "#abb2bf";
        text-dark = "#282c34";
        accent = "#61afef";
        accent2 = "#c678dd";
        red = "#e06c75";
      };
      kittyTheme = "One Dark";
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

    Kanagawa = {
      colors = {
        bg = "#1f1f28";
        bg-alt = "#16161d";
        bg-alt2 = "#2a2a37";
        bg-alt3 = "#363646";
        border = "#54546d";
        border2 = "#727169";
        text = "#dcd7ba";
        text-dark = "#1f1f28";
        accent = "#7e9cd8";
        accent2 = "#957fb8";
        red = "#e82424";
      };
      kittyTheme = "Kanagawa";
    };
  };

  # Helper functions
  generateColorsCss = theme: colors: ''
    @define-color bg ${colors.bg};
    @define-color bg-alt ${colors.bg-alt};
    @define-color bg-alt2 ${colors.bg-alt2};
    @define-color bg-alt3 ${colors.bg-alt3};
    @define-color border ${colors.border};
    @define-color border2 ${colors.border2};
    @define-color text ${colors.text};
    @define-color tex-dark ${colors.text-dark};
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
