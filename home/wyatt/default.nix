{ config, pkgs, ... }:
# let
#     dots = "${config.home.homeDirectory}../../dots";
#     create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
#     configs = {
#         beets = "beets";
#         btop = "btop";
#         cava = "cava";
#         fastfetch = "fastfetch";
#         ghostty = "ghostty";
#         helix = "helix";
#         # hypr = "hypr";
#         kew = "kew";
#         picom = "picom";
#         qtile = "qtile";
#         sysfetch = "sysfetch";
#         tut = "tut";
#         waybar = "waybar";
#     };
# in
{
    home.username = "wyatt";
    home.homeDirectory = "/home/wyatt";
    home.stateVersion = "25.05";
    programs.bash = {
        bashrcExtra = "krabby random";
        enable = true;
        shellAliases = {
            ":q" = "exit";
            bimp = "beet import";
            fenrir = "ssh wyatt@192.168.69.200";
            ff = "fastfetch --percent-type 10";
            hf = "hyfetch";
            ls = "eza -1 --icons";
            jctl = "journalctl -p 3 -xb";
            jormungandr = "ssh wyatt@192.168.69.100";
            of = "onefetch -i ~/Pictures/fflogo.png";
            sysfetch = ".config/sysfetch/sysfetch";
            yt-music = "yt-dlp -x --audio-format opus --replace-in-metadata uploader ' - Topic' '' --parse-metadata '%(playlist_index)s:%(meta_track)s' --parse-metadata '%(uploader)s:%(meta_album_artist)s' --embed-metadata  --format 'bestaudio/best' --audio-quality 0 -o '~/Downloads/Music/%(uploader)s/%(album)s/%(playlist_index)s - %(title)s.%(ext)s' --print '%(uploader)s - %(album)s - %(playlist_index)s %(title)s' --no-simulate";
        };
    };
    programs = {
        bat = {
            enable = true;
            config.theme = "ansi";
        };
        git.enable = true;
        ghostty = {
            enable = true;
            enableBashIntegration = true;
            installBatSyntax = true;
        };
        # nvf = {
        #     enable = true;
        #     settings = {
        #         vim.viAlias = true;
        #         vim.vimAlias = true;
        #         vim.lsp = {
        #             enable = true;
        #         };
        #         vim.languages = {
        #             clang = true;
        #             go = true;
        #             html = true;
        #             lua = true;
        #             markdown = true;
        #             nix = true;
        #             rust = true;
        #         };
        #     };
        # };
        starship.enable = true;
    };
    # xdg.configFile = builtins.mapAttrs (name: subpath: {
    #     source = create_symlink "${dots}/${subpath}";
    #     recursive = true;
    # })
    # configs;

    home.file.".config/hyfetch.json".source = ../../dots/hyfetch.json;
    home.file.".config/starship.toml".source = ../../dots/starship.toml;

    services.gnome-keyring.enable = true;
    

    home.packages = with pkgs; [
        bash-language-server
        beets-unstable
        bottom
        btop-rocm
        cava
        discord
        dunst
        eza
        fastfetch
        flameshot
        gcr
        grim
        gopls
        helix
        hyfetch
        hyprpicker
        hyprshot
        kew
        kitty
        krabby
        libreoffice
        marksman
        mullvad-vpn
        nil
        nitrogen
        nixpkgs-fmt
        nodejs
        onefetch
        picom
        protonup-qt
        pyright
        rofi
        ruff
        rust-analyzer
        signal-desktop
        slurp
        swww
        tut
        upower
        vivaldi
        vscode-langservers-extracted
        waybar
        webcord
        wf-recorder
        wl-clipboard-rs
        yt-dlp
    ];
}
