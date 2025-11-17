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
        };

        fontSize = mkOption {
          type = types.int;
          default = 14;
        };

        font = mkOption {
          type = types.str;
          default = "Maple Mono NF";
        };

        transparency = mkOption {
          type = types.int;
          default = 85;
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

        editor.meow = mkEnableOption "Meow modal editing (Helix-style)" // {default = true;};
        editor.file-templates = mkEnableOption "File templates" // {default = true;};
        editor.fold = mkEnableOption "Code folding" // {default = true;};
        editor.multiple-cursors = mkEnableOption "Multiple cursors" // {default = true;};
        editor.snippets = mkEnableOption "Yasnippet" // {default = true;};

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
          emms = mkEnableOption "EMMS (music player)" // {default = true;};
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
            dashboard
            nerd-icons
          ]
          ++ optional cfg.emacs.modules.ui.modeline doom-modeline
          ++ optional cfg.emacs.modules.ui.which-key which-key
          ++ optional cfg.emacs.modules.ui.hl-todo hl-todo
          ++ optional cfg.emacs.modules.ui.indent-guides highlight-indent-guides
          ++ optional cfg.emacs.modules.ui.treemacs treemacs
          ++ optionals (cfg.emacs.modules.ui.treemacs && cfg.emacs.modules.tools.magit) [treemacs-magit]
          # Completion
          ++ optionals cfg.emacs.modules.completion.vertico [vertico orderless marginalia consult]
          ++ optionals cfg.emacs.modules.completion.corfu [corfu cape]
          # Editor - Meow (Helix-style modal editing)
          ++ optional cfg.emacs.modules.editor.meow meow
          ++ optional cfg.emacs.modules.editor.meow avy
          ++ optional cfg.emacs.modules.editor.meow evil # Just for evil-ex commands
          ++ optional cfg.emacs.modules.editor.multiple-cursors multiple-cursors
          ++ optionals cfg.emacs.modules.editor.snippets [yasnippet yasnippet-snippets]
          ++ optional cfg.emacs.modules.base.undo undo-tree
          # Tools
          ++ optional cfg.emacs.modules.tools.magit magit
          ++ optional cfg.emacs.modules.tools.direnv envrc
          ++ optional cfg.emacs.modules.tools.editorconfig editorconfig
          ++ optionals cfg.emacs.modules.tools.lsp [lsp-mode lsp-ui]
          ++ optionals cfg.emacs.modules.tools.tree-sitter [tree-sitter tree-sitter-langs]
          ++ optional cfg.emacs.modules.tools.emms emms
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
        ++ [pkgs.hyprls]
        ++ optional cfg.emacs.modules.lang.python python3Packages.python-lsp-server
        ++ optional cfg.emacs.modules.lang.rust rust-analyzer
        ++ optional cfg.emacs.modules.lang.typescript nodePackages.typescript-language-server
        ++ optional cfg.emacs.modules.lang.go gopls
        ++ optional cfg.emacs.modules.lang.javascript nodePackages.typescript-language-server
      )
      ++ optional cfg.emacs.modules.tools.editorconfig editorconfig-core-c
      ++ optional cfg.emacs.modules.lang.markdown pandoc
      ++ optional cfg.emacs.modules.tools.emms mpv
      ++ cfg.extraPackages;

    # Emacs configuration file
    home.file.".emacs.d/init.el".text = ''
      ;;; init.el --- Yggdrasil Emacs Configuration -*- lexical-binding: t -*-

      ;;; Startup optimization
      (setq gc-cons-threshold most-positive-fixnum)
      (add-hook 'emacs-startup-hook
                (lambda ()
                  (setq gc-cons-threshold (* 16 1024 1024))))
      (setq native-comp-deferred-compilation nil)
      (setq-default cursor-in-non-selected-windows nil)
      (setq highlight-nonselected-windows nil)
      (setq-default bidi-display-reordering 'left-to-right
                    bidi-paragraph-direction 'left-to-right)

      ;;; Better defaults
      (setq-default
       indent-tabs-mode nil
       tab-width 4
       fill-column 80
       require-final-newline t
       scroll-margin 8
       scroll-step 1
       scroll-conservatively 10000
       scroll-preserve-screen-position t
       auto-window-vscroll nil
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
                          :height (* ${toString cfg.emacs.ui.fontSize} 12))

      ;; Line numbers
      (global-display-line-numbers-mode 1)
      (setq display-line-numbers-type 'relative)

      ;; Make line numbers more visible
      (set-face-attribute 'line-number nil
                          :foreground "#6c7086"  ;; Lighter gray for line numbers
                          :background nil)
      (set-face-attribute 'line-number-current-line nil
                          :foreground "#cdd6f4"  ;; Bright for current line
                          :background nil
                          :weight 'bold)

      ;; Highlight current line
      (global-hl-line-mode 1)

      ;; Electric Pair Mode - Auto-close brackets, quotes, parens (like Helix)
      (electric-pair-mode 1)
      (setq electric-pair-preserve-balance t
            electric-pair-delete-adjacent-pairs t
            electric-pair-open-newline-between-pairs t)

      ;; Show matching parentheses
      (show-paren-mode 1)
      (setq show-paren-delay 0
            show-paren-style 'mixed)

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

      ${optionalString cfg.emacs.modules.ui.indent-guides ''
        ;; Indent Guides - vertical lines showing indentation (like Helix)
        (require 'highlight-indent-guides)
        (add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
        (setq highlight-indent-guides-method 'character
              highlight-indent-guides-responsive 'stack
              highlight-indent-guides-character ?\┊
              highlight-indent-guides-auto-enabled t)

        ;; Make indent guides use theme colors dynamically
        (defun my/set-indent-guide-colors ()
          "Set indent guide colors based on current Catppuccin theme."
          (let ((surface1 (face-attribute 'font-lock-comment-face :foreground))
                (surface2 (face-attribute 'shadow :foreground))
                (blue (face-attribute 'font-lock-function-name-face :foreground)))
            (set-face-foreground 'highlight-indent-guides-character-face surface2)
            (set-face-foreground 'highlight-indent-guides-stack-character-face surface1)
            (set-face-foreground 'highlight-indent-guides-top-character-face blue)))

        ;; Apply colors after theme loads
        (add-hook 'after-init-hook 'my/set-indent-guide-colors)

        ;; Reapply when theme changes
        (advice-add 'load-theme :after
                    (lambda (&rest _) (my/set-indent-guide-colors)))
      ''}

      ${optionalString cfg.emacs.modules.ui.hl-todo ''
        ;; Highlight TODOs, FIXMEs, NOTEs in comments
        (require 'hl-todo)
        (global-hl-todo-mode)
        (setq hl-todo-keyword-faces
              '(("TODO"   . "#FF6C6B")
                ("FIXME"  . "#FF6C6B")
                ("HACK"   . "#ECBE7B")
                ("NOTE"   . "#51AFEF")
                ("DONE"   . "#98BE65")))
      ''}

      ${optionalString cfg.emacs.modules.ui.treemacs ''
        ;; Treemacs - file explorer sidebar
        (require 'treemacs)
        (setq treemacs-width 30
              treemacs-follow-mode t
              treemacs-filewatch-mode t
              treemacs-fringe-indicator-mode 'always)

        ;; Toggle treemacs with C-c t
        (global-set-key (kbd "C-c t") 'treemacs)
      ''}

      ;;; Dashboard
      (require 'dashboard)

      ;; Dashboard configuration
      (setq dashboard-banner-logo-title "Y G G D R A S I L"
            dashboard-startup-banner "~/Pictures/large.png"
            dashboard-center-content t
            dashboard-show-shortcuts t
            dashboard-set-heading-icons nil
            dashboard-set-file-icons nil
            dashboard-items '((recents  . 10)
                              (bookmarks . 5)
                              (projects . 5)
                              (agenda . 10))
            dashboard-footer-messages
            '("Powered by Nix + Home Manager + Emacs")
            dashboard-footer-icon ""
            dashboard-projects-backend 'project-el
            dashboard-week-agenda t
            dashboard-filter-agenda-entry 'dashboard-no-filter-agenda
            dashboard-item-shortcuts '((recents . "r")
                                       (bookmarks . "m")
                                       (projects . "p")
                                       (agenda . "a")))

      ;; Setup dashboard
      (dashboard-setup-startup-hook)

      ;; Custom function to open nth recent file
      (defun dashboard-jump-to-recent-file (n)
        "Open the Nth recent file (1-indexed)."
        (interactive)
        (let ((file (nth (1- n) recentf-list)))
          (if file
              (find-file file)
            (message "No recent file at position %d" n))))

      ;; Custom function to jump to nth bookmark
      (defun dashboard-jump-to-bookmark (n)
        "Jump to the Nth bookmark (1-indexed)."
        (interactive)
        (let ((bm (nth (1- n) (bookmark-all-names))))
          (if bm
              (bookmark-jump bm)
            (message "No bookmark at position %d" n))))

      ;; Custom function to jump to nth project
      (defun dashboard-jump-to-project (n)
        "Switch to the Nth project (1-indexed)."
        (interactive)
        (when (fboundp 'projectile-relevant-known-projects)
          (let ((proj (nth (1- n) (projectile-relevant-known-projects))))
            (if proj
                (projectile-switch-project-by-name proj)
              (message "No project at position %d" n)))))

      ;; Add numbered shortcuts after dashboard is loaded
      (add-hook 'dashboard-mode-hook
                (lambda ()
                  ;; Override the default r/m/p/a keys to create a prefix map
                  (define-prefix-command 'dashboard-recents-map)
                  (define-prefix-command 'dashboard-bookmarks-map)
                  (define-prefix-command 'dashboard-projects-map)

                  ;; Bind r/m/p as prefixes
                  (define-key dashboard-mode-map (kbd "r") 'dashboard-recents-map)
                  (define-key dashboard-mode-map (kbd "m") 'dashboard-bookmarks-map)
                  (define-key dashboard-mode-map (kbd "p") 'dashboard-projects-map)

                  ;; Bind numbers under each prefix
                  (dotimes (i 10)
                    (let ((key (number-to-string (mod (1+ i) 10)))
                          (n (1+ i)))
                      ;; r 1-0 for recent files
                      (define-key dashboard-recents-map (kbd key)
                        `(lambda () (interactive) (dashboard-jump-to-recent-file ,n)))

                      ;; m 1-0 for bookmarks
                      (define-key dashboard-bookmarks-map (kbd key)
                        `(lambda () (interactive) (dashboard-jump-to-bookmark ,n)))

                      ;; p 1-0 for projects
                      (define-key dashboard-projects-map (kbd key)
                        `(lambda () (interactive) (dashboard-jump-to-project ,n)))))))

      ;; Create and show dashboard
      (defun my/create-dashboard ()
        "Create and display the dashboard."
        (interactive)
        (with-current-buffer (get-buffer-create "*dashboard*")
          (dashboard-mode)
          (dashboard-insert-startupify-lists)
          (dashboard-refresh-buffer))
        (switch-to-buffer "*dashboard*"))

      ;; For regular emacs startup
      (setq initial-buffer-choice 'my/create-dashboard)

      ;; For emacsclient - create dashboard when new frame is made
      (add-hook 'server-after-make-frame-hook
                (lambda ()
                  (with-selected-frame (selected-frame)
                    (my/create-dashboard))))

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
        ;; Which Key - Shows keybinding popup (like Helix)
        (require 'which-key)
        (which-key-mode)
        (setq which-key-idle-delay 0.3
              which-key-popup-type 'side-window
              which-key-side-window-location 'bottom
              which-key-side-window-max-height 0.5
              which-key-separator " → "
              which-key-prefix-prefix "+"
              which-key-show-docstrings t
              which-key-max-description-length 40)
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

      ;;; Editor - Meow Modal Editing (Helix-style)

      ${optionalString cfg.emacs.modules.editor.meow ''
        ;; Meow - Modal editing with Helix/Kakoune-style keybindings
        (require 'meow)

        ;; Ensure insert mode allows normal typing - disable conflicting bindings
        (defun my/ensure-insert-mode-typing ()
          "Ensure all keys work normally in insert mode."
          ;; Make sure no keys are bound in insert state that would interfere with typing
          (when (boundp 'meow-insert-state-keymap)
            (setq meow-insert-state-keymap (make-sparse-keymap))))

        ;; Meow setup function
        (defun meow-setup ()
          (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)

          ;; Motion state keys (when not in normal mode)
          (meow-motion-overwrite-define-key
           '("j" . meow-next)
           '("k" . meow-prev)
           '("<escape>" . ignore))

          ;; LEADER KEY with which-key integration (SPC in normal mode)
          (meow-leader-define-key
           ;; Command palette
           '("SPC" . execute-extended-command)

           ;; Comment operations (SPC c) - like Helix Space+c
           '("cc" . comment-line)
           '("cC" . comment-box)
           '("c SPC" . comment-dwim)

           ;; File operations (SPC f)
           '("ff" . find-file)
           '("fs" . save-buffer)
           '("fr" . consult-recent-file)
           '("fD" . delete-file)

           ;; Buffer operations (SPC b)
           '("bb" . consult-buffer)
           '("bd" . kill-current-buffer)
           '("bn" . next-buffer)
           '("bp" . previous-buffer)
           '("bR" . revert-buffer)

           ;; Window operations (SPC v for "view/viewport")
           '("vv" . split-window-right)
           '("vs" . split-window-below)
           '("vd" . delete-window)
           '("vh" . windmove-left)
           '("vj" . windmove-down)
           '("vk" . windmove-up)
           '("vl" . windmove-right)
           '("v=" . balance-windows)

           ;; Search operations (SPC s)
           '("ss" . consult-line)
           '("sp" . consult-ripgrep)
           '("sb" . consult-buffer)
           '("si" . consult-imenu)

           ;; Jump operations (SPC z)
           '("zz" . avy-goto-char-2)
           '("zl" . avy-goto-line)
           '("zw" . avy-goto-word-1)
           '("zc" . avy-goto-char-timer)

           ;; Toggle operations (SPC T - capital T)
           '("Tn" . display-line-numbers-mode)
           '("Tr" . read-only-mode)
           '("Tw" . whitespace-mode)
           '("Tt" . toggle-transparency)

           ;; Git operations (SPC g) - always define, magit will be available if enabled
           '("gg" . magit-status)
           '("gd" . magit-diff-unstaged)
           '("gc" . magit-commit)
           '("gp" . magit-push)
           '("gl" . magit-log)

           ;; Code operations (SPC l for "language/lsp") - always define, lsp will be available if enabled
           '("la" . lsp-execute-code-action)
           '("lr" . lsp-rename)
           '("lf" . lsp-format-buffer)
           '("ld" . lsp-find-definition)
           '("lD" . lsp-find-declaration)
           '("li" . lsp-find-implementation)
           '("lt" . lsp-find-type-definition)
           '("lR" . lsp-find-references)

           ;; Help/Documentation (SPC H - capital H)
           '("Hf" . describe-function)
           '("Hv" . describe-variable)
           '("Hk" . describe-key)
           '("Hm" . describe-mode)

           ;; Quit (SPC q)
           '("qq" . save-buffers-kill-terminal)
           '("qr" . restart-emacs))

          ;; NORMAL MODE KEYS (Helix-inspired motion and selection)
          (meow-normal-define-key
           ;; Numeric arguments
           '("0" . meow-expand-0)
           '("9" . meow-expand-9)
           '("8" . meow-expand-8)
           '("7" . meow-expand-7)
           '("6" . meow-expand-6)
           '("5" . meow-expand-5)
           '("4" . meow-expand-4)
           '("3" . meow-expand-3)
           '("2" . meow-expand-2)
           '("1" . meow-expand-1)
           '("-" . negative-argument)

           ;; === MOVEMENT (Helix h/j/k/l) ===
           '("h" . meow-left)
           '("j" . meow-next)
           '("k" . meow-prev)
           '("l" . meow-right)

           ;; === SELECTION (Helix-style: select THEN act) ===
           ;; Word/symbol selection
           '("w" . meow-mark-word)           ;; Select word (like Helix 'w')
           '("W" . meow-mark-symbol)         ;; Select WORD (like Helix 'W')
           '("b" . meow-back-word)           ;; Select back word
           '("B" . meow-back-symbol)         ;; Select back WORD
           '("e" . meow-next-word)           ;; Extend to end of word
           '("E" . meow-next-symbol)         ;; Extend to end of WORD

           ;; Line selection
           '("x" . meow-line)                ;; Select line (like Helix 'x')
           '("X" . meow-goto-line)           ;; Go to line (like Helix 'g')

           ;; Extend selection
           '(";" . meow-reverse)             ;; Reverse selection direction
           '("," . meow-inner-of-thing)      ;; Select inner thing
           '("." . meow-bounds-of-thing)     ;; Select bounds of thing

           ;; Paragraph/block
           '("[" . meow-beginning-of-thing)  ;; Go to beginning
           '("]" . meow-end-of-thing)        ;; Go to end

           ;; === ACTIONS (performed on selection) ===
           '("c" . meow-change)              ;; Change selection (like Helix 'c')
           '("d" . meow-kill)                ;; Delete/kill selection (like Helix 'd')
           '("y" . meow-save)                ;; Yank/copy (like Helix 'y')
           '("p" . meow-yank)                ;; Paste after (like Helix 'p')
           '("P" . meow-yank-pop)            ;; Paste from kill ring

           ;; === INSERT MODES (like Helix i/a/o/O) ===
           '("i" . meow-insert)              ;; Insert mode
           '("a" . meow-append)              ;; Append (insert after)
           '("o" . meow-open-below)          ;; Open line below
           '("O" . meow-open-above)          ;; Open line above
           '("I" . meow-insert-at-begin)     ;; Insert at line beginning
           '("A" . meow-append-at-end)       ;; Append at line end

           ;; === FIND/SEARCH (like Helix f/t//) ===
           '("f" . meow-find)                ;; Find char forward
           '("t" . meow-till)                ;; Till char forward
           '("/" . meow-visit)               ;; Search (like Helix '/')
           '("n" . meow-search)              ;; Next match (like Helix 'n')
           '("N" . meow-pop-search)          ;; Previous match (like Helix 'N')

           ;; === UNDO/REDO (like Helix u/U) ===
           '("u" . meow-undo)                ;; Undo
           '("U" . meow-undo-in-selection)   ;; Undo in selection

           ;; === COMMENT TOGGLE (like Helix Ctrl-c) ===
           '("C-c" . comment-line)           ;; Comment/uncomment line or region

           ;; === OTHER USEFUL COMMANDS ===
           '("g" . meow-cancel-selection)    ;; Cancel selection (like Helix ESC)
           '("G" . meow-grab)                ;; Grab/secondary selection
           '("r" . meow-replace)             ;; Replace char (like Helix 'r')
           '("R" . meow-swap-grab)           ;; Swap with grabbed
           '("m" . meow-join)                ;; Join lines (like Helix 'J')
           '("%" . mark-whole-buffer)        ;; Select entire file (like Helix '%')
           '("=" . meow-indent)              ;; Indent selection

           ;; Capital C for multi-cursor - add cursor below (like Helix C)
           '("C" . meow-line-expand)         ;; Expand selection to next line

           ;; Ex-mode commands (like Helix ':')
           '(":" . evil-ex)                  ;; Open command line

           ;; Quit/escape
           '("<escape>" . meow-cancel-selection)
           '("C-g" . meow-cancel-selection)))

        ;; Initialize Meow
        (meow-setup)

        ;; Call our function to ensure insert mode is clean
        (my/ensure-insert-mode-typing)

        ;; Enable Meow globally
        (meow-global-mode 1)

        ;; Configure Meow behavior
        (setq meow-use-clipboard t
              meow-use-cursor-position-hack t
              meow-select-on-change t
              meow-expand-hint-remove-delay 2.0)

        ;; Hook to ensure insert mode stays clean every time we enter it
        (add-hook 'meow-insert-enter-hook 'my/ensure-insert-mode-typing)

        ;; Keep avy for quick jumping (works great with Meow!)
        (require 'avy)
        (setq avy-all-windows t
              avy-background t
              avy-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l ?q ?w ?e ?r ?u ?i ?o ?p))

        ;; Setup evil-ex for ':' commands (like Helix)
        (require 'evil)
        (setq evil-ex-search-vim-style-regexp t
              evil-ex-substitute-global t)

        ;; Common ex commands that work well with Meow
        ;; :w - save file
        ;; :q - quit
        ;; :wq - save and quit
        ;; :e <file> - open file
        ;; :s/find/replace/ - substitute
        ;; :%s/find/replace/g - substitute globally
      ''}

      ${optionalString cfg.emacs.modules.editor.multiple-cursors ''
        ;; Multiple cursors
        (require 'multiple-cursors)
        (global-set-key (kbd "C->") 'mc/mark-next-like-this)
        (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
        (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
      ''}

      ${optionalString cfg.emacs.modules.editor.snippets ''
        ;; Yasnippet
        (require 'yasnippet)
        (yas-global-mode 1)
      ''}

      ${optionalString cfg.emacs.modules.base.undo ''
        ;; Undo Tree
        (require 'undo-tree)
        (global-undo-tree-mode)
        (setq undo-tree-auto-save-history t
              undo-tree-history-directory-alist
              `(("." . ,(expand-file-name "tempDir/undo-tree/" user-emacs-directory))))
        ;; Create undo-tree directory if it doesn't exist
        (unless (file-exists-p (expand-file-name "tempDir/undo-tree/" user-emacs-directory))
          (make-directory (expand-file-name "tempDir/undo-tree/" user-emacs-directory) t))
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
              lsp-signature-auto-activate nil
              ;; CRITICAL: Disable all default LSP keybindings that interfere with insert mode
              lsp-enable-which-key-integration nil
              lsp-modeline-code-actions-enable nil
              lsp-modeline-diagnostics-enable nil
              lsp-signature-render-documentation nil
              lsp-eldoc-enable-hover nil)

        ;; Explicitly unbind ALL problematic keys that interfere with normal typing
        (with-eval-after-load 'lsp-mode
          ;; Completely suppress all automatic keybindings from lsp-mode-map
          (suppress-keymap lsp-mode-map t)
          ;; Only use LSP features through explicit prefix (C-c l)
          (define-key lsp-mode-map lsp-keymap-prefix lsp-command-map))

        (require 'lsp-ui)
        (setq lsp-ui-doc-enable t
              lsp-ui-doc-position 'at-point
              lsp-ui-sideline-enable t
              lsp-ui-sideline-show-code-actions nil)  ;; Disable automatic code actions
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

      ${optionalString cfg.emacs.modules.tools.emms ''
        ;; EMMS - Emacs MultiMedia System
        (require 'emms-setup)
        (setq emms-player-list nil)

        ;; Use mpv as the player
        (require 'emms-player-mpv)
        (setq emms-player-list '(emms-player-mpv))

        (emms-all)

        ;; Set music directory
        (setq emms-source-file-default-directory "~/Music/")

        ;; Enable info display
        (require 'emms-mode-line)
        (emms-mode-line 1)
        (require 'emms-playing-time)
        (emms-playing-time 1)

        ;; Key bindings
        (global-set-key (kbd "C-c m p") 'emms-pause)
        (global-set-key (kbd "C-c m s") 'emms-stop)
        (global-set-key (kbd "C-c m n") 'emms-next)
        (global-set-key (kbd "C-c m r") 'emms-previous)
        (global-set-key (kbd "C-c m b") 'emms-smart-browse)
        (global-set-key (kbd "C-c m l") 'emms-playlist-mode-go)
      ''}

      ;;; Formatting

      ;; Format on save function
      (defun format-buffer ()
        "Format the current buffer based on major mode."
        (interactive)
        ;; Save cursor position for ALL formatters
        (let ((current-point (point))
              (current-line (line-number-at-pos))
              (current-column (current-column)))
          (cond
           ;; Nix - use alejandra or nixpkgs-fmt
           ((eq major-mode 'nix-mode)
            (when (executable-find "nixpkgs-fmt")
              (shell-command-on-region
               (point-min) (point-max)
               "nixpkgs-fmt"
               (current-buffer) t
               "*nixpkgs-fmt Errors*" t)))

           ;; Python - use black and isort
           ((eq major-mode 'python-mode)
            (when (executable-find "black")
              (shell-command-on-region
               (point-min) (point-max)
               "black --quiet -"
               (current-buffer) t
               "*Black Errors*" t))
            (when (executable-find "isort")
              (shell-command-on-region
               (point-min) (point-max)
               "isort --quiet -"
               (current-buffer) t
               "*isort Errors*" t)))

           ;; Rust - use rustfmt
           ((eq major-mode 'rust-mode)
            (when (executable-find "rustfmt")
              (shell-command-on-region
               (point-min) (point-max)
               "rustfmt"
               (current-buffer) t
               "*rustfmt Errors*" t)))

           ;; JavaScript/TypeScript - use prettier
           ((or (eq major-mode 'js2-mode)
                (eq major-mode 'typescript-mode)
                (eq major-mode 'web-mode))
            (when (executable-find "prettier")
              (shell-command-on-region
               (point-min) (point-max)
               "prettier --stdin-filepath dummy.js"
               (current-buffer) t
               "*Prettier Errors*" t)))

           ;; Go - use gofmt
           ((eq major-mode 'go-mode)
            (when (executable-find "gofmt")
              (shell-command-on-region
               (point-min) (point-max)
               "gofmt"
               (current-buffer) t
               "*gofmt Errors*" t)))

           ;; Shell scripts - use shfmt
           ((eq major-mode 'sh-mode)
            (when (executable-find "shfmt")
              (shell-command-on-region
               (point-min) (point-max)
               "shfmt -i 2"
               (current-buffer) t
               "*shfmt Errors*" t)))

           ;; Fallback to built-in indent
           (t (indent-region (point-min) (point-max))))

          ;; Restore cursor position after formatting
          ;; Try to restore exact point first, fall back to line+column
          (goto-char (min current-point (point-max)))
          ;; If the point moved significantly, try to restore line+column
          (when (> (abs (- (line-number-at-pos) current-line)) 2)
            (goto-line current-line)
            (move-to-column current-column))))

      ;; Enable format on save for configured modes
      (defun enable-format-on-save ()
        "Enable formatting on save for the current buffer."
        (add-hook 'before-save-hook 'format-buffer nil t))

      ;; Add to relevant mode hooks
      (add-hook 'nix-mode-hook 'enable-format-on-save)
      (add-hook 'python-mode-hook 'enable-format-on-save)
      (add-hook 'rust-mode-hook 'enable-format-on-save)
      (add-hook 'js2-mode-hook 'enable-format-on-save)
      (add-hook 'typescript-mode-hook 'enable-format-on-save)
      (add-hook 'go-mode-hook 'enable-format-on-save)
      (add-hook 'sh-mode-hook 'enable-format-on-save)
      (add-hook 'web-mode-hook 'enable-format-on-save)

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
        (add-hook 'rust-mode-hook
                  (lambda ()
                    (setq rustic-format-on-save nil)))
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
