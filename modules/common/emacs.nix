{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.gnu-emacs;
in {
  options.programs.gnu-emacs = {
    enable = mkEnableOption "GNU Emacs configuration";

    package = mkOption {
      type = types.package;
      default = pkgs.emacs;
      description = "Emacs package to use";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Extra system packages (like sqlite, graphviz)";
    };

    emacs = {
      ui = {
        theme = mkOption {
          type = types.enum ["catppuccin-mocha" "catppuccin-macchiato" "catppuccin-frappe" "catppuccin-latte"];
          default = "catppuccin-mocha";
          description = "Catppuccin theme variant to use";
        };

        fontSize = mkOption {
          type = types.int;
          default = 12;
          description = "Default font size";
        };

        font = mkOption {
          type = types.str;
          default = "Maple Mono NF";
          description = "Default font family";
        };

        transparency = mkOption {
          type = types.int;
          default = 90;
          description = "Transparency level (0-100, where 100 is opaque)";
        };
      };

      modules = {
        completion = {
          vertico = mkEnableOption "Vertico completion" // {default = true;};
          corfu = mkEnableOption "Corfu inline completion" // {default = true;};
        };

        ui = {
          modeline = mkEnableOption "Doom modeline" // {default = true;};
          hl-todo = mkEnableOption "Highlight TODOs" // {default = true;};
          indent-guides = mkEnableOption "Indent guides" // {default = true;};
          ligatures = mkEnableOption "Ligature support" // {default = true;};
          minimap = mkEnableOption "Minimap sidebar" // {default = false;};
          treemacs = mkEnableOption "Treemacs file explorer" // {default = true;};
          which-key = mkEnableOption "Which-key" // {default = true;};
        };

        editor = {
          evil = mkEnableOption "Evil mode" // {default = true;};
          file-templates = mkEnableOption "File templates" // {default = true;};
          fold = mkEnableOption "Code folding" // {default = true;};
          multiple-cursors = mkEnableOption "Multiple cursors" // {default = true;};
          snippets = mkEnableOption "Yasnippet" // {default = true;};
        };

        base = {
          dired = mkEnableOption "Dired enhancements" // {default = true;};
          electric = mkEnableOption "Electric indent" // {default = true;};
          undo = mkEnableOption "Undo tree" // {default = true;};
          vc = mkEnableOption "Version control" // {default = true;};
        };

        tools = {
          debugger = mkEnableOption "DAP debugger" // {default = true;};
          direnv = mkEnableOption "Direnv integration" // {default = true;};
          editorconfig = mkEnableOption "EditorConfig" // {default = true;};
          magit = mkEnableOption "Magit" // {default = true;};
          lsp = mkEnableOption "LSP mode" // {default = true;};
          tree-sitter = mkEnableOption "Tree-sitter" // {default = true;};
        };

        lang = {
          nix = mkEnableOption "Nix support" // {default = true;};
          python = mkEnableOption "Python support" // {default = false;};
          rust = mkEnableOption "Rust support" // {default = false;};
          javascript = mkEnableOption "JavaScript support" // {default = false;};
          typescript = mkEnableOption "TypeScript support" // {default = false;};
          go = mkEnableOption "Go support" // {default = false;};
          markdown = mkEnableOption "Markdown support" // {default = true;};
          org = mkEnableOption "Org mode enhancements" // {default = true;};
          latex = mkEnableOption "LaTeX support" // {default = false;};
          web = mkEnableOption "HTML/CSS/Web support" // {default = true;};
          yaml = mkEnableOption "YAML support" // {default = true;};
          toml = mkEnableOption "TOML support" // {default = true;};
        };
      };
    };
  };

  config = mkIf cfg.enable {
    programs.emacs = {
      enable = true;
      package = cfg.package;

      extraPackages = epkgs:
        with epkgs;
          [
            # Theme
            catppuccin-theme
            # Dashboard for splash screen
            dashboard
            nerd-icons
          ]
          ++ optional cfg.emacs.modules.ui.modeline doom-modeline
          ++ optional cfg.emacs.modules.ui.which-key which-key
          ++ optional cfg.emacs.modules.ui.hl-todo hl-todo
          ++ optional cfg.emacs.modules.ui.indent-guides highlight-indent-guides
          ++ optional cfg.emacs.modules.ui.treemacs treemacs
          ++ optionals (cfg.emacs.modules.ui.treemacs && cfg.emacs.modules.editor.evil) [treemacs-evil]
          ++ optionals (cfg.emacs.modules.ui.treemacs && cfg.emacs.modules.tools.magit) [treemacs-magit]
          # Completion
          ++ optionals cfg.emacs.modules.completion.vertico [vertico orderless marginalia consult]
          ++ optionals cfg.emacs.modules.completion.corfu [corfu cape]
          # Editor - Enhanced Evil mode with more packages
          ++ optionals cfg.emacs.modules.editor.evil [
            evil
            evil-collection
            evil-surround
            evil-commentary
            evil-numbers
            evil-exchange
            evil-args
            evil-indent-plus
            evil-visualstar
            evil-lion
            evil-matchit
            evil-snipe
            evil-goggles
            avy
            evil-easymotion
          ]
          ++ optional cfg.emacs.modules.editor.multiple-cursors evil-multiedit
          ++ optionals cfg.emacs.modules.editor.snippets [yasnippet yasnippet-snippets]
          ++ optional cfg.emacs.modules.base.undo undo-tree
          # Tools
          ++ optional cfg.emacs.modules.tools.magit magit
          ++ optional cfg.emacs.modules.tools.direnv envrc
          ++ optional cfg.emacs.modules.tools.editorconfig editorconfig
          ++ optionals cfg.emacs.modules.tools.lsp [lsp-mode lsp-ui]
          ++ optionals cfg.emacs.modules.tools.tree-sitter [tree-sitter tree-sitter-langs]
          # Languages
          ++ optional cfg.emacs.modules.lang.nix nix-mode
          ++ optional cfg.emacs.modules.lang.python python-mode
          ++ optional cfg.emacs.modules.lang.rust rust-mode
          ++ optional cfg.emacs.modules.lang.javascript js2-mode
          ++ optional cfg.emacs.modules.lang.typescript typescript-mode
          ++ optional cfg.emacs.modules.lang.go go-mode
          ++ optional cfg.emacs.modules.lang.markdown markdown-mode
          ++ optionals cfg.emacs.modules.lang.org [org-bullets]
          ++ optionals cfg.emacs.modules.lang.web [web-mode emmet-mode]
          ++ optional cfg.emacs.modules.lang.yaml yaml-mode
          ++ optional cfg.emacs.modules.lang.toml toml-mode;
    };

    # System packages for Emacs
    home.packages = with pkgs;
      [
        # Tools that Emacs needs
        (ripgrep.override {withPCRE2 = true;})
        fd

        # Formatters for various languages
        nixpkgs-fmt # Nix formatter (or use alejandra)
        black # Python formatter
        python3Packages.isort # Python import sorter
        rustfmt # Rust formatter
        nodePackages.prettier # JS/TS/JSON/CSS/HTML/Markdown formatter
        shfmt # Shell script formatter
        go-tools # Includes gofmt, goimports

        # LSP servers
      ]
      ++ optionals cfg.emacs.modules.tools.lsp (
        optional cfg.emacs.modules.lang.nix nil
        ++ optional cfg.emacs.modules.lang.python python3Packages.python-lsp-server
        ++ optional cfg.emacs.modules.lang.rust rust-analyzer
        ++ optional cfg.emacs.modules.lang.typescript nodePackages.typescript-language-server
        ++ optional cfg.emacs.modules.lang.go gopls
        ++ optional cfg.emacs.modules.lang.javascript nodePackages.typescript-language-server
      )
      ++ optional cfg.emacs.modules.tools.editorconfig editorconfig-core-c
      ++ optional cfg.emacs.modules.lang.markdown pandoc
      ++ cfg.extraPackages;

    # Emacs configuration file
    home.file.".emacs.d/init.el".text = ''
      ;;; init.el --- Yggdrasil Emacs Configuration -*- lexical-binding: t -*-

      ;;; Startup optimization
      (setq gc-cons-threshold most-positive-fixnum)
      (add-hook 'emacs-startup-hook
                (lambda ()
                  (setq gc-cons-threshold (* 16 1024 1024))))

      ;;; Better defaults
      (setq-default
       indent-tabs-mode nil
       tab-width 4
       fill-column 80
       require-final-newline t
       scroll-margin 8                      ;; Keep 8 lines visible above/below cursor
       scroll-step 1                        ;; Scroll one line at a time
       scroll-conservatively 10000          ;; Never recenter point
       scroll-preserve-screen-position t
       auto-window-vscroll nil              ;; Improve scrolling performance
       ring-bell-function 'ignore
       inhibit-startup-screen t
       initial-scratch-message nil
       read-process-output-max (* 1024 1024))

      ;; UTF-8 everywhere
      (set-default-coding-systems 'utf-8)
      (prefer-coding-system 'utf-8)

      ;; UI cleanup
      (menu-bar-mode -1)
      (when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
      (when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

      ;; Better window management
      (setq split-width-threshold 160
            split-height-threshold nil)

      ;; Backup and auto-save - all temp files go to ~/.emacs.d/tempDir/
      (setq backup-directory-alist `(("." . ,(expand-file-name "tempDir" user-emacs-directory)))
            backup-by-copying t
            version-control t
            delete-old-versions t
            kept-new-versions 6
            kept-old-versions 2
            auto-save-default t
            auto-save-timeout 30
            auto-save-interval 200
            auto-save-file-name-transforms
            `((".*" ,(expand-file-name "tempDir/" user-emacs-directory) t))
            ;; Also save lock files to tempDir
            lock-file-name-transforms
            `((".*" ,(expand-file-name "tempDir/" user-emacs-directory) t))
            create-lockfiles t)

      ;; Custom file - also save to tempDir to avoid clutter
      (setq custom-file (expand-file-name "tempDir/custom.el" user-emacs-directory))
      (when (file-exists-p custom-file)
        (load custom-file))

      ;; Recent files configuration - enable recentf mode
      (require 'recentf)
      (setq recentf-save-file (expand-file-name "tempDir/recentf" user-emacs-directory)
            recentf-max-saved-items 50
            recentf-max-menu-items 15
            recentf-auto-cleanup 'never
            recentf-exclude '("/tmp/" "/ssh:" "\\.?undo-tree" "tempDir"))
      (recentf-mode 1)

      ;; Save recentf list when switching buffers and periodically
      (add-hook 'kill-buffer-hook 'recentf-save-list)
      (add-hook 'after-save-hook 'recentf-save-list)
      (run-at-time nil (* 5 60) 'recentf-save-list)

      ;; Load existing recent files on startup
      (when (file-exists-p recentf-save-file)
        (recentf-load-list))

      ;;; UI Configuration

      ;; Font
      (set-face-attribute 'default nil
                          :family "${cfg.emacs.ui.font}"
                          :height (* ${toString cfg.emacs.ui.fontSize} 10))

      ;; Line numbers
      (global-display-line-numbers-mode 1)
      (setq display-line-numbers-type 'relative)

      ;; Highlight current line
      (global-hl-line-mode 1)

      ;; Show matching parens
      (show-paren-mode 1)
      (setq show-paren-delay 0)

      ;; Transparency settings
      (defun set-transparency (value)
        "Set the transparency of the frame window. 0=transparent/100=opaque"
        (interactive "nTransparency Value (0-100): ")
        (set-frame-parameter nil 'alpha-background value))

      ;; Set initial transparency
      (set-frame-parameter nil 'alpha-background ${toString cfg.emacs.ui.transparency})

      ;; For daemon mode - apply to all new frames
      (add-to-list 'default-frame-alist '(alpha-background . ${toString cfg.emacs.ui.transparency}))

      ;; Toggle transparency function
      (defun toggle-transparency ()
        "Toggle between transparent and opaque."
        (interactive)
        (let ((alpha (frame-parameter nil 'alpha-background)))
          (if (and alpha (< alpha 100))
              (set-frame-parameter nil 'alpha-background 100)
            (set-frame-parameter nil 'alpha-background ${toString cfg.emacs.ui.transparency}))))

      ;; Theme
      (require 'catppuccin-theme)
      (setq catppuccin-flavor '${replaceStrings ["catppuccin-"] [""] cfg.emacs.ui.theme})
      (load-theme 'catppuccin t)

      ;;; Dashboard (Doom-style splash screen)
      (require 'dashboard)

      ;; Dashboard configuration - set BEFORE setup-startup-hook
      (setq dashboard-banner-logo-title "Y G G D R A S I L"
            dashboard-startup-banner 'logo
            dashboard-center-content t
            dashboard-show-shortcuts nil
            dashboard-set-heading-icons nil  ;; Disable icons for reliability
            dashboard-set-file-icons nil
            dashboard-items '((recents  . 5)
                              (bookmarks . 5))
            dashboard-footer-messages
            '("Wyfy's Cross-Platform Nix Configuration"
              "Powered by Nix + Home Manager + Emacs")
            dashboard-footer-icon "")

      ;; Setup dashboard
      (dashboard-setup-startup-hook)

      ;; Force dashboard to show on startup
      (setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

      ${optionalString cfg.emacs.modules.ui.modeline ''
        ;; Doom Modeline
        (require 'doom-modeline)
        (doom-modeline-mode 1)
        (setq doom-modeline-height 25
              doom-modeline-bar-width 3
              doom-modeline-buffer-file-name-style 'truncate-upto-project
              doom-modeline-icon t
              doom-modeline-major-mode-icon t
              doom-modeline-major-mode-color-icon t)
      ''}

      ${optionalString cfg.emacs.modules.ui.which-key ''
        ;; Which Key
        (require 'which-key)
        (which-key-mode)
        (setq which-key-idle-delay 0.3)
      ''}
 ${optionalString cfg.emacs.modules.editor.evil ''
        ;; Evil Mode - Core Configuration
        ;; CRITICAL: Set these BEFORE requiring evil or evil-collection
        (setq evil-want-integration t
              evil-want-keybinding nil  ;; Must be set BEFORE loading evil
              evil-want-C-u-scroll t
              evil-want-C-d-scroll t
              evil-want-C-i-jump nil
              evil-respect-visual-line-mode t
              evil-search-module 'evil-search
              evil-ex-complete-emacs-commands nil
              evil-vsplit-window-right t
              evil-split-window-below t
              evil-shift-round nil
              evil-want-C-w-in-emacs-state nil)

        ${optionalString cfg.emacs.modules.base.undo ''
          ;; Undo Tree - configure before evil
          (setq undo-tree-auto-save-history t
                undo-tree-history-directory-alist
                `(("." . ,(expand-file-name "tempDir/undo-tree/" user-emacs-directory))))
          
          ;; Create undo-tree directory if it doesn't exist
          (unless (file-exists-p (expand-file-name "tempDir/undo-tree/" user-emacs-directory))
            (make-directory (expand-file-name "tempDir/undo-tree/" user-emacs-directory) t))
          
          (require 'undo-tree)
          (global-undo-tree-mode)
          (setq evil-undo-system 'undo-tree)
        ''}

        ;; NOW load evil mode
        (require 'evil)
        (evil-mode 1)

        ;; Evil Collection - load AFTER evil
        (require 'evil-collection)
        (evil-collection-init)

        ;; Evil Surround - cs, ds, ys commands
        (require 'evil-surround)
        (global-evil-surround-mode 1)

        ;; Evil Commentary - gc commands
        (require 'evil-commentary)
        (evil-commentary-mode)

        ;; Evil Numbers - C-a/C-x to increment/decrement
        (require 'evil-numbers)
        (define-key evil-normal-state-map (kbd "C-a") 'evil-numbers/inc-at-pt)
        (define-key evil-normal-state-map (kbd "C-x") 'evil-numbers/dec-at-pt)
        (define-key evil-visual-state-map (kbd "C-a") 'evil-numbers/inc-at-pt)
        (define-key evil-visual-state-map (kbd "C-x") 'evil-numbers/dec-at-pt)
        (define-key evil-normal-state-map (kbd "g C-a") 'evil-numbers/inc-at-pt-incremental)
        (define-key evil-normal-state-map (kbd "g C-x") 'evil-numbers/dec-at-pt-incremental)

        ;; Evil Exchange - gx to exchange text
        (require 'evil-exchange)
        (evil-exchange-install)

        ;; Evil Args - text objects for arguments
        (require 'evil-args)
        (define-key evil-inner-text-objects-map "a" 'evil-inner-arg)
        (define-key evil-outer-text-objects-map "a" 'evil-outer-arg)

        ;; Evil Indent Plus - text objects for indentation
        (require 'evil-indent-plus)
        (evil-indent-plus-default-bindings)

        ;; Evil Visualstar - * and # in visual mode
        (require 'evil-visualstar)
        (global-evil-visualstar-mode)

        ;; Evil Lion - gl and gL for alignment
        (require 'evil-lion)
        (evil-lion-mode)

        ;; Evil Matchit - % for matching tags/brackets
        (require 'evil-matchit)
        (global-evil-matchit-mode 1)

        ;; Evil Snipe - improved f/F/t/T motions
        (require 'evil-snipe)
        (evil-snipe-mode +1)
        (evil-snipe-override-mode +1)
        (setq evil-snipe-smart-case t
              evil-snipe-scope 'whole-visible
              evil-snipe-repeat-scope 'visible
              evil-snipe-char-fold t)

        ;; Evil Goggles - visual feedback for operations
        (require 'evil-goggles)
        (evil-goggles-mode)
        (setq evil-goggles-duration 0.100) ;; 100ms flash

        ;; Avy - jump to any visible position
        (require 'avy)
        (setq avy-all-windows t
              avy-background t
              avy-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l ?q ?w ?e ?r ?u ?i ?o ?p))

        ;; Evil Easymotion - vim-easymotion for Emacs
        (require 'evil-easymotion)
        (evilem-default-keybindings "gs")

        ;; Additional vim-like search motions
        (define-key evil-normal-state-map (kbd "*") 'evil-search-word-forward)
        (define-key evil-normal-state-map (kbd "#") 'evil-search-word-backward)
        (define-key evil-normal-state-map (kbd "n") 'evil-search-next)
        (define-key evil-normal-state-map (kbd "N") 'evil-search-previous)

        ;; Custom keybindings (Doom Emacs style with SPC leader)
        (evil-set-leader 'normal (kbd "SPC"))
        (evil-set-leader 'visual (kbd "SPC"))

        ;; File operations
        (evil-define-key 'normal 'global (kbd "<leader>ff") 'find-file)
        (evil-define-key 'normal 'global (kbd "<leader>fs") 'save-buffer)
        (evil-define-key 'normal 'global (kbd "<leader>fr") 'consult-recent-file)
        (evil-define-key 'normal 'global (kbd "<leader>fD") 'delete-file)

        ;; Buffer operations
        (evil-define-key 'normal 'global (kbd "<leader>bb") 'consult-buffer)
        (evil-define-key 'normal 'global (kbd "<leader>bd") 'kill-current-buffer)
        (evil-define-key 'normal 'global (kbd "<leader>bn") 'next-buffer)
        (evil-define-key 'normal 'global (kbd "<leader>bp") 'previous-buffer)
        (evil-define-key 'normal 'global (kbd "<leader>bR") 'revert-buffer)

        ;; Window operations
        (evil-define-key 'normal 'global (kbd "<leader>wv") 'evil-window-vsplit)
        (evil-define-key 'normal 'global (kbd "<leader>ws") 'evil-window-split)
        (evil-define-key 'normal 'global (kbd "<leader>wd") 'evil-window-delete)
        (evil-define-key 'normal 'global (kbd "<leader>wh") 'evil-window-left)
        (evil-define-key 'normal 'global (kbd "<leader>wj") 'evil-window-down)
        (evil-define-key 'normal 'global (kbd "<leader>wk") 'evil-window-up)
        (evil-define-key 'normal 'global (kbd "<leader>wl") 'evil-window-right)
        (evil-define-key 'normal 'global (kbd "<leader>w=") 'balance-windows)

        ;; Search operations
        (evil-define-key 'normal 'global (kbd "<leader>ss") 'consult-line)
        (evil-define-key 'normal 'global (kbd "<leader>sp") 'consult-ripgrep)
        (evil-define-key 'normal 'global (kbd "<leader>sb") 'consult-buffer)
        (evil-define-key 'normal 'global (kbd "<leader>si") 'consult-imenu)

        ;; Jump operations (avy/easymotion)
        (evil-define-key 'normal 'global (kbd "<leader>jj") 'avy-goto-char-2)
        (evil-define-key 'normal 'global (kbd "<leader>jl") 'avy-goto-line)
        (evil-define-key 'normal 'global (kbd "<leader>jw") 'avy-goto-word-1)
        (evil-define-key 'normal 'global (kbd "<leader>jc") 'avy-goto-char-timer)

        ;; Toggle operations
        (evil-define-key 'normal 'global (kbd "<leader>tn") 'display-line-numbers-mode)
        (evil-define-key 'normal 'global (kbd "<leader>tr") 'read-only-mode)
        (evil-define-key 'normal 'global (kbd "<leader>tw") 'whitespace-mode)
        (evil-define-key 'normal 'global (kbd "<leader>tt") 'toggle-transparency)

        ;; Git operations (if magit is enabled)
        ${optionalString cfg.emacs.modules.tools.magit ''
          (evil-define-key 'normal 'global (kbd "<leader>gg") 'magit-status)
          (evil-define-key 'normal 'global (kbd "<leader>gd") 'magit-diff-unstaged)
          (evil-define-key 'normal 'global (kbd "<leader>gc") 'magit-commit)
          (evil-define-key 'normal 'global (kbd "<leader>gp") 'magit-push)
          (evil-define-key 'normal 'global (kbd "<leader>gl") 'magit-log)
        ''}

        ;; Code operations (if LSP is enabled)
        ${optionalString cfg.emacs.modules.tools.lsp ''
          (evil-define-key 'normal 'global (kbd "<leader>ca") 'lsp-execute-code-action)
          (evil-define-key 'normal 'global (kbd "<leader>cr") 'lsp-rename)
          (evil-define-key 'normal 'global (kbd "<leader>cf") 'lsp-format-buffer)
          (evil-define-key 'normal 'global (kbd "<leader>cd") 'lsp-find-definition)
          (evil-define-key 'normal 'global (kbd "<leader>cD") 'lsp-find-declaration)
          (evil-define-key 'normal 'global (kbd "<leader>ci") 'lsp-find-implementation)
          (evil-define-key 'normal 'global (kbd "<leader>ct") 'lsp-find-type-definition)
          (evil-define-key 'normal 'global (kbd "<leader>cR") 'lsp-find-references)
        ''}

        ;; Help/Documentation
        (evil-define-key 'normal 'global (kbd "<leader>hf") 'describe-function)
        (evil-define-key 'normal 'global (kbd "<leader>hv") 'describe-variable)
        (evil-define-key 'normal 'global (kbd "<leader>hk") 'describe-key)
        (evil-define-key 'normal 'global (kbd "<leader>hm") 'describe-mode)

        ;; Quick actions
        (evil-define-key 'normal 'global (kbd "<leader>qq") 'save-buffers-kill-terminal)
        (evil-define-key 'normal 'global (kbd "<leader>qr") 'restart-emacs)

        ;; Additional vim-like improvements
        (define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
        (define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)
        (define-key evil-normal-state-map (kbd "gj") 'evil-next-line)
        (define-key evil-normal-state-map (kbd "gk") 'evil-previous-line)
        (define-key evil-normal-state-map (kbd "Y") (kbd "y$"))
        (define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
        (define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
        (define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
        (define-key evil-normal-state-map (kbd "C-l") 'evil-window-right)

        ;; ESC to quit things
        (define-key evil-normal-state-map [escape] 'keyboard-quit)
        (define-key evil-visual-state-map [escape] 'keyboard-quit)
        (define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
        (define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
        (define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
        (define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
        (define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)
      ''}
        (evil-define-key 'normal 'global (kbd "<leader>tn") 'display-line-numbers-mode)
        (evil-define-key 'normal 'global (kbd "<leader>tr") 'read-only-mode)
        (evil-define-key 'normal 'global (kbd "<leader>tw") 'whitespace-mode)
        (evil-define-key 'normal 'global (kbd "<leader>tt") 'toggle-transparency)

        ;; Git operations (if magit is enabled)
        ${optionalString cfg.emacs.modules.tools.magit ''
          (evil-define-key 'normal 'global (kbd "<leader>gg") 'magit-status)
          (evil-define-key 'normal 'global (kbd "<leader>gd") 'magit-diff-unstaged)
          (evil-define-key 'normal 'global (kbd "<leader>gc") 'magit-commit)
          (evil-define-key 'normal 'global (kbd "<leader>gp") 'magit-push)
          (evil-define-key 'normal 'global (kbd "<leader>gl") 'magit-log)
        ''}

        ;; Code operations (if LSP is enabled)
        ${optionalString cfg.emacs.modules.tools.lsp ''
          (evil-define-key 'normal 'global (kbd "<leader>ca") 'lsp-execute-code-action)
          (evil-define-key 'normal 'global (kbd "<leader>cr") 'lsp-rename)
          (evil-define-key 'normal 'global (kbd "<leader>cf") 'lsp-format-buffer)
          (evil-define-key 'normal 'global (kbd "<leader>cd") 'lsp-find-definition)
          (evil-define-key 'normal 'global (kbd "<leader>cD") 'lsp-find-declaration)
          (evil-define-key 'normal 'global (kbd "<leader>ci") 'lsp-find-implementation)
          (evil-define-key 'normal 'global (kbd "<leader>ct") 'lsp-find-type-definition)
          (evil-define-key 'normal 'global (kbd "<leader>cR") 'lsp-find-references)
        ''}

        ;; Help/Documentation
        (evil-define-key 'normal 'global (kbd "<leader>hf") 'describe-function)
        (evil-define-key 'normal 'global (kbd "<leader>hv") 'describe-variable)
        (evil-define-key 'normal 'global (kbd "<leader>hk") 'describe-key)
        (evil-define-key 'normal 'global (kbd "<leader>hm") 'describe-mode)

        ;; Quick actions
        (evil-define-key 'normal 'global (kbd "<leader>qq") 'save-buffers-kill-terminal)
        (evil-define-key 'normal 'global (kbd "<leader>qr") 'restart-emacs)

        ;; Additional vim-like improvements
        (define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
        (define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)
        (define-key evil-normal-state-map (kbd "gj") 'evil-next-line)
        (define-key evil-normal-state-map (kbd "gk") 'evil-previous-line)
        (define-key evil-normal-state-map (kbd "Y") (kbd "y$"))
        (define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
        (define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
        (define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
        (define-key evil-normal-state-map (kbd "C-l") 'evil-window-right)

        ;; ESC to quit things
        (define-key evil-normal-state-map [escape] 'keyboard-quit)
        (define-key evil-visual-state-map [escape] 'keyboard-quit)
        (define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
        (define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
        (define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
        (define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
        (define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)
      ''}

      ${optionalString cfg.emacs.modules.editor.multiple-cursors ''
        ;; Multiple Cursors
        (require 'evil-multiedit)
        (evil-multiedit-default-keybinds)
      ''}

      ${optionalString cfg.emacs.modules.editor.snippets ''
        ;; Yasnippet
        (require 'yasnippet)
        (yas-global-mode 1)
      ''}

      ;;; Tools

      ${optionalString cfg.emacs.modules.tools.magit ''
        ;; Magit
        (require 'magit)
        (global-set-key (kbd "C-x g") 'magit-status)
      ''}

      ${optionalString cfg.emacs.modules.tools.lsp ''
        ;; LSP Mode
        (require 'lsp-mode)
        (setq lsp-keymap-prefix "C-c l"
              lsp-idle-delay 0.5
              lsp-enable-file-watchers nil
              lsp-signature-auto-activate nil)

        (require 'lsp-ui)
        (setq lsp-ui-doc-enable t
              lsp-ui-doc-position 'at-point
              lsp-ui-sideline-enable t)
      ''}

      ${optionalString cfg.emacs.modules.tools.tree-sitter ''
        ;; Tree-sitter
        (require 'tree-sitter)
        (global-tree-sitter-mode)
        (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)

        (require 'tree-sitter-langs)
      ''}

      ${optionalString cfg.emacs.modules.tools.direnv ''
        ;; Direnv
        (require 'envrc)
        (envrc-global-mode)
      ''}

      ${optionalString cfg.emacs.modules.tools.editorconfig ''
        ;; EditorConfig
        (require 'editorconfig)
        (editorconfig-mode 1)
      ''}

      ;;; Languages

      ${optionalString cfg.emacs.modules.lang.nix ''
        ;; Nix
        (require 'nix-mode)
        (add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))
        ${optionalString cfg.emacs.modules.tools.lsp "(add-hook 'nix-mode-hook #'lsp-deferred)"}
      ''}

      ${optionalString cfg.emacs.modules.lang.python ''
        ;; Python
        (require 'python-mode)
        ${optionalString cfg.emacs.modules.tools.lsp "(add-hook 'python-mode-hook #'lsp-deferred)"}
      ''}

      ${optionalString cfg.emacs.modules.lang.rust ''
        ;; Rust
        (require 'rust-mode)
        ${optionalString cfg.emacs.modules.tools.lsp "(add-hook 'rust-mode-hook #'lsp-deferred)"}
      ''}

      ${optionalString cfg.emacs.modules.lang.javascript ''
        ;; JavaScript
        (require 'js2-mode)
        (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
        ${optionalString cfg.emacs.modules.tools.lsp "(add-hook 'js2-mode-hook #'lsp-deferred)"}
      ''}

      ${optionalString cfg.emacs.modules.lang.typescript ''
        ;; TypeScript
        (require 'typescript-mode)
        (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
        ${optionalString cfg.emacs.modules.tools.lsp "(add-hook 'typescript-mode-hook #'lsp-deferred)"}
      ''}

      ${optionalString cfg.emacs.modules.lang.go ''
        ;; Go
        (require 'go-mode)
        (add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))
        ${optionalString cfg.emacs.modules.tools.lsp "(add-hook 'go-mode-hook #'lsp-deferred)"}
      ''}

      ${optionalString cfg.emacs.modules.lang.markdown ''
        ;; Markdown
        (require 'markdown-mode)
        (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
        (add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))

        ;; Hugo integration
        (setq markdown-command "pandoc")
      ''}

      ${optionalString cfg.emacs.modules.lang.web ''
        ;; Web Mode - for HTML templates (Hugo uses Go templates)
        (require 'web-mode)
        (add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
        (add-to-list 'auto-mode-alist '("\\.htm\\'" . web-mode))
        (add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))
        (add-to-list 'auto-mode-alist '("\\.gohtml\\'" . web-mode))

        (setq web-mode-engines-alist
              '(("go" . "\\.gohtml\\'")))

        (setq web-mode-markup-indent-offset 2
              web-mode-css-indent-offset 2
              web-mode-code-indent-offset 2
              web-mode-enable-auto-pairing t
              web-mode-enable-css-colorization t
              web-mode-enable-current-element-highlight t)

        ;; Emmet mode for HTML expansion
        (require 'emmet-mode)
        (add-hook 'web-mode-hook 'emmet-mode)
        (add-hook 'html-mode-hook 'emmet-mode)
        (add-hook 'css-mode-hook 'emmet-mode)
      ''}

      ${optionalString cfg.emacs.modules.lang.yaml ''
        ;; YAML
        (require 'yaml-mode)
        (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
        (add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode))
      ''}

      ${optionalString cfg.emacs.modules.lang.toml ''
        ;; TOML
        (require 'toml-mode)
        (add-to-list 'auto-mode-alist '("\\.toml\\'" . toml-mode))
        ;; Hugo config files
        (add-to-list 'auto-mode-alist '("hugo\\.toml\\'" . toml-mode))
      ''}

      ${optionalString cfg.emacs.modules.lang.org ''
        ;; Org Mode
        (require 'org)
        (setq org-startup-indented t
              org-hide-emphasis-markers t
              org-startup-with-inline-images t
              org-image-actual-width '(300))

        (require 'org-bullets)
        (add-hook 'org-mode-hook 'org-bullets-mode)
      ''}

      ;;; init.el ends here
    '';
  };
}
