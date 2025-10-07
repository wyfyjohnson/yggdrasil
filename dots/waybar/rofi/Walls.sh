#!/usr/bin/env bash

# =============================================================
# Dependencies:
# → Wayland: swww, rofi (wayland), xxhsum, imagemagick
# → X11: feh, rofi, xxhsum, imagemagick
# → GNU: findutils, coreutils
# =============================================================

# Use XDG directories - writable locations
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Theme tracking in writable state directory
THEME_FILE="$XDG_STATE_HOME/waybar/theme"
[ -d "$(dirname "$THEME_FILE")" ] || mkdir -p "$(dirname "$THEME_FILE")"

# Read current theme (default to first available if not set)
if [ -f "$THEME_FILE" ]; then
    THEME=$(cat "$THEME_FILE")
else
    THEME=$(basename "$(find "$XDG_CONFIG_HOME/waybar/themes" -maxdepth 1 -type d ! -name themes | head -n1)")
    echo "$THEME" > "$THEME_FILE"
fi

wall_dir="$XDG_CONFIG_HOME/waybar/themes/$THEME/walls"
cacheDir="$XDG_CACHE_HOME/waybar/walls-cache/$THEME"

# Validate wallpaper directory
if [ ! -d "$wall_dir" ]; then
    echo "Error: Directory '$wall_dir' does not exist"
    exit 1
fi

# Create cache dir if not exists
[ -d "$cacheDir" ] || mkdir -p "$cacheDir"

# Detect session type and set appropriate commands
detect_session() {
    if [ -n "$WAYLAND_DISPLAY" ]; then
        echo "wayland"
    elif [ -n "$DISPLAY" ]; then
        echo "x11"
    else
        # Fallback detection
        if pgrep -x "sway\|Hyprland\|river\|wayfire" >/dev/null 2>&1; then
            echo "wayland"
        elif pgrep -x "Xorg\|X" >/dev/null 2>&1; then
            echo "x11"
        else
            echo "unknown"
            return 1
        fi
    fi
}

SESSION_TYPE=$(detect_session)

# Generate cache for wallpapers if needed
for img in "$wall_dir"/*.{jpg,jpeg,png,webp}; do
    [ -f "$img" ] || continue
    
    wallpaper_name=$(basename "$img")
    cache_file="$cacheDir/$wallpaper_name"
    
    # Generate thumbnail if not exists
    if [ ! -f "$cache_file" ]; then
        magick "$img" -resize 500x500^ -gravity center -extent 500x500 "$cache_file" 2>/dev/null
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
selected=$(echo -en "$rofi_list" | rofi -dmenu -theme "$XDG_CONFIG_HOME/waybar/rofi/WallSelect.rasi" -p "Select Wallpaper")

if [ -n "$selected" ]; then
    wallpaper_path="$wall_dir/$selected"
    
    # Set wallpaper based on session type
    if [ "$SESSION_TYPE" = "wayland" ]; then
        swww img "$wallpaper_path" --transition-type fade --transition-fps 60
    elif [ "$SESSION_TYPE" = "x11" ]; then
        feh --bg-scale "$wallpaper_path"
    fi
    
    # Save selection to writable location
    echo "$wallpaper_path" > "$XDG_STATE_HOME/waybar/wallpaper"
fi
