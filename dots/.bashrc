# Ghostty shell integration for Bash. This should be at the top of your bashrc!
if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
    builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
fi

export HELIX_RUNTIME=~/stuffundthings/helix/runtime

#export HISTSIZE=20000
#export HISTFILE="$HOME/.local/share/zsh/history"
#export SAVEHIST=$HISTSIZE  

### Path ###
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

### Prompt ###
eval "$(starship init bash)"

### Fun stuff
# fastfetch
krabby random

### Aliases ###
alias ls='eza --icons -T --level 1'
alias doas="sudo"
alias vdl='yt-dlp -S "+codec:h264"'
#alias pretend="doas emerge -p"
alias enstall="sudo nala install"
alias off="sudo poweroff"
alias sink="sudo nala update"
alias :q="exit"
alias yt-audio="yt-dlp -x --audio-format opus --format 'bestaudio/best' --audio-quality 0"
alias yt-music="yt-dlp -x --audio-format opus --replace-in-metadata uploader ' - Topic' '' --parse-metadata '%(playlist_index)s:%(meta_track)s' --parse-metadata '%(uploader)s:%(meta_album_artist)s' --embed-metadata  --format 'bestaudio/best' --audio-quality 0 -o '~/Downloads/Music/%(uploader)s/%(album)s/%(playlist_index)s - %(title)s.%(ext)s' --print '%(uploader)s - %(album)s - %(playlist_index)s %(title)s' --no-simulate"
alias bigupgrade="sudo nala upgrade"
alias shieldsup="sudo systemctl start openvpn-server@mullvad_us_lax"
alias gametime="sudo systemctl stop openvpn-server@mullvad_us_lax"
alias ff="fastfetch --percent-type 10"

### Ghostty/Term/User Shell ###
#${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration


### Helix/Editor Stuff ###
#export HELIX_RUNTIME=~/src/helix/runtime
export SUDO_EDITOR=$(which hx)

### Hyprshot ###
# HYPRSHOT_DIR= ~/Pictures/Screenshots
