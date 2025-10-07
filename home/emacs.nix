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
          ++ optionals cfg.emacs.modules.lang.org [org-bullets];
    };

    # System packages for Emacs
    home.packages = with pkgs;
      [
        # Tools that Emacs needs
        (ripgrep.override {withPCRE2 = true;})
        fd

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
       scroll-margin 0
       scroll-conservatively 101
       scroll-preserve-screen-position t
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

      ;; Backup and auto-save
      (setq backup-directory-alist `(("." . ,(expand-file-name "backup" user-emacs-directory)))
            backup-by-copying t
            version-control t
            delete-old-versions t
            kept-new-versions 6
            kept-old-versions 2
            auto-save-default t
            auto-save-timeout 30
            auto-save-interval 200
            auto-save-file-name-transforms
            `((".*" ,(expand-file-name "auto-save/" user-emacs-directory) t)))

      ;; Custom file
      (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
      (when (file-exists-p custom-file)
        (load custom-file))

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

      ;; Theme
      (require 'catppuccin-theme)
      (setq catppuccin-flavor '${replaceStrings ["catppuccin-"] [""] cfg.emacs.ui.theme})
      (load-theme 'catppuccin t)

      ;;; Dashboard (Doom-style splash screen)
      (require 'dashboard)
      (dashboard-setup-startup-hook)

      ;; Dashboard configuration
      (setq dashboard-banner-logo-title "Y G G D R A S I L")
      (setq dashboard-startup-banner 'logo)
      (setq dashboard-center-content t)
      (setq dashboard-show-shortcuts nil)
      (setq dashboard-set-navigator t)
      (setq dashboard-set-heading-icons t)
      (setq dashboard-set-file-icons t)

      (setq dashboard-items '((recents  . 5)
                              (projects . 5)
                              (bookmarks . 5)))

      ;; Custom footer
      (setq dashboard-footer-messages
            '("Wyfy's Cross-Platform Nix Configuration"
              "Powered by Nix + Home Manager + Emacs"))
      (setq dashboard-footer-icon
            (nerd-icons-mdicon "nf-md-tree"
                               :height 1.1
                               :v-adjust -0.05
                               :face 'font-lock-keyword-face))

      ;; Navigator configuration
      (setq dashboard-navigator-buttons
            `(((,(nerd-icons-mdicon "nf-md-github" :height 1.1 :v-adjust 0.0)
                "GitHub"
                "Browse GitHub"
                (lambda (&rest _) (browse-url "https://github.com")))
               (,(nerd-icons-mdicon "nf-md-cog" :height 1.1 :v-adjust 0.0)
                "Settings"
                "Open settings"
                (lambda (&rest _) (find-file user-init-file)))
               (,(nerd-icons-mdicon "nf-md-refresh" :height 1.1 :v-adjust 0.0)
                "Reload"
                "Reload configuration"
                (lambda (&rest _) (load-file user-init-file))))))

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

      ${optionalString cfg.emacs.modules.ui.indent-guides ''
        ;; Indent Guides
        (require 'highlight-indent-guides)
        (add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
        (setq highlight-indent-guides-method 'character)
      ''}

      ${optionalString cfg.emacs.modules.ui.hl-todo ''
        ;; Highlight TODOs
        (require 'hl-todo)
        (global-hl-todo-mode)
      ''}

      ${optionalString cfg.emacs.modules.ui.treemacs ''
        ;; Treemacs
        (require 'treemacs)
        (global-set-key (kbd "C-c t") 'treemacs)
        ${optionalString cfg.emacs.modules.editor.evil "(require 'treemacs-evil)"}
        ${optionalString cfg.emacs.modules.tools.magit "(require 'treemacs-magit)"}
      ''}

      ;;; Completion

      ${optionalString cfg.emacs.modules.completion.vertico ''
        ;; Vertico
        (require 'vertico)
        (vertico-mode)
        (setq vertico-cycle t)

        ;; Orderless
        (require 'orderless)
        (setq completion-styles '(orderless basic)
              completion-category-overrides '((file (styles basic partial-completion))))

        ;; Marginalia
        (require 'marginalia)
        (marginalia-mode)

        ;; Consult
        (require 'consult)
        (global-set-key (kbd "C-s") 'consult-line)
        (global-set-key (kbd "C-x b") 'consult-buffer)
        (global-set-key (kbd "M-y") 'consult-yank-pop)
        (global-set-key (kbd "M-g g") 'consult-goto-line)
      ''}

      ${optionalString cfg.emacs.modules.completion.corfu ''
        ;; Corfu
        (require 'corfu)
        (global-corfu-mode)
        (setq corfu-auto t
              corfu-quit-no-match 'separator)

        ;; Cape
        (require 'cape)
        (add-to-list 'completion-at-point-functions #'cape-dabbrev)
        (add-to-list 'completion-at-point-functions #'cape-file)
      ''}

      ;;; Editor - Evil Mode with Full Vim Keybindings

      ${optionalString cfg.emacs.modules.editor.evil ''
        ;; Evil Mode - Core Configuration
        (require 'evil)
        (setq evil-want-integration t
              evil-want-keybinding nil
              evil-want-C-u-scroll t
              evil-want-C-d-scroll t
              evil-want-C-i-jump nil
              evil-respect-visual-line-mode t
              evil-undo-system 'undo-redo
              evil-search-module 'evil-search
              evil-ex-complete-emacs-commands nil
              evil-vsplit-window-right t
              evil-split-window-below t
              evil-shift-round nil
              evil-want-C-w-in-emacs-state nil)

        ${optionalString cfg.emacs.modules.base.undo ''
          ;; Undo Tree
          (require 'undo-tree)
          (global-undo-tree-mode)
          (setq evil-undo-system 'undo-tree)
        ''}

        (evil-mode 1)

        ;; Evil Collection - Vim keybindings everywhere
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

        ;; Toggle operations
        (evil-define-key 'normal 'global (kbd "<leader>tn") 'display-line-numbers-mode)
        (evil-define-key 'normal 'global (kbd "<leader>tr") 'read-only-mode)
        (evil-define-key 'normal 'global (kbd "<leader>tw") 'whitespace-mode)

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
