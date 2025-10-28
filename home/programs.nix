{
  config,
  pkgs,
  lib,
  ...
}: let
  dotsPath = ../dots;
  fileExists = path: builtins.pathExists path;
in {
  programs = {
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
      };
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    gnu-emacs = {
      enable = true;
      package = pkgs.emacs;

      emacs.ui = {
        theme = "catppuccin-mocha";
        font = "Maple Mono NF";
        fontSize = 14;
        transparency = 90;
      };

      emacs.modules = {
        completion = {
          vertico = true;
          corfu = true;
        };

        ui = {
          modeline = true;
          hl-todo = true;
          indent-guides = true;
          treemacs = true;
          which-key = true;
        };

        editor = {
          meow = true;
          multiple-cursors = true;
          snippets = true;
        };

        tools = {
          direnv = true;
          editorconfig = true;
          magit = true;
          lsp = true;
        };

        lang = {
          nix = true;
          python = true;
          rust = true;
          markdown = true;
          org = true;
          go = true;
        };
      };
    };

    kitty = {
      enable = true;
      font = {
        name = "Maple Mono NF";
        size = 14;
      };

      settings = lib.mkIf (!fileExists "${dotsPath}/kitty") {
        foreground = "#CDD6F4";
        background = "#1E1E2E";
        selection_foreground = "#1E1E2E";
        selection_background = "#F5E0DC";

        cursor = "#F5E0DC";
        cursor_text_color = "#1E1E2E";

        url_color = "#F5E0DC";

        active_border_color = "#B4BEFE";
        inactive_border_color = "#6C7086";
        bell_border_color = "#F9E2AF";

        active_tab_foreground = "#11111B";
        active_tab_background = "#CBA6F7";
        inactive_tab_foreground = "#CDD6F4";
        inactive_tab_background = "#181825";
        tab_bar_background = "#11111B";

        color0 = "#45475A";
        color8 = "#585B70";
        color1 = "#F38BA8";
        color9 = "#F38BA8";
        color2 = "#A6E3A1";
        color10 = "#A6E3A1";
        color3 = "#F9E2AF";
        color11 = "#F9E2AF";
        color4 = "#89B4FA";
        color12 = "#89B4FA";
        color5 = "#F5C2E7";
        color13 = "#F5C2E7";
        color6 = "#94E2D5";
        color14 = "#94E2D5";
        color7 = "#BAC2DE";
        color15 = "#A6ADC8";

        repaint_delay = 10;
        input_delay = 3;
        sync_to_monitor = true;

        window_padding_width = 4;
        confirm_os_window_close = 0;

        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";

        enable_audio_bell = false;
        visual_bell_duration = "0.0";
        window_alert_on_bell = false;
        bell_on_tab = false;
      };
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraConfig = lib.mkIf (!fileExists "${dotsPath}/nvim") ''
        set number
        set relativenumber
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set smartindent
        set wrap
        set smartcase
        set noswapfile
        set nobackup
        set undofile
        set incsearch
        set termguicolors
        set scrolloff=8
        set sidescrolloff=8
        set mouse=a

        " Basic key mappings
        nnoremap <Space> <Nop>
        let mapleader = " "

        " Save file
        nnoremap <leader>w :w<CR>
        nnoremap <leader>q :q<CR>

        " Split navigation
        nnoremap <C-h> <C-w>h
        nnoremap <C-j> <C-w>j
        nnoremap <C-k> <C-w>k
        nnoremap <C-l> <C-w>l
      '';

      plugins = lib.mkIf (!fileExists "${dotsPath}/nvim") (
        with pkgs.vimPlugins; [
          vim-sensible
          vim-surround
          vim-commentary
          fzf-vim
          lightline-vim
          vim-nix
          vim-markdown
          vim-javascript
          vim-json
        ]
      );
    };

    ssh = {
      enable = true;
      matchBlocks = {
        "fenrir" = {
          hostname = "192.168.69.200";
          user = "wyatt";
        };
        "hel" = {
          hostname = "192.168.69.250";
          user = "wyatt";
        };
        "jormungandr" = {
          hostname = "192.168.69.100";
          user = "wyatt";
        };
      };
    };
  };

  # Services (Linux-only)
  services = lib.mkIf pkgs.stdenv.isLinux {
    dunst = lib.mkIf (!fileExists "${dotsPath}/dunstrc") {
      enable = true;
      settings = {
        global = {
          monitor = 0;
          follow = "mouse";
          geometry = "300x5-30+20";
          indicate_hidden = "yes";
          shrink = "no";
          transparency = 0;
          notification_height = 0;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          frame_width = 3;
          frame_color = "#aaaaaa";
          separator_color = "frame";
          sort = "yes";
          idle_threshold = 120;
          font = "Fira Code 10";
          line_height = 0;
          markup = "full";
          format = "<b>%s</b>\\n%b";
          alignment = "left";
          show_age_threshold = 60;
          word_wrap = "yes";
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "yes";
          icon_position = "left";
          max_icon_size = 32;
          sticky_history = "yes";
          history_length = 20;
          browser = "firefox";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          startup_notification = false;
          verbosity = "mesg";
          corner_radius = 0;
        };
      };
    };
    emacs = {
      enable = true;
      client.enable = true;
      socketActivation.enable = true;
    };
  };
}
