{ config, pkgs, ... }:
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
                # vim.languages = {
                #     bash = {
                #         enable = true;
                #         extraDiagnostics.enable = true;
                #         format.enable = true;
                #         lsp.enable = true;
                #         treesitter.enable = true;
                #     };
                #     clang = {
                #         enable = true;
                #         extraDiagnostics.enable = true;
                #         format.enable = true;
                #         lsp.enable = true;
                #         treesitter.enable = true;
                #     };
                #     go = {
                #         enable = true;
                #         format.enable = true;
                #         lsp.enable = true;
                #         treesitter.enable = true;
                #     };
                #     html = {
                #         enable = true;
                #         extraDiagnostics.enable = true;
                #         format.enable = true;
                #         lsp.enable = true;
                #         treesitter.enable = true;
                #     };
                #     lua = {
                #         enable = true;
                #         lsp.enable = true;
                #         treesitter.enable = true;
                #     };
                #     markdown = {
                #         enable = true;
                #         lsp.enable = true;
                #         treesitter.enable = true;
                #     };
                #     nix = {
                #         enable = true;
                #         extraDiagnostics.enable = true;
                #         format.enable = true;
                #         lsp.enable = true;
                #         treesitter.enable = true;
                #     };
                #     python = {
                #         enable = true;
                #         format.enable = true;
                #         lsp.enable = true;
                #         treesitter.enable = true;
                #     };
                #     rust = {
                #         enable = true;
                #         format.enable = true;
                #         lsp.enable = true;
                #         treesitter.enable = true;
                #     };
                # };
        #     };
        # };
        starship.enable = true;
    };

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
        gcr
        grim
        gopls
        evil-helix
        hyfetch
        kew
        kitty
        krabby
        marksman
        mullvad-vpn
        nil
        nitrogen
        nixpkgs-fmt
        nodejs
        onefetch
        pyright
        ruff
        rust-analyzer
        signal-desktop
        tut
        upower
        vivaldi
        vscode-langservers-extracted
        waybar
        webcord
        yt-dlp
    ];
}
