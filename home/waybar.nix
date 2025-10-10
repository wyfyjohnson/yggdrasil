# waybar.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.waybar;

  # Theme configuration
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

  # Generate colors.css from theme
  generateColorsCss = theme: let
    colors = themeConfig.${theme}.colors;
  in ''
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

  # Generate rofi shared.rasi from theme
  generateRofiTheme = theme: let
    colors = themeConfig.${theme}.colors;
  in ''
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

  # Scripts
  waybarScripts = pkgs.writeScriptBin "waybar-scripts" ''
    #!${pkgs.bash}/bin/bash

    # Quick actions script
    quickactions() {
      case "$1" in
        --bluetooth)
          state=$(${pkgs.bluez}/bin/bluetoothctl show | grep "Powered:" | awk '{print $2}')
          if [[ "$state" == "yes" ]]; then
            state="On"
            class="BTOn"
          else
            state="Off"
            class="BTOff"
          fi
          echo "{\"text\": \" \", \"class\": \"$class\", \"tooltip\": \"Bluetooth  $state\"}"
          ;;
        --network)
          if ${pkgs.iproute2}/bin/ip link show up | grep -q "state UP"; then
            state="On"
            class="NetOn"
          else
            state="Off"
            class="NetOff"
          fi
          echo "{\"text\": \" \", \"class\": \"$class\", \"tooltip\": \"Network  $state\"}"
          ;;
        --battery)
          battery=$(${pkgs.upower}/bin/upower -e | grep battery | head -n1)
          battery_info=$(${pkgs.upower}/bin/upower -i "$battery")
          percent=$(echo "$battery_info" | grep -E "percentage" | awk '{print $2}' | tr -d '%' | cut -d'.' -f1)
          state=$(echo "$battery_info" | grep -E "state" | awk '{print $2}')

          if [[ "$state" == "charging" ]]; then
            class="charging"
          elif (( percent < 33 )); then
            class="Low"
          elif (( percent < 66 )); then
            class="Med"
          else
            class="Full"
          fi

          echo "{\"text\": \" \", \"class\": \"$class\", \"tooltip\": \"Battery | ''${percent}%  $state\"}"
          ;;
        --volume)
          volume_info=$(${pkgs.pamixer}/bin/pamixer --get-volume)
          mute_status=$(${pkgs.pamixer}/bin/pamixer --get-mute)

          if [[ "$mute_status" == "true" ]]; then
            class="volmute"
          elif (( volume_info < 33 )); then
            class="volow"
          elif (( volume_info < 66 )); then
            class="volmed"
          else
            class="volfull"
          fi

          echo "{\"text\": \" \", \"class\": \"$class\", \"tooltip\": \"Volume  ''${volume_info}%\"}"
          ;;
        --nerd)
          echo "{\"text\": \" \", \"class\": \"nerd\", \"tooltip\": \"    Nerd Icons\"}"
          ;;
        --clipboard)
          echo "{\"text\": \" \", \"class\": \"clipboard\", \"tooltip\": \"   Clipboard\"}"
          ;;
        --power)
          echo "{\"text\": \" \", \"class\": \"power\", \"tooltip\": \"Power Menu\"}"
          ;;
        --logo)
          echo "{\"text\": \" \", \"class\": \"logo\", \"tooltip\": \"Apps Launcher\"}"
          ;;
        --config)
          echo "{\"text\": \" \", \"class\": \"config\", \"tooltip\": \"   Configs\"}"
          ;;
        --theme)
          echo "{\"text\": \" \", \"class\": \"theme\", \"tooltip\": \"󱥚   Themes\"}"
          ;;
        --wallpapers)
          echo "{\"text\": \" \", \"class\": \"wallpapers\", \"tooltip\": \"  Wallpapers\"}"
          ;;
        --screenshot)
          echo "{\"text\": \" \", \"class\": \"screenshot\", \"tooltip\": \"  Screenshots | Click Select  Right Click Output\"}"
          ;;
        --record)
          statusrecord=$(cat ''${XDG_STATE_HOME:-$HOME/.local/state}/waybar/isrecording 2>/dev/null | tr -d '[:space:]')
          if [ "$statusrecord" = "on" ]; then
            echo "{\"text\": \" \", \"class\": \"recordon\", \"tooltip\": \"   Recording  Right Click to stop\"}"
          else
            echo "{\"text\": \" \", \"class\": \"recordoff\", \"tooltip\": \"   Record\"}"
          fi
          ;;
        --picker)
          echo "{\"text\": \" \", \"class\": \"picker\", \"tooltip\": \"   Click Change Accent  Right Click Change Accent2\"}"
          ;;
        *)
          echo "{\"text\": \" \", \"class\": \"config\", \"tooltip\": \"Quick Actions  CONFIG\"}"
          ;;
      esac
    }

    # Weather script
    weather() {
      CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
      CACHE_FILE="$CACHE_DIR/weather-data.json"

      mkdir -p "$CACHE_DIR"

      get_city() {
        ${pkgs.curl}/bin/curl -s "https://ipapi.co/city/" 2>/dev/null || echo "Carlsbad,CA"
      }

      fetch_weather() {
        local city=$(get_city)
        local url="https://v2.wttr.in/''${city}?format=j1"

        local weather_data=$(${pkgs.curl}/bin/curl -s "$url" --connect-timeout 10 2>/dev/null)

        if [[ $? -eq 0 && -n "$weather_data" ]]; then
          echo "{\"timestamp\": $(date +%s), \"data\": $weather_data}" > "$CACHE_FILE"
          echo "$weather_data"
        else
          if [[ -f "$CACHE_FILE" ]]; then
            ${pkgs.jq}/bin/jq -r '.data' "$CACHE_FILE" 2>/dev/null
          fi
        fi
      }

      case "''${1:-show}" in
        "fetch")
          fetch_weather >/dev/null
          ;;
        "show"|*)
          local weather_data

          if [[ -f "$CACHE_FILE" ]]; then
            local cache_time=$(${pkgs.jq}/bin/jq -r '.timestamp' "$CACHE_FILE" 2>/dev/null)
            local current_time=$(date +%s)
            local age=$((current_time - cache_time))

            if [[ $age -gt 900 ]]; then
              weather_data=$(fetch_weather)
            else
              weather_data=$(${pkgs.jq}/bin/jq -r '.data' "$CACHE_FILE" 2>/dev/null)
            fi
          else
            weather_data=$(fetch_weather)
          fi

          if [[ -n "$weather_data" ]]; then
            local temp=$(echo "$weather_data" | ${pkgs.jq}/bin/jq -r '.current_condition[0].temp_C' 2>/dev/null)
            local weather_code=$(echo "$weather_data" | ${pkgs.jq}/bin/jq -r '.current_condition[0].weatherCode' 2>/dev/null)
            local condition=$(echo "$weather_data" | ${pkgs.jq}/bin/jq -r '.current_condition[0].weatherDesc[0].value' 2>/dev/null)

            if [[ "$temp" != "null" && "$weather_code" != "null" ]]; then
              local hour=$(date +%H)
              local is_night=$([[ $hour -lt 6 || $hour -gt 20 ]] && echo true || echo false)

              local weather_class
              case "$weather_code" in
                "113") weather_class=$($is_night && echo "night" || echo "sunny") ;;
                "116") weather_class=$($is_night && echo "cloudy-night" || echo "cloudy-day") ;;
                "119") weather_class="clouds" ;;
                "122") weather_class="cloudy" ;;
                "143"|"248"|"260") weather_class="fog" ;;
                *) weather_class="cloudy" ;;
              esac

              echo "{\"text\": \" ''${temp}°\", \"class\": \"$weather_class\", \"tooltip\": \"Weather | ''${condition}  ''${temp}°C\"}"
            else
              echo "{\"text\": \"--°\", \"class\": \"weather\", \"tooltip\": \"Weather | No data\"}"
            fi
          else
            echo "{\"text\": \"--°\", \"class\": \"cloudy\", \"tooltip\": \"Weather | Error loading data\"}"
          fi
          ;;
      esac
    }

    # Recording script
    record() {
      ISRECORD="''${XDG_STATE_HOME:-$HOME/.local/state}/waybar/isrecording"
      VIDEO_DIR="''${XDG_VIDEOS_DIR:-$HOME/Videos}"

      mkdir -p "$(dirname "$ISRECORD")" "$VIDEO_DIR"

      monitor=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused==true).name')
      archivo="$VIDEO_DIR/$(date '+%Y-%m-%d_%H-%M-%S').mp4"

      case "$1" in
        --stop)
          echo "off" > "$ISRECORD"
          ${pkgs.killall}/bin/killall wf-recorder 2>/dev/null
          ;;
        *)
          echo "on" > "$ISRECORD"
          ${pkgs.wf-recorder}/bin/wf-recorder -o "$monitor" -f "$archivo" -r 30 --audio="$(${pkgs.pulseaudio}/bin/pactl get-default-sink).monitor" &
          ;;
      esac
    }

    # Main router
    case "$1" in
      quickactions)
        shift
        quickactions "$@"
        ;;
      weather)
        shift
        weather "$@"
        ;;
      record)
        shift
        record "$@"
        ;;
      *)
        echo "Usage: waybar-scripts {quickactions|weather|record} [args...]"
        exit 1
        ;;
    esac
  '';

  # Theme switcher script
  themeSwitcher = pkgs.writeScriptBin "waybar-theme-switcher" ''
    #!${pkgs.bash}/bin/bash

    XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}"

    THEME_FILE="$XDG_STATE_HOME/waybar/theme"
    mkdir -p "$(dirname "$THEME_FILE")"

    # Available themes
    themes=(
      "Tokyo"
      "Catppuccin"
      "Gruvbox"
      "Nord"
      "Dracula"
      "Everforest"
      "Rosepine"
      "Onedark"
      "Oxocarbon"
      "Kanagawa"
    )

    # Build rofi list
    rofi_list=""
    for theme in "''${themes[@]}"; do
      rofi_list+="$theme\n"
    done

    # Show rofi selector
    selected=$(echo -en "$rofi_list" | ${pkgs.rofi-wayland}/bin/rofi -dmenu -theme "$XDG_CONFIG_HOME/waybar/rofi/ThemeSelect.rasi" -p "Select Theme")

    if [ -n "$selected" ]; then
      echo "$selected" > "$THEME_FILE"

      # Trigger theme application through home-manager
      # This would need to be integrated with your home-manager config
      ${pkgs.systemd}/bin/systemctl --user restart waybar.service
    fi
  '';
