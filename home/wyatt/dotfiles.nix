{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Helper function to check if a file exists
  fileExists = path: builtins.pathExists path;

  # Helper function to conditionally create config file
  mkConfigFile =
    configPath: sourcePath:
    lib.mkIf (fileExists sourcePath) {
      "${configPath}".source = sourcePath;
    };

  dotsPath = ../../dots;
in
{
  # XDG configuration files from dots directory
  xdg.configFile = lib.mkMerge [
    (mkConfigFile "starship.toml" "${dotsPath}/starship.toml")
    (mkConfigFile "hyfetch.json" "${dotsPath}/hyfetch.json")

    # Alacritty terminal configuration
    (mkConfigFile "alacritty/alacritty.yml" "${dotsPath}/alacritty.yml")
    (mkConfigFile "alacritty/alacritty.toml" "${dotsPath}/alacritty.toml")

    # Kitty terminal configuration
    (mkConfigFile "kitty/kitty.conf" "${dotsPath}/kitty.conf")

    # Ghostty terminal configuration
    (mkConfigFile "ghostty/config" "${dotsPath}/ghostty")

    # Neovim configuration (if you have it)
    (lib.mkIf (fileExists "${dotsPath}/nvim") {
      "nvim".source = "${dotsPath}/nvim";
      "nvim".recursive = true;
    })

    # Hyprland configuration (Linux only)
    (lib.mkIf (pkgs.stdenv.isLinux && fileExists "${dotsPath}/hypr") {
      "hypr".source = "${dotsPath}/hypr";
      "hypr".recursive = true;
    })

    # Waybar configuration (Linux only)
    (lib.mkIf (pkgs.stdenv.isLinux) (mkConfigFile "waybar/config" "${dotsPath}/waybar/config"))
    (lib.mkIf (pkgs.stdenv.isLinux) (mkConfigFile "waybar/style.css" "${dotsPath}/waybar/style.css"))

    # Dunst notification configuration (Linux only)
    (lib.mkIf (pkgs.stdenv.isLinux) (mkConfigFile "dunst/dunstrc" "${dotsPath}/dunstrc"))

    # Rofi configuration (Linux only)
    (lib.mkIf (pkgs.stdenv.isLinux && fileExists "${dotsPath}/rofi") {
      "rofi".source = "${dotsPath}/rofi";
      "rofi".recursive = true;
    })

    # Firefox user.js and userChrome.css (if you have them)
    (lib.mkIf (fileExists "${dotsPath}/firefox") {
      "firefox-custom".source = "${dotsPath}/firefox";
      "firefox-custom".recursive = true;
    })

    # Git configuration files
    (mkConfigFile "git/ignore" "${dotsPath}/gitignore_global")
    (mkConfigFile "git/attributes" "${dotsPath}/gitattributes")

    # Zsh configuration
    (mkConfigFile "zsh/.zshrc" "${dotsPath}/zshrc")
    (mkConfigFile "zsh/.zprofile" "${dotsPath}/zprofile")

    # Bash configuration
    (mkConfigFile "bash/.bashrc" "${dotsPath}/bashrc")
    (mkConfigFile "bash/.bash_profile" "${dotsPath}/bash_profile")

    # Tmux configuration
    (mkConfigFile "tmux/tmux.conf" "${dotsPath}/tmux.conf")

    # Fastfetch configuration
    (mkConfigFile "fastfetch/config.jsonc" "${dotsPath}/fastfetch.jsonc")

    # Bottom (btop alternative) configuration
    (mkConfigFile "bottom/bottom.toml" "${dotsPath}/bottom.toml")

    # Custom scripts directory
    (lib.mkIf (fileExists "${dotsPath}/scripts") {
      "scripts".source = "${dotsPath}/scripts";
      "scripts".recursive = true;
    })
  ];

  # Home directory dotfiles (files that need to be in ~/)
  home.file = lib.mkMerge [
    # Wallpapers directory
    (lib.mkIf (fileExists "${dotsPath}/wallpapers") {
      "Pictures/wallpapers".source = "${dotsPath}/wallpapers";
      "Pictures/wallpapers".recursive = true;
    })

    # Custom themes directory
    (lib.mkIf (fileExists "${dotsPath}/themes") {
      ".themes".source = "${dotsPath}/themes";
      ".themes".recursive = true;
    })

    # Custom icons directory
    (lib.mkIf (fileExists "${dotsPath}/icons") {
      ".icons".source = "${dotsPath}/icons";
      ".icons".recursive = true;
    })

    # Local bin directory for custom scripts
    (lib.mkIf (fileExists "${dotsPath}/bin") {
      ".local/bin".source = "${dotsPath}/bin";
      ".local/bin".recursive = true;
    })

    # SSH config (be careful with permissions)
    (lib.mkIf (fileExists "${dotsPath}/ssh_config") {
      ".ssh/config".source = "${dotsPath}/ssh_config";
    })

    # GPG configuration
    (lib.mkIf (fileExists "${dotsPath}/gpg.conf") {
      ".gnupg/gpg.conf".source = "${dotsPath}/gpg.conf";
    })
  ];

  # Set executable permissions for scripts
  home.activation = lib.mkIf (fileExists "${dotsPath}/scripts") {
    makeScriptsExecutable = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -d "$HOME/.config/scripts" ]; then
        find "$HOME/.config/scripts" -type f -name "*.sh" -exec chmod +x {} \;
        find "$HOME/.config/scripts" -type f -name "*.py" -exec chmod +x {} \;
      fi

      if [ -d "$HOME/.local/bin" ]; then
        find "$HOME/.local/bin" -type f -exec chmod +x {} \;
      fi
    '';
  };
}
