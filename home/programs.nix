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
    # Alphabetically organized programs
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
    kitty = {
      enable = true;
      font = {
        name = "Maple Mono NF";
        size = 14;
      };

      settings = lib.mkIf (!fileExists "${dotsPath}/kitty") {
        # Official Catppuccin Mocha colors
        foreground = "#CDD6F4";
        background = "#1E1E2E";
        selection_foreground = "#1E1E2E";
        selection_background = "#F5E0DC";

        # Cursor colors
        cursor = "#F5E0DC";
        cursor_text_color = "#1E1E2E";

        # URL underline color when hovering with mouse
        url_color = "#F5E0DC";

        # Kitty window border colors
        active_border_color = "#B4BEFE";
        inactive_border_color = "#6C7086";
        bell_border_color = "#F9E2AF";

        # Tab colors
        active_tab_foreground = "#11111B";
        active_tab_background = "#CBA6F7";
        inactive_tab_foreground = "#CDD6F4";
        inactive_tab_background = "#181825";
        tab_bar_background = "#11111B";

        # The 16 terminal colors (official Catppuccin Mocha)
        # black
        color0 = "#45475A"; # Surface1
        color8 = "#585B70"; # Surface2

        # red
        color1 = "#F38BA8"; # Red
        color9 = "#F38BA8";

        # green
        color2 = "#A6E3A1"; # Green
        color10 = "#A6E3A1";

        # yellow
        color3 = "#F9E2AF"; # Yellow
        color11 = "#F9E2AF";

        # blue
        color4 = "#89B4FA"; # Blue
        color12 = "#89B4FA";

        # magenta
        color5 = "#F5C2E7"; # Pink
        color13 = "#F5C2E7";

        # cyan
        color6 = "#94E2D5"; # Teal
        color14 = "#94E2D5";

        # white
        color7 = "#BAC2DE"; # Subtext1
        color15 = "#A6ADC8"; # Subtext0

        # Performance and behavior settings
        repaint_delay = 10;
        input_delay = 3;
        sync_to_monitor = true;

        # Window settings
        window_padding_width = 4;
        confirm_os_window_close = 0;

        # Tab settings
        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";

        # Other useful settings
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

      # Basic config if no dotfiles
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
          # Essential plugins if no custom config
          vim-sensible
          vim-surround
          vim-commentary
          fzf-vim
          lightline-vim

          # Syntax highlighting
          vim-nix
          vim-markdown
          vim-javascript
          vim-json
        ]
      );
    };

    ssh = {
      enable = true;
    };

    tmux = {
      enable = true;
      terminal = "tmux-256color";
      keyMode = "vi";
      customPaneNavigationAndResize = true;
      # Basic config if no dotfile
      extraConfig = lib.mkIf (!fileExists "${dotsPath}/tmux.conf") ''
        # Terminal settings
        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM
        set-option -sa terminal-overrides ",xterm-kitty:RGB,xterm*:Tc"
        set -g allow-passthrough on

        # Set prefix to Ctrl-a
        unbind C-b
        set -g prefix C-a
        bind C-a send-prefix

        # Split panes using | and -
        bind | split-window -h
        bind - split-window -v
        unbind '"'
        unbind %

        # Reload config
        bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

        # Enable mouse mode
        set -g mouse on

        # Start windows and panes at 1
        set -g base-index 1
        setw -g pane-base-index 1

        # Catppuccin Mocha theme
        thm_bg="#1e1e2e"
        thm_fg="#cdd6f4"
        thm_cyan="#89dceb"
        thm_black="#181825"
        thm_gray="#313244"
        thm_magenta="#cba6f7"
        thm_pink="#f5c2e7"
        thm_red="#f38ba8"
        thm_green="#a6e3a1"
        thm_yellow="#f9e2af"
        thm_blue="#89b4fa"
        thm_orange="#fab387"
        thm_black4="#585b70"

        # Status bar styling
        set -g status-position bottom
        set -g status-justify left
        set -g status-style "fg=$thm_pink,bg=$thm_bg"
        set -g status-interval 1

        # Window status
        setw -g window-status-activity-style "fg=$thm_fg,bg=$thm_bg,none"
        setw -g window-status-separator ""
        setw -g window-status-style "fg=$thm_fg,bg=$thm_bg,none"

        # Active window
        setw -g window-status-current-format "#[fg=$thm_bg,bg=$thm_pink] #I #[fg=$thm_fg,bg=$thm_gray] #W#[fg=$thm_gray,bg=$thm_bg]"

        # Inactive windows
        setw -g window-status-format "#[fg=$thm_bg,bg=$thm_blue] #I #[fg=$thm_fg,bg=$thm_gray] #W #[fg=$thm_gray,bg=$thm_bg]"

        # Status left
        set -g status-left-length 100
        set -g status-left "#[fg=$thm_bg,bg=$thm_green,bold] #S #[fg=$thm_green,bg=$thm_bg]"

        # Status right
        set -g status-right-length 100
        set -g status-right "#[fg=$thm_blue,bg=$thm_bg]#[fg=$thm_bg,bg=$thm_blue] %Y-%m-%d #[fg=$thm_pink,bg=$thm_blue]#[fg=$thm_bg,bg=$thm_pink,bold] %H:%M:%S "

        # Pane borders
        set -g pane-border-style "fg=$thm_gray"
        set -g pane-active-border-style "fg=$thm_blue"

        # Message styling
        set -g message-style "fg=$thm_cyan,bg=$thm_gray,align=centre"
        set -g message-command-style "fg=$thm_cyan,bg=$thm_gray,align=centre"

        # Copy mode styling
        set -g mode-style "fg=$thm_pink,bg=$thm_black4,bold"
      '';
    };
  };

  # Services (Linux-only)
  services = lib.mkIf pkgs.stdenv.isLinux {
    # Dunst notification daemon (moved from app-configs.nix)
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
  };
}
