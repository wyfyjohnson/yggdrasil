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
          treemacs = mkEnableOption "Treemacs file explorer" // {default = true;};
          which-key = mkEnableOption "Which-key" // {default = true;};
        };

        editor = {
          evil = mkEnableOption "Evil mode" // {default = true;};
          multiple-cursors = mkEnableOption "Multiple cursors" // {default = true;};
          snippets = mkEnableOption "Yasnippet" // {default = true;};
        };

        tools = {
          direnv = mkEnableOption "Direnv integration" // {default = true;};
          editorconfig = mkEnableOption "EditorConfig" // {default = true;};
          magit = mkEnableOption "Magit" // {default = true;};
          lsp = mkEnableOption "LSP mode" // {default = true;};
        };

        lang = {
          nix = mkEnableOption "Nix support" // {default = true;};
          python = mkEnableOption "Python support" // {default = true;};
          rust = mkEnableOption "Rust support" // {default = false;};
          markdown = mkEnableOption "Markdown support" // {default = true;};
          org = mkEnableOption "Org mode enhancements" // {default = true;};
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
          ]
          ++ optional cfg.emacs.modules.ui.modeline doom-modeline
          ++ optional cfg.emacs.modules.ui.modeline nerd-icons
          ++ optional cfg.emacs.modules.ui.which-key which-key
          ++ optional cfg.emacs.modules.ui.hl-todo hl-todo
          ++ optional cfg.emacs.modules.ui.indent-guides highlight-indent-guides
          ++ optional cfg.emacs.modules.ui.treemacs treemacs
          ++ optionals (cfg.emacs.modules.ui.treemacs && cfg.emacs.modules.editor.evil) [treemacs-evil]
          ++ optionals (cfg.emacs.modules.ui.treemacs && cfg.emacs.modules.tools.magit) [treemacs-magit]
          # Completion
          ++ optionals cfg.emacs.modules.completion.vertico [vertico orderless marginalia consult]
          ++ optionals cfg.emacs.modules.completion.corfu [corfu cape]
          # Editor
          ++ optionals cfg.emacs.modules.editor.evil [evil evil-collection evil-surround evil-commentary]
          ++ optional cfg.emacs.modules.editor.multiple-cursors evil-multiedit
          ++ optionals cfg.emacs.modules.editor.snippets [yasnippet yasnippet-snippets]
          # Tools
          ++ optional cfg.emacs.modules.tools.magit magit
          ++ optional cfg.emacs.modules.tools.direnv envrc
          ++ optional cfg.emacs.modules.tools.editorconfig editorconfig
          ++ optionals cfg.emacs.modules.tools.lsp [lsp-mode lsp-ui]
          # Languages
          ++ optional cfg.emacs.modules.lang.nix nix-mode
          ++ optional cfg.emacs.modules.lang.python python-mode
          ++ optional cfg.emacs.modules.lang.rust rust-mode
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
      )
      ++ optional cfg.emacs.modules.tools.editorconfig editorconfig-core-c
      ++ optional cfg.emacs.modules.lang.markdown pandoc;

    # Emacs configuration file
    home.file.".emacs.d/init.el".text = ''
      ;;; init.el --- Emacs Configuration -*- lexical-binding: t -*-

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

      ;;; Editor

      ${optionalString cfg.emacs.modules.editor.evil ''
        ;; Evil
        (require 'evil)
        (setq evil-want-integration t
              evil-want-keybinding nil
              evil-want-C-u-scroll t
              evil-want-C-d-scroll t
              evil-undo-system 'undo-redo)
        (evil-mode 1)

        (require 'evil-collection)
        (evil-collection-init)

        (require 'evil-surround)
        (global-evil-surround-mode 1)

        (require 'evil-commentary)
        (evil-commentary-mode)
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
