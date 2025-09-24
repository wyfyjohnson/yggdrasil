{
  config,
  pkgs,
  lib,
  ...
}: let
  dotsPath = ../dots;
  fileExists = path: builtins.pathExists path;
in {
  programs.bash = {
    enable = true;
    enableCompletion = true;

    bashrcExtra = ''
      if [[ -z "$TMUX" && -n "$PS1" ]]; then
          if tmux list-sessions &>/dev/null; then
            tmux new-session
          else
            tmux new-session -s main
          fi
        fi
            command -v krabby >/dev/null 2>&1 && krabby random
    '';

    shellAliases = {
      ":q" = "exit";
      "ls" = "eza -1 --icons";
      "ll" = "eza -la --icons";
      "lt" = "eza --tree --icons";

      "ff" = "fastfetch --percent-type 10";
      "hf" = "hyfetch";
      "of" = "onefetch -i ~/Pictures/fflogo.png";

      "fenrir" = "ssh wyatt@192.168.69.200";
      "hel" = "ssh wyatt@192.168.69.250";
      "jormungandr" = "ssh wyatt@192.168.69.100";

      "bimp" = "beet import";
      "yt-music" = "yt-dlp -x --audio-format opus --replace-in-metadata uploader ' - Topic' '' --parse-metadata '%(playlist_index)s:%(meta_track)s' --parse-metadata '%(uploader)s:%(meta_album_artist)s' --embed-metadata --format 'bestaudio/best' --audio-quality 0 -o '~/Downloads/Music/%(uploader)s/%(album)s/%(playlist_index)s - %(title)s.%(ext)s' --print '%(uploader)s - %(album)s - %(playlist_index)s %(title)s' --no-simulate";

      "jctl" = "journalctl -p 3 -xb";
      "sysfetch" = ".config/sysfetch/sysfetch";
      "gp" = "git push && git push github main ";
    };
  };

  programs.starship = lib.mkMerge [
    {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    }
    # Fallback config if no dotfiles starship.toml exists
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

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = config.programs.bash.shellAliases;

    initContent = ''
      if [[ -z "$TMUX" && -n "$PS1" ]]; then
        if tmux list-sessions &>/dev/null; then
          tmux new-session
        else
          tmux new-session -s main
        fi
      fi

      command -v krabby >/dev/null 2>&1 && krabby random
    '';
  };
}