in {
  options.programs.waybar = {
    enable = mkEnableOption "Waybar status bar";

    theme = mkOption {
      type = types.enum [
        "Tokyo"
        "Catppuccin"
        "Gruvbox"
        "Nord"
        "Dracula"
        "Everforest"
        "Rosepine"
        "Onedark"
        "Oxocarbon"
        "Kanagawa"
      ];
      default = "Tokyo";
      description = "Theme to use for Waybar";
    };

    customAccent = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Custom accent color (hex format)";
    };

    customAccent2 = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Custom secondary accent color (hex format)";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      waybarScripts
      themeSwitcher
      # Dependencies
      bluez
      iproute2
      upower
      pamixer
      jq
      curl
      wf-recorder
      hyprpicker
      hyprshot
      cliphist
      imagemagick
      swww
    ];

    programs.waybar = {
      enable = true;

      settings = [
        {
          layer = "top";
          position = "top";
          spacing = 0;
          height = 20;

          modules-left = [
            "custom/logo"
            "clock"
            "custom/divisor"
            "custom/weather"
          ];

          modules-center = [
            "disk"
            "cpu"
            "memory"
            "hyprland/workspaces"
            "custom/clipboard"
            "custom/nerd"
            "custom/theme"
            "custom/wallpapers"
            "custom/screenshot"
            "custom/record"
            "custom/picker"
          ];

          modules-right =
            [
              "tray"
              "custom/divisor"
              "custom/networkicon"
              "custom/bluetoothicon"
              "custom/volumeicon"
              "custom/batteryicon"
              "custom/divisor"
              "custom/power"
            ]
            ++ optional cfg.enableRecording "custom/recorder";

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
              urgent = "󰳤";
            };
            persistent-workspaces = {
              "1" = [];
              "2" = [];
              "3" = [];
              "4" = [];
              "5" = [];
            };
          };

          "custom/weather" = {
            exec = "${waybarScripts}/bin/waybar-scripts weather show";
            format = "{}";
            tooltip = true;
            interval = 900;
            return-type = "json";
            on-click = "${waybarScripts}/bin/waybar-scripts weather fetch";
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
                months = "<span color='${themeConfig.${cfg.theme}.colors.accent}'><b>{}</b></span>";
                days = "<span color='${themeConfig.${cfg.theme}.colors.text}'><b>{}</b></span>";
                weeks = "<span color='${themeConfig.${cfg.theme}.colors.accent2}'><b>W{}</b></span>";
                weekdays = "<span color='${themeConfig.${cfg.theme}.colors.accent}'><b>{}</b></span>";
                today = "<span color='${themeConfig.${cfg.theme}.colors.red}'><b><u>{}</u></b></span>";
              };
            };
          };

          "custom/divisor" = {
            format = "  ";
            tooltip = false;
          };

          "custom/logo" = {
            exec = "${waybarScripts}/bin/waybar-scripts quickactions --logo";
            format = "{}";
            tooltip = true;
            interval = 86400;
            return-type = "json";
            on-click = "${pkgs.rofi-wayland}/bin/rofi -show drun -theme ~/.config/waybar/rofi/Launcher.rasi";
          };

          "custom/theme" = {
            exec = "${waybarScripts}/bin/waybar-scripts quickactions --theme";
            format = "{}";
            tooltip = true;
            interval = 86400;
            return-type = "json";
            on-click = "${themeSwitcher}/bin/waybar-theme-switcher";
          };

          "custom/wallpapers" = {
            exec = "${waybarScripts}/bin/waybar-scripts quickactions --wallpapers";
            format = "{}";
            tooltip = true;
            interval = 86400;
            return-type = "json";
            on-click = "~/.config/waybar/rofi/Walls.sh";
          };

          "custom/screenshot" = {
            exec = "${waybarScripts}/bin/waybar-scripts quickactions --screenshot";
            format = "{}";
            tooltip = true;
            interval = 86400;
            return-type = "json";
            on-click = "${pkgs.hyprshot}/bin/hyprshot -m region";
            on-click-right = "${pkgs.hyprshot}/bin/hyprshot -m output";
          };

          "custom/record" = {
            exec = "${waybarScripts}/bin/waybar-scripts quickactions --record";
            format = "{}";
            tooltip = true;
            interval = 1;
            return-type = "json";
            on-click = "${waybarScripts}/bin/waybar-scripts record";
            on-click-right = "${waybarScripts}/bin/waybar-scripts record --stop";
          };

          "custom/clipboard" = {
            exec = "${waybarScripts}/bin/waybar-scripts quickactions --clipboard";
            format = "{}";
            tooltip = true;
            interval = 86400;
            return-type = "json";
            on-click = "${pkgs.cliphist}/bin/cliphist list | ${pkgs.rofi-wayland}/bin/rofi -dmenu -theme ~/.config/waybar/rofi/clipboard.rasi | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy";
          };

          "custom/nerd" = {
            exec = "${waybarScripts}/bin/waybar-scripts quickactions --nerd";
            format = "{}";
            tooltip = true;
            interval = 86400;
            return-type = "json";
            on-click = "~/.config/waybar/rofi/nficons.sh";
          };

          "custom/picker" = {
            exec = "${waybarScripts}/bin/waybar-scripts quickactions --picker";
            format = "{}";
            tooltip = true;
            interval = 86400;
            return-type = "json";
            on-click = "~/.config/waybar/scripts/accentpicker.sh --accent";
            on-click-right = "~/.config/waybar/scripts/accentpicker.sh --accent2";
          };

          "custom/power" = {
            format = " ⏼ ";
            on-click = "~/.config/waybar/rofi/power.sh";
            tooltip = false;
          };

          "custom/networkicon" = {
            exec = "${waybarScripts}/bin/waybar-scripts quickactions --network";
            interval = 1;
            return-type = "json";
            format = "{}";
            tooltip = true;
          };

          "custom/bluetoothicon" = {
            exec = "${waybarScripts}/bin/waybar-scripts quickactions --bluetooth";
            interval = 1;
            return-type = "json";
            format = "{}";
            tooltip = true;
          };

          "custom/batteryicon" = {
            exec = "${waybarScripts}/bin/waybar-scripts quickactions --battery";
            interval = 1;
            return-type = "json";
            format = "{}";
            tooltip = true;
          };

          "custom/volumeicon" = {
            exec = "${waybarScripts}/bin/waybar-scripts quickactions --volume";
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

      style = ''
        @import "colors.css";


        /* ==================== */
        /* 🎛️ Estilos generales */
        /* ==================== */
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


        /* ==================== */
        /* 🔲 Workspaces */
        /* ==================== */

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



        /* ==================== */
        /* 📊 Módulos del sistema */
        /* ==================== */
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

        #battery {
          background-color: @bg;
        }

        #battery.warning,
        #battery.critical,
        #battery.urgent {
          background-color: @bg;
        }

        #battery.charging {
          background-color: @bg;
          color: @text-dark;
        }

        #backlight {
          background-color: @bg;
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


        /* ==================== */
        /* 🌐 Red, Audio, Batería */
        /* ==================== */
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

        #network {
          border-top-left-radius: 6px;
          border-bottom-left-radius: 6px;
          margin-right: 0;
          border-top-right-radius: 0px;
          border-bottom-right-radius: 0px;
        }

        #wireplumber {
          margin-top: 2px;
          border-radius: 0;
          margin-left: -2px;
          margin-right: -2px;
        }

        #battery {
          border-top-left-radius: 0px;
          border-top-right-radius: 6px;
          border-bottom-right-radius: 6px;
          margin-left: 0;
          margin-right: 5px;
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

        /* ==================== */
        /* 📝 Tooltips */
        /* ==================== */
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


        /* ==================== */
        /* 🔧 Quick Actions */
        /* ==================== */
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


        /* ==================== */
        /* 🌤️ Clima */
        /* ==================== */
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

        /* Sol y Luna */
        #custom-weather.sunny {
          background-image: url("icons/weather/Sun-symbolic.svg");
        }

        #custom-weather.night {
          background-image: url("icons/weather/Moon-symbolic.svg");
        }

        /* Nubes */
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

        /* Niebla */
        #custom-weather.fog {
          background-image: url("icons/weather/Fog-symbolic.svg");
        }

        /* Lluvia */
        #custom-weather.light-rain,
        #custom-weather.drizzle,
        #custom-weather.rain,
        #custom-weather.heavy-rain {
          background-image: url("icons/weather/CloudRain-symbolic.svg");
        }

        /* Nieve */
        #custom-weather.light-snow,
        #custom-weather.snow,
        #custom-weather.heavy-snow {
          background-image: url("icons/weather/CloudSnowfall-symbolic.svg");
        }

        #custom-weather.blizzard {
          background-image: url("icons/weather/Snowflake-symbolic.svg");
        }

        #custom-weather.light-snow-minimal {
          background-image: url("icons/weather/CloudSnowfallMinimalistic-symbolic.svg");
        }

        /* Aguanieve y hielo */
        #custom-weather.sleet,
        #custom-weather.freezing-drizzle,
        #custom-weather.freezing-rain,
        #custom-weather.hail {
          background-image: url("icons/weather/CloudWaterdrop-symbolic.svg");
        }

        /* Tormentas */
        #custom-weather.thunder {
          background-image: url("icons/weather/CloudBolt-symbolic.svg");
        }

        #custom-weather.thunder-minimal {
          background-image: url("icons/weather/CloudBoltMinimalistic-symbolic.svg");
        }

        #custom-weather.storm {
          background-image: url("icons/weather/CloudStorm-symbolic.svg");
        }
      '';
    };

    # Create config directory structure
    xdg.configFile = {
      "waybar/colors.css".text = generateColorsCss cfg.theme;

      "waybar/rofi/shared.rasi".text = generateRofiTheme cfg.theme;

      # Copy all rofi themes
      "waybar/rofi/Launcher.rasi".source = ./rofi/Launcher.rasi;
      "waybar/rofi/ThemeSelect.rasi".source = ./rofi/ThemeSelect.rasi;
      "waybar/rofi/WallSelect.rasi".source = ./rofi/WallSelect.rasi;
      "waybar/rofi/clipboard.rasi".source = ./rofi/clipboard.rasi;
      "waybar/rofi/icons.rasi".source = ./rofi/icons.rasi;
      "waybar/rofi/powermenu.rasi".source = ./rofi/powermenu.rasi;

      # Copy icon files
      "waybar/icons".source = ./icons;
    };

    # Create state directory on activation
    home.activation.createWaybarState = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ${config.xdg.stateHome}/waybar
      echo "${cfg.theme}" > ${config.xdg.stateHome}/waybar/theme
      echo "off" > ${config.xdg.stateHome}/waybar/isrecording
    '';
  };
}
