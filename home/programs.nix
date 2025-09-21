{
  config,
  pkgs,
  lib,
  ...
}: {
  programs = {
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
      };
    };
    bash = {
      enable = true;
      enableCompletion = true;
    };
    # Terminal emulators - basic configs
    # ghostty = {
    #   enable = true;
    #   enableBashIntegration = true;
    # };
    kitty = {
      enable = true;
      font = {
        name = "Maple Mono NF"; # or whatever font you prefer
        size = 12;
      };

      settings = {
        # Official Catppuccin Mocha colors
        foreground = "#CDD6F4";
        background = "#1E1E2E";
        selection_foreground = "#1E1E2E";
        selection_background = "#F5E0DC";

        # Cursor colors
        cursor = "#F5E0DC";
        cursor_text_color = "#1E1E2E";

        # URL underline color when hovering with mouse
        url_color = "#F5E0DC";

        # Kitty window border colors
        active_border_color = "#B4BEFE";
        inactive_border_color = "#6C7086";
        bell_border_color = "#F9E2AF";

        # Tab colors
        active_tab_foreground = "#11111B";
        active_tab_background = "#CBA6F7";
        inactive_tab_foreground = "#CDD6F4";
        inactive_tab_background = "#181825";
        tab_bar_background = "#11111B";

        # The 16 terminal colors (official Catppuccin Mocha)
        # black
        color0 = "#45475A"; # Surface1
        color8 = "#585B70"; # Surface2

        # red
        color1 = "#F38BA8"; # Red
        color9 = "#F38BA8";

        # green
        color2 = "#A6E3A1"; # Green
        color10 = "#A6E3A1";

        # yellow
        color3 = "#F9E2AF"; # Yellow
        color11 = "#F9E2AF";

        # blue
        color4 = "#89B4FA"; # Blue
        color12 = "#89B4FA";

        # magenta
        color5 = "#F5C2E7"; # Pink
        color13 = "#F5C2E7";

        # cyan
        color6 = "#94E2D5"; # Teal
        color14 = "#94E2D5";

        # white
        color7 = "#BAC2DE"; # Subtext1
        color15 = "#A6ADC8"; # Subtext0
      };
    };
    # Development tools
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    # File utilities
    fzf = {
      enable = true;
      enableBashIntegration = true;
    };
    ssh = {
      enable = true;
    };
    starship = {
      enable = true;
    };
  };
}
