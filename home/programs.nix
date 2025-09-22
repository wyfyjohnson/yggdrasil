{
  config,
  pkgs,
  lib,
  ...
}: {
  programs = {
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
      };
    };
    # bash = {
    #   enable = true;
    #   enableCompletion = true;
  };
  # Terminal emulators - basic configs
  # ghostty = {
  #   enable = true;
  #   enableBashIntegration = true;
  # };
  kitty = {
    enable = true;
    font = {
      name = "Maple Mono NF"; # or whatever font you prefer
      size = 12;
    };

    settings = {
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
    };
  };
  # Development tools
  direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  # File utilities
  fzf = {
    enable = true;
    enableBashIntegration = true;
  };
  ssh = {
    enable = true;
  };
  starship = {
    enable = true;
  };

  # Neovim - use dotfiles if available
  neovim = lib.mkIf (fileExists "${dotsPath}/nvim" || !fileExists "${dotsPath}/nvim") {
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

  # Tmux configuration
  tmux = lib.mkIf (fileExists "${dotsPath}/tmux.conf" || !fileExists "${dotsPath}/tmux.conf") {
    enable = true;
    terminal = "screen-256color";
    keyMode = "vi";
    customPaneNavigationAndResize = true;

    # Basic config if no dotfile
    extraConfig = lib.mkIf (!fileExists "${dotsPath}/tmux.conf") ''
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

      # Status bar
      set -g status-position bottom
      set -g status-bg colour234
      set -g status-fg colour137
      set -g status-left ""
      set -g status-right "#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S "
      set -g status-right-length 50
      set -g status-left-length 20

      setw -g window-status-current-format " #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F "
      setw -g window-status-format " #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F "
    '';
  };
}
