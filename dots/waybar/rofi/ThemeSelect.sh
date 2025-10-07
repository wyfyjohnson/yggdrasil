#!/usr/bin/env bash

# Use XDG directories
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

themes_dir="$XDG_CONFIG_HOME/waybar/themes"
cache_dir="$XDG_CACHE_HOME/waybar/walls-cache"
state_dir="$XDG_STATE_HOME/waybar"

# Create writable directories
mkdir -p "$cache_dir" "$state_dir"

rofi_command="rofi -dmenu -theme $XDG_CONFIG_HOME/waybar/rofi/ThemeSelect.rasi"

# Validate themes directory exists
if [ ! -d "$themes_dir" ]; then
    echo "Error: Directory '$themes_dir' does not exist"
    exit 1
fi

echo "Scanning themes and wallpapers..."

# Build rofi list
temp_list=""

# Scan each theme folder
for theme_dir in "$themes_dir"/*; do
    [ -d "$theme_dir" ] || continue
    
    theme_name=$(basename "$theme_dir")
    
    # Look for any wallpaper in the theme
    wallpaper=$(find "$theme_dir/walls" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) 2>/dev/null | head -n1)
    
    if [ -n "$wallpaper" ]; then
        wallpaper_filename=$(basename "$wallpaper")
        cache_file="$cache_dir/$theme_name/$wallpaper_filename"
        
        # Generate cache if needed
        if [ ! -f "$cache_file" ]; then
            mkdir -p "$cache_dir/$theme_name"
            magick "$wallpaper" -resize 500x500^ -gravity center -extent 500x500 "$cache_file" 2>/dev/null
        fi
        
        # Add to rofi list with icon
        if [ -f "$cache_file" ]; then
            temp_list+="$theme_name\0icon\x1f$cache_file\n"
        else
            temp_list+="$theme_name\n"
        fi
    else
        # Show theme even without wallpaper
        temp_list+="$theme_name\n"
    fi
done

# Show rofi selector
selected=$(echo -en "$temp_list" | $rofi_command -p "Select Theme")

if [ -n "$selected" ]; then
    # Save selected theme to writable state directory
    echo "$selected" > "$state_dir/theme"
    
    # Reload waybar to apply new theme
    pkill -SIGUSR2 waybar
fi
