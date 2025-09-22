{
  config,
  pkgs,
  lib,
  ...
}: let
  dotsPath = ../../dots;
  fileExists = path: builtins.pathExists path;
in {
  programs = {
    starship = lib.mkMerge [
      {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      }
      (lib.mkIf (!fileExists "${dotsPath}/starship.toml") {
        settings = {
          format = "$all$character";
          character = {
            success_symbol = "[➜](bold green)";
            error_symbol = "[➜](bold red)";
          };
          git_branch = {
            symbol = " ";
            format = "[$symbol$branch]($style) ";
          };
          git_status = {
            format = "([$all_status$ahead_behind]($style) )";
          };
        };
      })
    ];

    alacritty =
      lib.mkIf (fileExists "${dotsPath}/alacritty.yml" || fileExists "${dotsPath}/alacritty.toml")
      {
        enable = true;
        # Config is handled by dotfiles.nix
      };

    # Kitty terminal - merge with dotfile config
    # kitty = {
    #   enable = true;
    #   settings = lib.mkIf (!fileExists "${dotsPath}/kitty.conf") {
    #     font_family = "FiraCode Nerd Font";
    #     font_size = 12;
    #     enable_audio_bell = false;
    #     window_padding_width = 8;
    #     background_opacity = "0.95";

    #     # Color scheme (fallback)
    #     foreground = "#d4d4d4";
    #     background = "#1e1e1e";
    #     cursor = "#d4d4d4";

    #     # Black
    #     color0 = "#1e1e1e";
    #     color8 = "#";

    #     # Red
    #     color1 = "#f44747";
    #     color9 = "#f44747";

    #     # Green
    #     color2 = "#608b4e";
    #     color10 = "#608b4e";

    #     # Yellow
    #     color3 = "#dcdcaa";
    #     color11 = "#dcdcaa";

    #     # Blue
    #     color4 = "#569cd6";
    #     color12 = "#569cd6";

    #     # Magenta
    #     color5 = "#c678dd";
    #     color13 = "#c678dd";

    #     # Cyan
    #     color6 = "#56b6c2";
    #     color14 = "#56b6c2";

    #     # White
    #     color7 = "#d4d4d4";
    #     color15 = "#d4d4d4";
    #   };
    # };

    # Ghostty terminal
    # ghostty = {
    #   enable = true;
    #   enableBashIntegration = true;
    #   installBatSyntax = true;
    #   # Config handled by dotfiles.nix if it exists
    # };

    # Firefox (if you want to manage profiles via Nix)
    firefox = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      profiles.wyatt = lib.mkIf (fileExists "${dotsPath}/firefox") {
        # Firefox dotfiles would be handled by dotfiles.nix
        settings = {
          # Basic privacy settings if no custom user.js
          "privacy.donottrackheader.enabled" = lib.mkDefault true;
          "privacy.trackingprotection.enabled" = lib.mkDefault true;
          "dom.security.https_only_mode" = lib.mkDefault true;
        };
      };
    };
  };

  # Services that might use dotfiles
  services = lib.mkIf pkgs.stdenv.isLinux {
    # Dunst notification daemon
    dunst = lib.mkIf (!fileExists "${dotsPath}/dunstrc") {
      enable = true;
      # Fallback configuration
      settings = {
        global = {
          monitor = 0;
          follow = "mouse";
          geometry = "300x5-30+20";
          indicate_hidden = "yes";
          shrink = "no";
          transparency = 0;
          notification_height = 0;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          frame_width = 3;
          frame_color = "#aaaaaa";
          separator_color = "frame";
          sort = "yes";
          idle_threshold = 120;
          font = "Fira Code 10";
          line_height = 0;
          markup = "full";
          format = "<b>%s</b>\\n%b";
          alignment = "left";
          show_age_threshold = 60;
          word_wrap = "yes";
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "yes";
          icon_position = "left";
          max_icon_size = 32;
          sticky_history = "yes";
          history_length = 20;
          browser = "firefox";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          startup_notification = false;
          verbosity = "mesg";
          corner_radius = 0;
        };
      };
    };
  };
}
