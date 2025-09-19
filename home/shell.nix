{
  config,
  pkgs,
  lib,
  ...
}:
{

  programs.bash = {
    enable = true;
    enableCompletion = true;

    bashrcExtra = ''
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
      "jormungandr" = "ssh wyatt@192.168.69.100";

      "bimp" = "beet import";
      "yt-music" = "yt-dlp -x --audio-format opus --replace-in-metadata uploader ' - Topic' '' --parse-metadata '%(playlist_index)s:%(meta_track)s' --parse-metadata '%(uploader)s:%(meta_album_artist)s' --embed-metadata --format 'bestaudio/best' --audio-quality 0 -o '~/Downloads/Music/%(uploader)s/%(album)s/%(playlist_index)s - %(title)s.%(ext)s' --print '%(uploader)s - %(album)s - %(playlist_index)s %(title)s' --no-simulate";

      "jctl" = "journalctl -p 3 -xb";
      "sysfetch" = ".config/sysfetch/sysfetch";
    };
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = config.programs.bash.shellAliases;

    initContent = ''
      command -v krabby >/dev/null 2>&1 && krabby random
    '';
  };
}
