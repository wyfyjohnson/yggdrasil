{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs = {
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
      };
    };
    bash.enable = true;

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
  
  # Add Catppuccin Mocha theme colors directly
  settings = {
    # Catppuccin Mocha theme
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
    
    # Colors for marks (marked text in the terminal)
    mark1_foreground = "#1E1E2E";
    mark1_background = "#B4BEFE";
    
    # The 16 terminal colors
    # black
    color0 = "#45475A";
    color8 = "#585B70";
    
    # red
    color1 = "#F38BA8";
    color9 = "#F38BA8";
    
    # green
    color2 = "#A6E3A1";
    color10 = "#A6E3A1";
    
    # yellow
    color3 = "#F9E2AF";
    color11 = "#F9E2AF";
    
    # blue
    color4 = "#89B4FA";
    color12 = "#89B4FA";
    
    # magenta
    color5 = "#F5C2E7";
    color13 = "#F5C2E7";
    
    # cyan
    color6 = "#94E2D5";
    color14 = "#94E2D5";
    
    # white
    color7 = "#BAC2DE";
    color15 = "#A6ADC8";
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
