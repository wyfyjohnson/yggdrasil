# home/waybar.nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Import theme configurations and scripts from waybar directory
  themes = import ./waybar/themes.nix {inherit lib;};
  scripts = import ./waybar/scripts.nix {inherit pkgs config;};

  # Configuration - change these to customize
  waybarConfig = {
    theme = "Catppuccin"; # Tokyo, Catppuccin, Gruvbox, Nord, Dracula, Everforest, Rosepine, Onedark, Oxocarbon, Kanagawa
    customAccent = null; # Set to a hex color like "#7aa2f7" or leave null
    customAccent2 = null;
    enableWeather = true;
    enableRecording = true;
    position = "top";
    height = 20;
    extraModules = []; # Add extra module names here
  };

  # Get theme colors
  currentTheme = themes.themeConfig.${waybarConfig.theme};
  currentColors = currentTheme.colors;

  # Handle custom accents
  accentColor =
    if waybarConfig.customAccent != null
    then waybarConfig.customAccent
    else currentColors.accent;

  accent2Color =
    if waybarConfig.customAccent2 != null
    then waybarConfig.customAccent2
    else currentColors.accent2;
in
  lib.mkIf pkgs.stdenv.isLinux {
    # Use built-in waybar module
    programs.waybar = {
      enable = true;
      systemd.enable = true;

      settings = [
        {
          layer = "top";
          position = waybarConfig.position;
          spacing = 0;
          height = waybarConfig.height;

          modules-left =
            [
              "custom/logo"
              "clock"
              "custom/divisor"
            ]
            ++ lib.optional waybarConfig.enableWeather "custom/weather";

          modules-center =
            [
              "disk"
              "cpu"
              "memory"
              "hyprland/workspaces"
              "custom/clipboard"
              "custom/nerd"
              "custom/theme"
              "custom/wallpapers"
              "custom/screenshot"
            ]
            ++ lib.optional waybarConfig.enableRecording "custom/record"
            ++ [
              "custom/picker"
            ]
            ++ waybarConfig.extraModules;

          modules-right = [
            "tray"
            "custom/divisor"
            "custom/networkicon"
            "custom/bluetoothicon"
            "custom/volumeicon"
            "custom/batteryicon"
            "custom/divisor"
            "custom/power"
          ];

          "hyprland/workspaces" = {
            on-click = "activate";
            format = "{icon}";
            format-icons = {
              default = "";
              "1" = "一";
              "2" = "二";
              "3" = "三";
              "4" = "四";
              "5" = "五";
              "6" = "六";
              "7" = "七";
              "8" = "八";
              "9" = "九";
              active = "󱓻";
              urgent = "󱓻";
            };
            persistent-workspaces = {
              "1" = [];
              "2" = [];
              "3" = [];
              "4" = [];
              "5" = [];
            };
          };

          "custom/weather" = lib.mkIf waybarConfig.enableWeather {
            exec = "${scripts.scripts.waybarScripts}/bin/waybar-scripts weather show";
            format = "{}";
            tooltip = true;
            interval = 900;
            return-type = "json";
            on-click = "${scripts.scripts.waybarScripts}/bin/waybar-scripts weather fetch";
          };

          memory = {
            interval = 5;
            format = "󰍛 {usage}%";
            max-length = 10;
          };

          cpu = {
            interval = 5;
            format = "󰻠 {usage}%";
            max-length = 10;
          };

          disk = {
            interval = 30;
            format = "󰋊 {used}";
            path = "/";
            max-length = 20;
            tooltip-format = "Used: {used} / {total}";
          };

          tray = {
            spacing = 5;
          };

          clock = {
            format = "{:%I:%M %p}";
            format-alt = "{:%A, %B %d, %Y}";
            tooltip = true;
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "month";
              format = {
                months = "<span color='#ff6699'><b>{}</b></span>";
                days = "<span color='#cdd6f4'><b>{}</b></span>";
                weekdays = "<span color='#7CD37C'><b>{}</b></span>";
                today = "<span color='#ffcc66'><b>{}</b></span>";
              };
            };
          };

          "custom/divisor" = {
            format = "  ";
            tooltip = false;
          };

          "custom/logo" = {
            exec = "${scripts.scripts.waybarScripts}/bin/waybar-scripts quickactions --logo";
            format = "{}";
            tooltip = true;
            interval = 86400;
            return-type = "json";
            on-click = "${pkgs.rofi-wayland}/bin/rofi -show drun -theme ${config.xdg.configHome}/waybar/rofi/Launcher.rasi";
          };

          "custom/theme" = {
            exec = "${scripts.scripts.waybarScripts}/bin/waybar-scripts quickactions --theme";
            format = "{}";
            tooltip = true;
            interval = 86400;
            return-type = "json";
            on-click = "${scripts.scripts.themeSwitcher}/bin/waybar-theme-switcher";
          };

          "custom/wallpapers" = {
            exec = "${scripts.scripts.waybarScripts}/bin/waybar-scripts quickactions --wallpapers";
            format = "{}";
            tooltip = true;
            interval = 86400;
            return-type = "json";
            on-click = "${scripts.scripts.wallpaperSelector}/bin/waybar-wallpaper-selector";
          };

          "custom/screenshot" = {
            exec = "${scripts.scripts.waybarScripts}/bin/waybar-scripts quickactions --screenshot";
            format = "{}";
            tooltip = true;
            interval = 86400;
            return-type = "json";
            on-click = "${pkgs.hyprshot}/bin/hyprshot -m region";
            on-click-right = "${pkgs.hyprshot}/bin/hyprshot -m output";
          };

          "custom/record" = lib.mkIf waybarConfig.enableRecording {
            exec = "${scripts.scripts.waybarScripts}/bin/waybar-scripts quickactions --record";
            format = "{}";
            tooltip = true;
            interval = 1;
            return-type = "json";
            on-click = "${scripts.scripts.waybarScripts}/bin/waybar-scripts record";
            on-click-right = "${scripts.scripts.waybarScripts}/bin/waybar-scripts record --stop";
          };

          "custom/clipboard" = {
            exec = "${scripts.scripts.waybarScripts}/bin/waybar-scripts quickactions --clipboard";
            format = "{}";
            tooltip = true;
            interval = 86400;
            return-type = "json";
            on-click = "${pkgs.cliphist}/bin/cliphist list | ${pkgs.rofi-wayland}/bin/rofi -dmenu -theme ${config.xdg.configHome}/waybar/rofi/clipboard.rasi | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy";
          };

          "custom/nerd" = {
            exec = "${scripts.scripts.waybarScripts}/bin/waybar-scripts quickactions --nerd";
            format = "{}";
            tooltip = true;
            interval = 86400;
            return-type = "json";
            on-click = "${scripts.scripts.nerdFontSelector}/bin/waybar-nerd-font-selector";
          };

          "custom/picker" = {
            exec = "${scripts.scripts.waybarScripts}/bin/waybar-scripts quickactions --picker";
            format = "{}";
            tooltip = true;
            interval = 86400;
            return-type = "json";
            on-click = "${scripts.scripts.accentPicker}/bin/waybar-accent-picker --accent";
            on-click-right = "${scripts.scripts.accentPicker}/bin/waybar-accent-picker --accent2";
          };

          "custom/power" = {
            format = " ⏼ ";
            on-click = "${scripts.scripts.powerMenu}/bin/waybar-power-menu";
            tooltip = false;
          };

          "custom/networkicon" = {
            exec = "${scripts.scripts.waybarScripts}/bin/waybar-scripts quickactions --network";
            interval = 1;
            return-type = "json";
            format = "{}";
            tooltip = true;
          };

          "custom/bluetoothicon" = {
            exec = "${scripts.scripts.waybarScripts}/bin/waybar-scripts quickactions --bluetooth";
            interval = 1;
            return-type = "json";
            format = "{}";
            tooltip = true;
          };

          "custom/batteryicon" = {
            exec = "${scripts.scripts.waybarScripts}/bin/waybar-scripts quickactions --battery";
            interval = 1;
            return-type = "json";
            format = "{}";
            tooltip = true;
          };

          "custom/volumeicon" = {
            exec = "${scripts.scripts.waybarScripts}/bin/waybar-scripts quickactions --volume";
            interval = 1;
            return-type = "json";
            format = "{}";
            tooltip = true;
            on-click = "${pkgs.pamixer}/bin/pamixer -t";
            on-scroll-up = "${pkgs.pamixer}/bin/pamixer -i 5";
            on-scroll-down = "${pkgs.pamixer}/bin/pamixer -d 5";
          };
        }
      ];

      # Your complete CSS
      style = ''
        @import "colors.css";

        * {
          font-family: JetBrainsMono Nerd Font;
          font-size: 13px;
        }

        window#waybar {
          background-color: @bg;
        }

        window#waybar.hidden {
          opacity: 0.5;
          margin: 15px;
        }

        #workspaces {
          background-color: @bg-alt;
          padding: 2px;
          margin: 2px;
          border-radius: 10px;
        }

        #workspaces button {
          all: initial;
          min-width: 0;
          background: linear-gradient(to bottom, @bg-alt3, @bg);
          padding: 6px 12px;
          transition: all 0.1s linear;
          border-top: 1px solid @border;
          box-shadow: 0px 17px 5px 1px rgba(0, 0, 0, 0.2);
          color: @accent2;
          font-weight: 800;
          text-shadow: -1px -1px 1px rgba(205, 214, 244, 0.1),
            0px 2px 3px rgba(0, 0, 0, 0.3);
        }

        #workspaces button:first-child {
          border-top-left-radius: 6px;
          border-bottom-left-radius: 6px;
        }

        #workspaces button:last-child {
          border-top-right-radius: 6px;
          border-bottom-right-radius: 6px;
        }

        #workspaces button.empty {
          color: #737373;
          background: transparent;
          text-shadow: none;
          box-shadow: none;
        }

        #workspaces button.active {
          box-shadow: 0px 17px 5px 1px rgba(0, 0, 0, 0);
          background: linear-gradient(to bottom, @bg-alt2, @bg-alt);
          color: @text;
          font-size: 25px;
          border-top: 1px solid @border2;
          text-shadow: 0px 0px 12px @text;
        }

        #workspaces button.focused {
          background: linear-gradient(to bottom, @accent2, @bg-alt3);
          color: @bg;
          text-shadow: 0px 0px 12px @accent2;
          font-size: 22px;
          border-top: 1px solid @accent2;
        }

        #workspaces button.visible {
          background: linear-gradient(to bottom, @bg-alt3, @bg-alt2);
          color: @accent;
          text-shadow: none;
          font-size: 18px;
          border-top: 1px solid @border;
        }

        #workspaces button.urgent {
          background-color: @red;
          color: @bg;
          text-shadow: 0px 0px 8px @red;
          font-weight: bold;
        }

        #custom-divisor {
          color: @accent;
        }

        #memory,
        #cpu,
        #disk {
          margin-right: 10px;
          background-color: @bg;
          font-family: SfMono;
          font-size: 15px;
          font-weight: bold;
          color: @accent;
        }

        #clock {
          font-family: SFRegular;
          background: linear-gradient(to bottom, @bg, @bg-alt3);
          font-size: 16px;
          margin: 2px;
          padding-left: 9px;
          padding-right: 9px;
          border-radius: 8px;
          font-weight: bold;
          border-bottom: 2px solid @bg-alt;
          border-top: 1px solid @border;
          color: @text;
        }

        #network,
        #wireplumber,
        #battery {
          background: linear-gradient(to bottom, @bg-alt3, @bg);
          padding: 4px 8px;
          margin: 2px;
          border-radius: 6px;
          border-top: 1px solid @border;
          border-bottom: 2px solid @bg-alt;
          font-family: SfMono;
          font-weight: bold;
          color: @text;
          font-size: 15px;
        }

        #network:hover,
        #wireplumber:hover,
        #battery:hover {
          color: @accent;
        }

        #custom-batteryicon.charging {
          background-image: url("icons/system/BatteryChargeMinimalistic-symbolic.svg");
        }

        #custom-batteryicon.Full {
          background-image: url("icons/system/BatteryFullMinimalistic-symbolic.svg");
        }

        #custom-batteryicon.Med {
          background-image: url("icons/system/BatteryHalfMinimalistic-symbolic.svg");
        }

        #custom-batteryicon.Low {
          background-image: url("icons/system/BatteryLowMinimalistic-symbolic.svg");
        }

        #custom-batteryicon {
          background-repeat: no-repeat;
          background-size: 22px;
          min-width: 22px;
          min-height: 22px;
          background-position: center;
          border-radius: 0;
          margin-left: -2px;
          margin-right: -2px;
        }

        #custom-volumeicon.volmute {
          background-image: url("icons/system/VolumeCross-symbolic.svg");
        }

        #custom-volumeicon.volow {
          background-image: url("icons/system/Volume-symbolic.svg");
        }

        #custom-volumeicon.volmed {
          background-image: url("icons/system/VolumeSmall-symbolic.svg");
        }

        #custom-volumeicon.volfull {
          background-image: url("icons/system/VolumeLoud-symbolic.svg");
        }

        #custom-volumeicon {
          background-repeat: no-repeat;
          background-size: 22px;
          min-width: 22px;
          min-height: 22px;
          background-position: center;
          border-radius: 0;
          margin-left: 5px;
          margin-right: 6px;
        }

        #custom-bluetoothicon.BTOn {
          background-image: url("icons/system/BluetoothWave-symbolic.svg");
        }

        #custom-bluetoothicon.BTOff {
          background-image: url("icons/system/Bluetooth-symbolic.svg");
        }

        #custom-bluetoothicon {
          background-repeat: no-repeat;
          background-size: 18px;
          min-width: 18px;
          min-height: 18px;
          background-position: center;
          border-radius: 0;
          margin-left: 2px;
          margin-right: 2px;
        }

        #custom-networkicon.NetOn {
          background-image: url("icons/system/Wi-FiRouterMinimalistic.svg");
        }

        #custom-networkicon.NetOff {
          background-image: url("icons/system/Netdown.svg");
        }

        #custom-networkicon {
          background-repeat: no-repeat;
          background-size: 22px;
          min-width: 22px;
          min-height: 22px;
          background-position: center;
          border-radius: 0;
          margin-left: 5px;
          margin-right: 5px;
        }

        tooltip {
          border-radius: 8px;
          padding: 10px;
          background-color: @bg;
        }

        tooltip label {
          padding: 5px;
          background-color: @bg;
          color: @accent;
          font-family: SfRegular;
        }

        #custom-config,
        #custom-theme,
        #custom-wallpapers,
        #custom-screenshot,
        #custom-record,
        #custom-picker,
        #custom-clipboard,
        #custom-nerd {
          background-repeat: no-repeat;
          background-size: 20px;
          min-width: 24px;
          min-height: 24px;
          margin-top: 10px;
          padding-left: 4px;
          padding-right: 4px;
        }

        #custom-logo {
          background-repeat: no-repeat;
          background-size: 25px;
          min-width: 24px;
          background-position: center;
          min-height: 24px;
          padding-left: 4px;
          padding-right: 4px;
          margin-left: 15px;
          margin-right: 5px;
        }

        #custom-clipboard {
          margin-left: 10px;
        }

        #custom-power {
          background: linear-gradient(to bottom, @bg, @bg-alt3);
          font-size: 16px;
          margin: 3px;
          color: #665c54;
          padding-left: 0px;
          padding-right: 5px;
          border-radius: 8px;
          font-weight: bold;
          border-bottom: 2px solid @bg-alt;
          border-top: 1px solid @border;
          margin-left: 3px;
          margin-right: 10px;
          text-shadow: -1px -1px 1px rgba(205, 214, 244, 0.1),
            0px 2px 3px rgba(0, 0, 0, 0.3);
        }

        #custom-power:hover {
          color: @red;
        }

        #custom-screenshot,
        #custom-record {
          margin-top: 8px;
          background-size: 24px;
        }

        #custom-clipboard.clipboard {
          background-image: url("icons/Clipboard.svg");
        }

        #custom-nerd.nerd {
          background-image: url("icons/Glasses.svg");
        }

        #custom-logo.logo {
          background-image: url("icons/avatar/nix.svg");
        }

        #custom-config.config {
          background-image: url("icons/Settings-symbolic.svg");
        }

        #custom-theme.theme {
          background-image: url("icons/Palette-symbolic.svg");
        }

        #custom-wallpapers.wallpapers {
          background-image: url("icons/Gallery-symbolic.svg");
        }

        #custom-screenshot.screenshot {
          background-image: url("icons/CameraMinimalistic-symbolic.svg");
        }

        #custom-record.recordoff {
          background-image: url("icons/Videocamera-symbolic.svg");
        }

        #custom-record.recordon {
          background-image: url("cache/recording.svg");
        }

        #custom-picker.picker {
          background-image: url("icons/Pipette-symbolic.svg");
        }

        #custom-weather {
          background-repeat: no-repeat;
          background-size: 20px;
          min-width: 24px;
          min-height: 24px;
          padding: 0 8px;
          margin-top: 7px;
          font-size: large;
          font-family: SfMono;
          font-weight: bold;
          margin-left: 2px;
          color: @text;
        }

        #custom-weather.sunny {
          background-image: url("icons/weather/Sun-symbolic.svg");
        }

        #custom-weather.night {
          background-image: url("icons/weather/Moon-symbolic.svg");
        }

        #custom-weather.cloudy-day {
          background-image: url("icons/weather/CloudSun-symbolic.svg");
        }

        #custom-weather.cloudy-night {
          background-image: url("icons/weather/CloudyMoon-symbolic.svg");
        }

        #custom-weather.clouds {
          background-image: url("icons/weather/Clouds-symbolic.svg");
        }

        #custom-weather.cloudy {
          background-image: url("icons/weather/Cloud-symbolic.svg");
        }

        #custom-weather.fog {
          background-image: url("icons/weather/Fog-symbolic.svg");
        }

        #custom-weather.light-rain,
        #custom-weather.drizzle,
        #custom-weather.rain,
        #custom-weather.heavy-rain {
          background-image: url("icons/weather/CloudRain-symbolic.svg");
        }

        #custom-weather.snow,
        #custom-weather.light-snow,
        #custom-weather.heavy-snow {
          background-image: url("icons/weather/CloudSnowfall-symbolic.svg");
        }

        #custom-weather.sleet {
          background-image: url("icons/weather/CloudWaterdrop-symbolic.svg");
        }

        #custom-weather.thunder {
          background-image: url("icons/weather/CloudBolt-symbolic.svg");
        }

        #custom-weather.storm {
          background-image: url("icons/weather/CloudStorm-symbolic.svg");
        }
      '';
    };

    # Install all packages including scripts
    home.packages = with pkgs;
      [
        # All your scripts
        scripts.scripts.waybarScripts
        scripts.scripts.themeSwitcher
        scripts.scripts.wallpaperSelector
        scripts.scripts.accentPicker
        scripts.scripts.nerdFontSelector
        scripts.scripts.powerMenu

        # Dependencies
        bluez
        iproute2
        upower
        pamixer
        jq
        curl
        imagemagick
        swww
        libnotify
        killall
        procps
        mpc-cli
        alsa-utils
        hyprpicker
        hyprshot
        cliphist
        wl-clipboard
        rofi-wayland
      ]
      ++ lib.optionals waybarConfig.enableRecording [wf-recorder];

    # Config files - copy everything from waybar directory
    xdg.configFile = {
      # Dynamically generated colors
      "waybar/colors.css".text = themes.generateColorsCss waybarConfig.theme currentColors;

      # Rofi theme files - generate shared, copy others
      "waybar/rofi/shared.rasi".text = themes.generateRofiTheme waybarConfig.theme currentColors;

      # Comment these out if files don't exist yet, uncomment when you have them:
      "waybar/rofi/Launcher.rasi".source = ./waybar/rofi/Launcher.rasi;
      "waybar/rofi/ThemeSelect.rasi".source = ./waybar/rofi/ThemeSelect.rasi;
      "waybar/rofi/WallSelect.rasi".source = ./waybar/rofi/WallSelect.rasi;
      "waybar/rofi/clipboard.rasi".source = ./waybar/rofi/clipboard.rasi;
      "waybar/rofi/icons.rasi".source = ./waybar/rofi/icons.rasi;
      "waybar/rofi/powermenu.rasi".source = ./waybar/rofi/powermenu.rasi;

      # Icon directory - uncomment when you have it:
      "waybar/icons".source = ./waybar/icons;

      # Theme accent files
      "waybar/themes/${waybarConfig.theme}/.accent".text = accentColor;
      "waybar/themes/${waybarConfig.theme}/.accent2".text = accent2Color;

      # Cache file - uncomment when you have it:
      "waybar/cache/recording.svg".source = ./waybar/cache/recording.svg;
    };

    # State directories
    home.activation.createWaybarState = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p ${config.xdg.stateHome}/waybar
      $DRY_RUN_CMD mkdir -p ${config.xdg.cacheHome}/waybar/walls-cache
      $DRY_RUN_CMD mkdir -p ${config.xdg.cacheHome}/waybar/theme-cache

      # Initialize theme state
      if [[ ! -f ${config.xdg.stateHome}/waybar/theme ]]; then
        $DRY_RUN_CMD echo "${waybarConfig.theme}" > ${config.xdg.stateHome}/waybar/theme
      fi

      # Initialize recording state
      $DRY_RUN_CMD echo "off" > ${config.xdg.stateHome}/waybar/isrecording
    '';
  }
