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
    enable = mkEnableOption "GNU Emacs configuration with Elpaca";

    package = mkOption {
      type = types.package;
      default = pkgs.emacs;
      description = "Emacs package to use";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Extra packages to install alongside Emacs";
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
          default = "JetBrains Mono";
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
    home.packages = let
      basePackages = with pkgs; [
        # Emacs
        cfg.package

        # Tools that Emacs packages need
        (ripgrep.override {withPCRE2 = true;})
        fd
        imagemagick
        zstd
      ];

      lspPackages = lib.optionals cfg.emacs.modules.tools.lsp (
        lib.optional cfg.emacs.modules.lang.nix pkgs.nil
        ++ lib.optional cfg.emacs.modules.lang.python pkgs.python3Packages.python-lsp-server
        ++ lib.optional cfg.emacs.modules.lang.rust pkgs.rust-analyzer
        ++ lib.optional cfg.emacs.modules.lang.typescript pkgs.nodePackages.typescript-language-server
        ++ lib.optional cfg.emacs.modules.lang.go pkgs.gopls
      );

      additionalPackages =
        lib.optional cfg.emacs.modules.tools.editorconfig pkgs.editorconfig-core-c
        ++ lib.optional cfg.emacs.modules.lang.markdown pkgs.pandoc;
    in
      basePackages ++ lspPackages ++ additionalPackages ++ cfg.extraPackages;

    home.file.".emacs.d/early-init.el".text = ''
      ;;; early-init.el --- Early Init File -*- lexical-binding: t -*-

      ;; Optimize startup
      (setq gc-cons-threshold most-positive-fixnum
            gc-cons-percentage 0.6)

      ;; Disable package.el in favor of Elpaca
      (setq package-enable-at-startup nil)

      ;; Native compilation settings
      (when (featurep 'native-compile)
        (setq native-comp-async-report-warnings-errors nil
              native-comp-deferred-compilation t))

      ;; UI optimizations
      (setq frame-inhibit-implied-resize t
            frame-resize-pixelwise t)

      (push '(menu-bar-lines . 0) default-frame-alist)
      (push '(tool-bar-lines . 0) default-frame-alist)
      (push '(vertical-scroll-bars) default-frame-alist)

      ;; Prevent unwanted runtime builds
      (setq load-prefer-newer t)
    '';

    home.file.".emacs.d/init.el".text = ''
      ;;; init.el --- GNU Emacs Init File -*- lexical-binding: t -*-

      ;;; Elpaca Bootstrap
      (defvar elpaca-installer-version 0.7)
      (defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
      (defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
      (defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
      (defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                                    :ref nil :depth 1
                                    :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                                    :build (:not elpaca--activate-package)))
      (let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
             (build (expand-file-name "elpaca/" elpaca-builds-directory))
             (order (cdr elpaca-order))
             (default-directory repo))
        (add-to-list 'load-path (if (file-exists-p build) build repo))
        (unless (file-exists-p repo)
          (make-directory repo t)
          (when (< emacs-major-version 28) (require 'subr-x))
          (condition-case-unless-debug err
              (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                       ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                       ,@(when-let ((depth (plist-get order :depth)))
                                                           (list (format "--depth=%d" depth) "--no-single-branch"))
                                                       ,(plist-get order :repo) ,repo))))
                       ((zerop (call-process "git" nil buffer t "checkout"
                                             (or (plist-get order :ref) "--"))))
                       (emacs (concat invocation-directory invocation-name))
                       ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                             "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                       ((require 'elpaca))
                       ((elpaca-generate-autoloads "elpaca" repo)))
                  (progn (message "%s" (buffer-string)) (kill-buffer buffer))
                (error "%s" (with-current-buffer buffer (buffer-string))))
            ((error) (warn "%s" err) (delete-directory repo 'recursive))))
        (unless (require 'elpaca-autoloads nil t)
          (require 'elpaca)
          (elpaca-generate-autoloads "elpaca" repo)
          (load "./elpaca-autoloads")))
      (add-hook 'after-init-hook #'elpaca-process-queues)
      (elpaca `(,@elpaca-order))

      ;; Install use-package support
      (elpaca elpaca-use-package
        (elpaca-use-package-mode))

      ;; Block until current queue processed
      (elpaca-wait)

      ;;; Core Configuration

      ;; Better defaults
      (setq-default
       ;; Performance
       read-process-output-max (* 1024 1024)

       ;; Editor behavior
       indent-tabs-mode nil
       tab-width 4
       fill-column 80
       require-final-newline t

       ;; Better scrolling
       scroll-margin 0
       scroll-conservatively 101
       scroll-preserve-screen-position t

       ;; Disable annoying features
       ring-bell-function 'ignore
       inhibit-startup-screen t
       initial-scratch-message nil)

      ;; UTF-8 everywhere
      (set-default-coding-systems 'utf-8)
      (prefer-coding-system 'utf-8)

      ;; Better window management
      (setq split-width-threshold 160
            split-height-threshold nil)

      ;; Custom file
      (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
      (when (file-exists-p custom-file)
        (load custom-file))

      ;; Backup files
      (setq backup-directory-alist `(("." . ,(expand-file-name "backup" user-emacs-directory)))
            backup-by-copying t
            version-control t
            delete-old-versions t
            kept-new-versions 6
            kept-old-versions 2)

      ;; Auto-save
      (setq auto-save-default t
            auto-save-timeout 30
            auto-save-interval 200
            auto-save-file-name-transforms
            `((".*" ,(expand-file-name "auto-save/" user-emacs-directory) t)))

      ;;; UI Configuration

      ;; Font
      (set-face-attribute 'default nil
                          :family "${cfg.emacs.ui.font}"
                          :height (* ${toString cfg.emacs.ui.fontSize} 10))

      ;; Display line numbers
      (global-display-line-numbers-mode 1)
      (setq display-line-numbers-type 'relative)

      ;; Highlight current line
      (global-hl-line-mode 1)

      ;; Show matching parens
      (show-paren-mode 1)
      (setq show-paren-delay 0)

      ;; Catppuccin Theme
      (use-package catppuccin-theme
        :ensure t
        :config
        (setq catppuccin-flavor '${replaceStrings ["catppuccin-"] [""] cfg.emacs.ui.theme})
        (load-theme 'catppuccin :no-confirm))

      ${optionalString cfg.emacs.modules.ui.modeline ''
        ;; Doom Modeline
        (use-package doom-modeline
          :ensure t
          :init (doom-modeline-mode 1)
          :config
          (setq doom-modeline-height 25
                doom-modeline-bar-width 3
                doom-modeline-buffer-file-name-style 'truncate-upto-project
                doom-modeline-icon t
                doom-modeline-major-mode-icon t
                doom-modeline-major-mode-color-icon t))

        (use-package nerd-icons
          :ensure t)
      ''}

      ${optionalString cfg.emacs.modules.ui.which-key ''
        ;; Which Key
        (use-package which-key
          :ensure t
          :init (which-key-mode)
          :config
          (setq which-key-idle-delay 0.3))
      ''}

      ${optionalString cfg.emacs.modules.ui.indent-guides ''
        ;; Indent Guides
        (use-package highlight-indent-guides
          :ensure t
          :hook (prog-mode . highlight-indent-guides-mode)
          :config
          (setq highlight-indent-guides-method 'character))
      ''}

      ${optionalString cfg.emacs.modules.ui.hl-todo ''
        ;; Highlight TODOs
        (use-package hl-todo
          :ensure t
          :hook (prog-mode . hl-todo-mode))
      ''}

      ${optionalString cfg.emacs.modules.ui.treemacs ''
        ;; Treemacs
        (use-package treemacs
          :ensure t
          :bind ("C-c t" . treemacs))

        (use-package treemacs-evil
          :ensure t
          :after (treemacs evil))

        (use-package treemacs-magit
          :ensure t
          :after (treemacs magit))
      ''}

      ;;; Completion

      ${optionalString cfg.emacs.modules.completion.vertico ''
        ;; Vertico
        (use-package vertico
          :ensure t
          :init (vertico-mode)
          :config
          (setq vertico-cycle t))

        ;; Orderless
        (use-package orderless
          :ensure t
          :custom
          (completion-styles '(orderless basic))
          (completion-category-overrides '((file (styles basic partial-completion)))))

        ;; Marginalia
        (use-package marginalia
          :ensure t
          :init (marginalia-mode))

        ;; Consult
        (use-package consult
          :ensure t
          :bind (("C-s" . consult-line)
                 ("C-x b" . consult-buffer)
                 ("C-x 4 b" . consult-buffer-other-window)
                 ("M-y" . consult-yank-pop)
                 ("M-g g" . consult-goto-line)
                 ("M-g M-g" . consult-goto-line)))
      ''}

      ${optionalString cfg.emacs.modules.completion.corfu ''
        ;; Corfu
        (use-package corfu
          :ensure t
          :init (global-corfu-mode)
          :config
          (setq corfu-auto t
                corfu-quit-no-match 'separator))

        ;; Cape (completion-at-point extensions)
        (use-package cape
          :ensure t
          :init
          (add-to-list 'completion-at-point-functions #'cape-dabbrev)
          (add-to-list 'completion-at-point-functions #'cape-file))
      ''}

      ;;; Editor

      ${optionalString cfg.emacs.modules.editor.evil ''
        ;; Evil
        (use-package evil
          :ensure t
          :init
          (setq evil-want-integration t
                evil-want-keybinding nil
                evil-want-C-u-scroll t
                evil-want-C-d-scroll t
                evil-undo-system 'undo-redo)
          :config
          (evil-mode 1))

        (use-package evil-collection
          :ensure t
          :after evil
          :config
          (evil-collection-init))

        (use-package evil-surround
          :ensure t
          :config
          (global-evil-surround-mode 1))

        (use-package evil-commentary
          :ensure t
          :config
          (evil-commentary-mode))
      ''}

      ${optionalString cfg.emacs.modules.editor.multiple-cursors ''
        ;; Multiple Cursors
        (use-package evil-multiedit
          :ensure t
          :after evil
          :config
          (evil-multiedit-default-keybinds))
      ''}

      ${optionalString cfg.emacs.modules.editor.snippets ''
        ;; Yasnippet
        (use-package yasnippet
          :ensure t
          :config
          (yas-global-mode 1))

        (use-package yasnippet-snippets
          :ensure t
          :after yasnippet)
      ''}

      ;;; Tools

      ${optionalString cfg.emacs.modules.tools.magit ''
        ;; Magit - force latest from main branch
        (use-package magit
          :ensure (:host github :repo "magit/magit" :branch "main")
          :bind ("C-x g" . magit-status))
      ''}

      ${optionalString cfg.emacs.modules.tools.lsp ''
        ;; LSP Mode
        (use-package lsp-mode
          :ensure t
          :commands (lsp lsp-deferred)
          :init
          (setq lsp-keymap-prefix "C-c l")
          :config
          (setq lsp-idle-delay 0.5
                lsp-enable-file-watchers nil
                lsp-signature-auto-activate nil))

        (use-package lsp-ui
          :ensure t
          :commands lsp-ui-mode
          :config
          (setq lsp-ui-doc-enable t
                lsp-ui-doc-position 'at-point
                lsp-ui-sideline-enable t))
      ''}

      ${optionalString cfg.emacs.modules.tools.tree-sitter ''
        ;; Tree-sitter
        (use-package tree-sitter
          :ensure t
          :config
          (global-tree-sitter-mode))

        (use-package tree-sitter-langs
          :ensure t
          :after tree-sitter)
      ''}

      ${optionalString cfg.emacs.modules.tools.direnv ''
        ;; Direnv
        (use-package envrc
          :ensure t
          :config
          (envrc-global-mode))
      ''}

      ${optionalString cfg.emacs.modules.tools.editorconfig ''
        ;; EditorConfig
        (use-package editorconfig
          :ensure t
          :config
          (editorconfig-mode 1))
      ''}

      ;;; Languages

      ${optionalString cfg.emacs.modules.lang.nix ''
        ;; Nix
        (use-package nix-mode
          :ensure t
          :mode "\\.nix\\'"
          :hook (nix-mode . lsp-deferred))
      ''}

      ${optionalString cfg.emacs.modules.lang.python ''
        ;; Python
        (use-package python-mode
          :ensure t
          :hook (python-mode . lsp-deferred))
      ''}

      ${optionalString cfg.emacs.modules.lang.rust ''
        ;; Rust
        (use-package rust-mode
          :ensure t
          :hook (rust-mode . lsp-deferred))
      ''}

      ${optionalString cfg.emacs.modules.lang.javascript ''
        ;; JavaScript
        (use-package js2-mode
          :ensure t
          :mode "\\.js\\'"
          :hook (js2-mode . lsp-deferred))
      ''}

      ${optionalString cfg.emacs.modules.lang.typescript ''
        ;; TypeScript
        (use-package typescript-mode
          :ensure t
          :mode "\\.ts\\'"
          :hook (typescript-mode . lsp-deferred))
      ''}

      ${optionalString cfg.emacs.modules.lang.go ''
        ;; Go
        (use-package go-mode
          :ensure t
          :hook (go-mode . lsp-deferred))
      ''}

      ${optionalString cfg.emacs.modules.lang.markdown ''
        ;; Markdown
        (use-package markdown-mode
          :ensure t
          :mode "\\.md\\'")
      ''}

      ${optionalString cfg.emacs.modules.lang.org ''
        ;; Org Mode
        (use-package org
          :ensure t
          :config
          (setq org-startup-indented t
                org-hide-emphasis-markers t
                org-startup-with-inline-images t
                org-image-actual-width '(300)))

        (use-package org-bullets
          :ensure t
          :hook (org-mode . org-bullets-mode))
      ''}

      ;; Restore GC settings
      (add-hook 'emacs-startup-hook
                (lambda ()
                  (setq gc-cons-threshold 16777216
                        gc-cons-percentage 0.1)))

      ;;; init.el ends here
    '';

    # Load custom config if it exists
    home.file.".emacs.d/config.el".text = ''
      ;;; config.el --- User Configuration -*- lexical-binding: t -*-

      ;; Add your custom configuration here
      ;; This file is loaded after init.el

      ;;; config.el ends here
    '';
  };
}
