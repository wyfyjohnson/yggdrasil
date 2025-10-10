# waybar/scripts.nix
{
  pkgs,
  config,
  ...
}: let
  # All waybar scripts bundled together
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
                "176"|"263"|"266"|"293"|"296"|"299"|"302"|"305"|"353"|"356"|"359") weather_class="light-rain" ;;
                "179"|"227"|"230"|"320"|"323"|"326"|"329"|"332"|"338"|"368"|"371"|"395") weather_class="snow" ;;
                "182"|"185"|"281"|"284"|"311"|"314"|"317"|"350"|"362"|"365"|"374"|"377") weather_class="sleet" ;;
                "200"|"389"|"392") weather_class="thunder" ;;
                "308") weather_class="storm" ;;
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
    XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"

    THEME_FILE="$XDG_STATE_HOME/waybar/theme"
    THEMES_DIR="$XDG_CONFIG_HOME/waybar/themes"
    CACHE_DIR="$XDG_CACHE_HOME/waybar/theme-cache"

    mkdir -p "$(dirname "$THEME_FILE")" "$CACHE_DIR"

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

    # Build rofi list with preview icons if available
    rofi_list=""
    for theme in "''${themes[@]}"; do
      preview_file="$CACHE_DIR/$theme-preview.png"

      # Generate preview if needed (simple colored rectangle)
      if [ ! -f "$preview_file" ]; then
        # This would ideally show a preview of the theme
        # For now, just add the theme name
        :
      fi

      rofi_list+="$theme\n"
    done

    # Show rofi selector
    selected=$(echo -en "$rofi_list" | ${pkgs.rofi-wayland}/bin/rofi -dmenu -theme "$XDG_CONFIG_HOME/waybar/rofi/ThemeSelect.rasi" -p "Select Theme")

    if [ -n "$selected" ]; then
      echo "$selected" > "$THEME_FILE"

      # Apply theme by rebuilding home-manager config or restarting waybar
      # For now, just restart waybar to pick up the new theme file
      ${pkgs.systemd}/bin/systemctl --user restart waybar.service

      # Optionally notify user
      ${pkgs.libnotify}/bin/notify-send "Waybar Theme" "Switched to $selected theme" -t 3000
    fi
  '';

  # Wallpaper selector script
  wallpaperSelector = pkgs.writeScriptBin "waybar-wallpaper-selector" ''
    #!${pkgs.bash}/bin/bash

    XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
    XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}"

    # Read current theme
    THEME_FILE="$XDG_STATE_HOME/waybar/theme"
    if [ -f "$THEME_FILE" ]; then
      THEME=$(cat "$THEME_FILE")
    else
      THEME="Tokyo"
    fi

    wall_dir="$XDG_CONFIG_HOME/waybar/themes/$THEME/walls"
    cacheDir="$XDG_CACHE_HOME/waybar/walls-cache/$THEME"

    # Validate wallpaper directory
    if [ ! -d "$wall_dir" ]; then
      ${pkgs.libnotify}/bin/notify-send "Wallpaper Selector" "No wallpapers found for $THEME theme" -u critical
      exit 1
    fi

    # Create cache dir if not exists
    mkdir -p "$cacheDir"

    # Generate cache for wallpapers if needed
    for img in "$wall_dir"/*.{jpg,jpeg,png,webp}; do
      [ -f "$img" ] || continue

      wallpaper_name=$(basename "$img")
      cache_file="$cacheDir/$wallpaper_name"

      # Generate thumbnail if not exists
      if [ ! -f "$cache_file" ]; then
        ${pkgs.imagemagick}/bin/magick "$img" -resize 500x500^ -gravity center -extent 500x500 "$cache_file" 2>/dev/null
      fi
    done

    # Build rofi list with icon previews
    rofi_list=""
    for img in "$wall_dir"/*.{jpg,jpeg,png,webp}; do
      [ -f "$img" ] || continue

      wallpaper_name=$(basename "$img")
      cache_file="$cacheDir/$wallpaper_name"

      if [ -f "$cache_file" ]; then
        rofi_list+="$wallpaper_name\0icon\x1f$cache_file\n"
      fi
    done

    # Show rofi selector
    selected=$(echo -en "$rofi_list" | ${pkgs.rofi-wayland}/bin/rofi -dmenu -theme "$XDG_CONFIG_HOME/waybar/rofi/WallSelect.rasi" -p "Select Wallpaper")

    if [ -n "$selected" ]; then
      wallpaper_path="$wall_dir/$selected"

      # Set wallpaper
      ${pkgs.swww}/bin/swww img "$wallpaper_path" --transition-type fade --transition-fps 60

      # Save selection
      echo "$wallpaper_path" > "$XDG_STATE_HOME/waybar/wallpaper"
      echo "$wallpaper_path" > "$XDG_CONFIG_HOME/waybar/themes/$THEME/walls/.wallpaper"
    fi
  '';

  # Accent color picker script
  accentPicker = pkgs.writeScriptBin "waybar-accent-picker" ''
    #!${pkgs.bash}/bin/bash

    XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}"

    # Verify flag
    case "$1" in
      --accent)
        ACCENT_FILE=".accent"
        ;;
      --accent2)
        ACCENT_FILE=".accent2"
        ;;
      *)
        echo "Usage: $0 [--accent|--accent2]"
        exit 1
        ;;
    esac

    # Read current theme
    THEME=$(cat "$XDG_STATE_HOME/waybar/theme" 2>/dev/null || echo "Tokyo")

    # Loop to ensure colors with hyprpicker
    while true; do
      echo "Selecting color with hyprpicker..."
      COLOR=$(${pkgs.hyprpicker}/bin/hyprpicker 2>/dev/null | grep '^#' | head -n1)

      if [ -n "$COLOR" ] && [[ "$COLOR" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
        echo "Selected color: $COLOR"
        break
      else
        echo "Error getting color, trying again..."
        sleep 1
      fi
    done

    # Save the color
    echo "$COLOR" > "$XDG_CONFIG_HOME/waybar/themes/$THEME/$ACCENT_FILE"

    # Notify user to rebuild or restart
    ${pkgs.libnotify}/bin/notify-send "Accent Color" "Color $COLOR saved. Rebuild home-manager to apply." -t 3000

    # Optionally trigger a rebuild or restart
    # home-manager switch &
  '';

  # Nerd font icon selector
  nerdFontSelector = pkgs.writeScriptBin "waybar-nerd-font-selector" ''
    #!${pkgs.bash}/bin/bash

    XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"

    SYMBOLS_FILE="$XDG_CONFIG_HOME/waybar/rofi/nerdfont-icons-fixed.txt"

    if [ ! -f "$SYMBOLS_FILE" ]; then
      ${pkgs.libnotify}/bin/notify-send "Nerd Font Selector" "Icons file not found" -u critical
      exit 1
    fi

    SELECTED=$(cat "$SYMBOLS_FILE" | ${pkgs.rofi-wayland}/bin/rofi -dmenu -i -theme "$XDG_CONFIG_HOME/waybar/rofi/icons.rasi")

    CHAR=$(echo "$SELECTED" | awk '{print $1}')

    if [ -n "$CHAR" ]; then
      echo -n "$CHAR" | ${pkgs.wl-clipboard}/bin/wl-copy
      ${pkgs.libnotify}/bin/notify-send "Nerd Font Icon" "Copied $CHAR to clipboard" -t 2000
    fi
  '';

  # Power menu script
  powerMenu = pkgs.writeScriptBin "waybar-power-menu" ''
    #!${pkgs.bash}/bin/bash

    XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"

    # Current Theme
    theme='powermenu'

    # CMDs
    uptime="$(${pkgs.procps}/bin/uptime -p | sed -e 's/up //g')"

    # Options
    shutdown='󰐦'
    reboot='󰑓'
    lock='󰍁'
    suspend='󰤄'
    logout='󰍃'

    # Rofi CMD
    rofi_cmd() {
      ${pkgs.rofi-wayland}/bin/rofi -dmenu \
        -p "Goodbye ''${USER}" \
        -mesg "Uptime: $uptime" \
        -theme "''${XDG_CONFIG_HOME}/waybar/rofi/''${theme}.rasi"
    }

    # Pass variables to rofi dmenu
    run_rofi() {
      echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
    }

    # Execute Command
    run_cmd() {
      case "$1" in
        --shutdown) ${pkgs.systemd}/bin/systemctl poweroff ;;
        --reboot)   ${pkgs.systemd}/bin/systemctl reboot ;;
        --suspend)
          ${pkgs.mpc-cli}/bin/mpc -q pause 2>/dev/null
          ${pkgs.alsa-utils}/bin/amixer set Master mute
          ${pkgs.systemd}/bin/systemctl suspend
          ;;
        --lock) ${pkgs.hyprlock}/bin/hyprlock & ;;
        --logout) ${pkgs.hyprland}/bin/hyprctl dispatch exit ;;
      esac
    }

    # Actions
    chosen="$(run_rofi)"
    case ''${chosen} in
      $shutdown) run_cmd --shutdown ;;
      $reboot)   run_cmd --reboot ;;
      $lock)     run_cmd --lock ;;
      $suspend)  run_cmd --suspend ;;
      $logout)   run_cmd --logout ;;
    esac
  '';
in {
  scripts = {
    inherit waybarScripts;
    inherit themeSwitcher;
    inherit wallpaperSelector;
    inherit accentPicker;
    inherit nerdFontSelector;
    inherit powerMenu;
  };
}
