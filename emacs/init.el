;;; init.el --- A small, reproducible Emacs configuration -*- lexical-binding: t; -*-

(when (< emacs-major-version 30)
  (error "This configuration requires Emacs 30 or newer"))

;;;; Files and mutable state

(defconst pm/config-directory
  (file-name-as-directory (file-truename user-emacs-directory)))
(defconst pm/data-directory
  (file-name-as-directory
    (expand-file-name "emacs" (or (getenv "XDG_DATA_HOME") "~/.local/share"))))
(defconst pm/cache-directory
  (file-name-as-directory
    (expand-file-name "emacs" (or (getenv "XDG_CACHE_HOME") "~/.cache"))))
(defconst pm/state-directory
  (file-name-as-directory
    (expand-file-name "emacs" (or (getenv "XDG_STATE_HOME") "~/.local/state"))))

(dolist (directory (list pm/data-directory pm/cache-directory pm/state-directory))
  (make-directory directory t))

(setq custom-file (expand-file-name "custom.el" pm/state-directory)
  package-user-dir (expand-file-name "elpa/" pm/data-directory)
  backup-directory-alist `(("." . ,(expand-file-name "backups/" pm/cache-directory)))
  auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-save/" pm/cache-directory) t))
  auto-save-list-file-prefix (expand-file-name "auto-save-list/.saves-" pm/cache-directory)
  savehist-file (expand-file-name "history.el" pm/state-directory)
  save-place-file (expand-file-name "places.el" pm/state-directory)
  recentf-save-file (expand-file-name "recentf.el" pm/state-directory)
  project-list-file (expand-file-name "projects.el" pm/state-directory)
  bookmark-default-file (expand-file-name "bookmarks.el" pm/state-directory)
  abbrev-file-name (expand-file-name "abbrev.el" pm/state-directory)
  tramp-persistency-file-name (expand-file-name "tramp.el" pm/state-directory)
  tramp-auto-save-directory (expand-file-name "tramp-auto-save/" pm/cache-directory)
  url-configuration-directory (expand-file-name "url/" pm/state-directory)
  server-auth-dir (expand-file-name "server/" pm/state-directory)
  eshell-directory-name (expand-file-name "eshell/" pm/state-directory)
  org-persist-directory (expand-file-name "org-persist/" pm/state-directory)
  transient-history-file (expand-file-name "transient/history.el" pm/state-directory)
  transient-levels-file (expand-file-name "transient/levels.el" pm/state-directory)
  transient-values-file (expand-file-name "transient/values.el" pm/state-directory))
(make-directory (cdar backup-directory-alist) t)
(make-directory (cadar auto-save-file-name-transforms) t)
(make-directory (file-name-directory auto-save-list-file-prefix) t)
(make-directory tramp-auto-save-directory t)
(load custom-file 'noerror 'nomessage)

;;;; Reproducible packages

;; Package repositories and builds live outside this config repo.  Only the
;; exact revisions in versions.el are checked in.
(setq straight-base-dir pm/data-directory
  straight-profiles `((nil . ,(expand-file-name "versions.el" pm/config-directory)))
  straight-use-version-specific-build-dir t
  straight-check-for-modifications '(check-on-save find-when-checking))

(defvar bootstrap-version)
(let ((bootstrap-file
        (expand-file-name "straight/repos/straight.el/bootstrap.el" straight-base-dir))
       (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
      (url-retrieve-synchronously
        "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
        'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(require 'use-package)
(setq straight-use-package-by-default t
  use-package-always-defer t
  use-package-expand-minimally t)

(defun pm/upgrade-packages ()
  "Update, rebuild, and lock all packages.
Use bin/upgrade rather than calling this directly: the script verifies a clean
startup and restores the old lockfile and package checkouts if that fails."
  (interactive)
  (straight-pull-all)
  (straight-rebuild-all)
  (straight-freeze-versions t))

(defun pm/smoke-test ()
  "Load the important deferred packages, failing on any error."
  (dolist (feature '(vertico orderless marginalia consult corfu cape
                      dumb-jump apheleia treesit-auto eglot magit envrc doom-themes
                      doom-modeline anzu kkp))
    (require feature))
  (message "Emacs package smoke test passed"))

;;;; Fast, quiet defaults

(setq user-full-name "purajit"
  inhibit-startup-screen t
  initial-scratch-message nil
  initial-major-mode 'text-mode
  confirm-kill-emacs nil
  ring-bell-function #'ignore
  use-short-answers t
  sentence-end-double-space nil
  create-lockfiles nil
  make-backup-files t
  version-control t
  delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  vc-follow-symlinks t
  require-final-newline t
  tab-always-indent 'complete
  visible-bell nil
  scroll-conservatively 101
  scroll-margin 2
  hscroll-margin 2
  show-paren-delay 0
  copy-region-blink-delay 0
  xref-search-program 'ripgrep)

(setq-default indent-tabs-mode nil
  tab-width 2
  fill-column 80
  display-line-numbers-width nil)

(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'pixel-scroll-precision-mode) (pixel-scroll-precision-mode 1))
(when (fboundp 'mouse-wheel-mode) (mouse-wheel-mode 1))
(xterm-mouse-mode 1)
(setq window-divider-default-places t
      window-divider-default-bottom-width 1
      window-divider-default-right-width 1)
;; On a terminal, `window-divider-mode' renders a full character-cell bar and
;; takes precedence over the thin `vertical-border' glyph below.
(window-divider-mode -1)
(global-display-line-numbers-mode -1)
(global-hl-line-mode -1)
(column-number-mode 1)
(line-number-mode 1)
(show-paren-mode 1)
(electric-pair-mode 1)
(delete-selection-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(global-auto-revert-mode 1)
(which-key-mode 1)

(add-hook 'before-save-hook #'delete-trailing-whitespace)
;; Use the same thin separator glyph in GUI and terminal frames.
(add-hook 'window-configuration-change-hook
  (lambda ()
    (let ((table (or buffer-display-table
                     standard-display-table
                     (setq standard-display-table (make-display-table)))))
      (set-display-table-slot table 'vertical-border ?│)
      (set-window-display-table (selected-window) table))))

;;;; macOS and frames

(setq ns-command-modifier 'hyper
  mac-command-modifier 'hyper
  ns-option-modifier 'meta
  mac-option-modifier 'meta
  ns-function-modifier 'super)

;; The native NS clipboard functions work in GUI frames but do not own the
;; macOS pasteboard from a TTY frame.  Keep them for GUI Emacs and bridge
;; terminal Emacs through the system tools, as Doom does on macOS.
(when (eq system-type 'darwin)
  (defvar pm/native-interprogram-cut-function interprogram-cut-function)
  (defvar pm/native-interprogram-paste-function interprogram-paste-function)
  (defvar pm/last-pbcopy-text nil)

  (defun pm/pbcopy (text)
    "Put TEXT on the macOS pasteboard from a terminal frame."
    (setq pm/last-pbcopy-text text)
    (let ((coding-system-for-write 'utf-8-unix)
           (process-connection-type nil))
      (with-temp-buffer
        (insert text)
        (call-process-region (point-min) (point-max)
          "/usr/bin/pbcopy" nil nil nil))))

  (defun pm/pbpaste ()
    "Return new text from the macOS pasteboard, or nil if Emacs put it there."
    (let ((coding-system-for-read 'utf-8-unix)
           (process-connection-type nil))
      (with-temp-buffer
        (when (zerop (call-process "/usr/bin/pbpaste" nil t nil))
          (let ((text (buffer-string)))
            (unless (equal text pm/last-pbcopy-text)
              text))))))

  (setq interprogram-cut-function
    (lambda (text)
      (if (and (display-graphic-p)
            pm/native-interprogram-cut-function)
        (funcall pm/native-interprogram-cut-function text)
        (pm/pbcopy text)))
    interprogram-paste-function
    (lambda ()
      (if (and (display-graphic-p)
            pm/native-interprogram-paste-function)
        (funcall pm/native-interprogram-paste-function)
        (pm/pbpaste)))))

(dolist (setting '((left . 0)
                    (width . 120)
                    (fullscreen . fullheight)
                    (undecorated . t)
                    (inhibit-double-buffering . t)
                    (font . "Mononoki Nerd Font-14")))
  (add-to-list 'default-frame-alist setting))

;; `default-frame-alist' covers daemon/client frames; the separate initial
;; entry ensures the first frame of a directly launched GUI is undecorated too.
(add-to-list 'initial-frame-alist '(undecorated . t))

(add-hook 'after-make-frame-functions
  (lambda (frame)
    (with-selected-frame frame
      (menu-bar-mode -1)
      (when (display-graphic-p)
        (select-frame-set-input-focus frame)))))

;;;; Keys: standard Emacs bindings, with a few deliberate conveniences

(defun pm/backward-to-bol-or-indent ()
  "Move to indentation, then toggle between it and the true line beginning."
  (interactive "^")
  (let ((origin (point)))
    (back-to-indentation)
    (when (= origin (point))
      (move-beginning-of-line 1))))

(global-set-key (kbd "C-a") #'pm/backward-to-bol-or-indent)
(global-set-key (kbd "M-g") #'goto-line)
(global-set-key (kbd "M-.") #'xref-find-definitions)
(global-set-key (kbd "M-,") #'xref-go-back)
(global-set-key (kbd "C-c SPC") #'avy-goto-char-timer)

;;;; Minibuffer and in-buffer completion

(use-package vertico
  :demand t
  :custom
  (vertico-cycle t)
  (vertico-count 17)
  (vertico-resize nil)
  :config
  (vertico-mode 1)
  (vertico-reverse-mode 1)
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)
  (keymap-set vertico-map "DEL" #'vertico-directory-delete-char))

(use-package orderless
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion basic))
                                    (eglot (styles orderless basic)))))

(use-package marginalia
  :demand t
  :config (marginalia-mode 1))

(use-package consult
  :bind (("C-x b" . consult-buffer)
          ("M-y" . consult-yank-pop)
          ([remap goto-line] . consult-goto-line)
          ([remap imenu] . consult-imenu)
          ([remap recentf-open-files] . consult-recent-file)))

(use-package dumb-jump
  :commands dumb-jump-xref-activate
  :init
  ;; Buffer-local semantic backends such as Eglot and Elisp run before global
  ;; hooks.  Dumb Jump then provides a ripgrep fallback ahead of legacy TAGS.
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
  :custom
  (dumb-jump-force-searcher 'rg)
  (xref-show-definitions-function #'consult-xref)
  (xref-show-xrefs-function #'consult-xref))

(use-package corfu
  :demand t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.35)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  (corfu-count 16)
  (corfu-on-exact-match nil)
  (corfu-quit-at-boundary 'separator)
  :config
  (global-corfu-mode 1)
  (corfu-history-mode 1)
  (add-to-list 'savehist-additional-variables 'corfu-history))

(use-package cape
  :hook ((prog-mode . pm/add-code-capfs)
          (text-mode . pm/add-text-capfs))
  :init
  (defun pm/add-code-capfs ()
    (add-hook 'completion-at-point-functions #'cape-file -10 t)
    (add-hook 'completion-at-point-functions #'cape-dabbrev 20 t))
  (defun pm/add-text-capfs ()
    (add-hook 'completion-at-point-functions #'cape-dabbrev 20 t)))

(use-package avy
  :commands avy-goto-char-timer)

;;;; Editing, undo, and search feedback

(use-package undo-fu
  :demand t
  :custom
  (undo-limit 256000)
  (undo-strong-limit 2000000)
  (undo-outer-limit 36000000)
  :bind (([remap undo] . undo-fu-only-undo)
          ([remap redo] . undo-fu-only-redo)
          ("C-_" . undo-fu-only-undo)
          ("M-_" . undo-fu-only-redo)))

(use-package undo-fu-session
  :after undo-fu
  :custom
  (undo-fu-session-directory (expand-file-name "undo/" pm/cache-directory))
  (undo-fu-session-incompatible-files '("\\.gpg\\'" "/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'"))
  :config
  (when (executable-find "zstd")
    (setq undo-fu-session-compression 'zst))
  (global-undo-fu-session-mode 1))

(use-package hl-todo
  :hook (prog-mode . hl-todo-mode))

(use-package eros
  :hook (emacs-lisp-mode . eros-mode))

;;;; Formatting and syntax-aware modes

(use-package apheleia
  :demand t
  :config
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-isort ruff))
  (setf (alist-get 'python-mode apheleia-mode-alist) '(ruff-isort ruff))
  (setf (alist-get 'shfmt apheleia-formatters) '("shfmt" "--filename" filepath))
  (add-to-list 'apheleia-mode-alist '(sh-mode . shfmt))
  (apheleia-global-mode 1))

(use-package treesit-auto
  :demand t
  :custom (treesit-font-lock-level 4)
  :init
  (defconst pm/tree-sitter-languages
    '(bash css go gomod javascript json lua python rust tsx typescript yaml)
    "Tree-sitter grammars used by this configuration.")

  (defun pm/install-tree-sitter-grammars ()
    "Install any missing grammars in `pm/tree-sitter-languages'."
    (interactive)
    (let ((treesit-auto-install t)
           (treesit-auto-langs pm/tree-sitter-languages))
      (treesit-auto-install-all)
      ;; Make newly installed modes available without requiring a restart.
      (treesit-auto-add-to-auto-mode-alist)))
  :config
  (let ((grammar-directory (expand-file-name "tree-sitter/" pm/data-directory)))
    (make-directory grammar-directory t)
    (add-to-list 'treesit-extra-load-path grammar-directory)
    (advice-add
      #'treesit-install-language-grammar :filter-args
      (lambda (args)
        (list (car args) (or (cadr args) grammar-directory)))))
  ;; Check the small configured set once at startup.  Do not enable
  ;; `global-treesit-auto-mode': it probes every grammar whenever any buffer
  ;; chooses a major mode, which makes opening even plain text files slow.
  (global-treesit-auto-mode -1)
  (let ((treesit-auto-langs pm/tree-sitter-languages))
    (treesit-auto-add-to-auto-mode-alist)))

;; Emacs 30 includes EditorConfig and the principal tree-sitter modes.
(use-package editorconfig
  :straight nil
  :demand t
  :config (editorconfig-mode 1))

(use-package flymake
  :straight nil
  :custom
  (flymake-no-changes-timeout 0.5)
  (flymake-suppress-zero-counters t))

(use-package flymake-shellcheck
  :hook (sh-mode . flymake-shellcheck-load))

(use-package eglot
  :straight nil
  :commands (eglot eglot-ensure)
  :hook ((python-mode python-ts-mode go-mode go-ts-mode) . eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-size 0)
  (eglot-sync-connect nil)
  :config
  (add-to-list 'eglot-server-programs
    '((python-mode python-ts-mode)
       . ("basedpyright-langserver" "--stdio"))))

;;;; Project and file tools

(use-package envrc
  :hook (after-init . envrc-global-mode))

(use-package magit
  :commands (magit-status magit-dispatch)
  :bind ("C-x g" . magit-status)
  :custom
  (magit-commit-show-diff nil)
  (git-commit-summary-max-length 72))

(use-package dired
  :straight nil
  :hook (dired-mode . dired-hide-details-mode)
  :custom
  (dired-dwim-target t)
  (dired-kill-when-opening-new-dired-buffer t))

;;;; Mode line

(use-package anzu
  :demand t
  :bind (([remap query-replace] . anzu-query-replace)
          ([remap query-replace-regexp] . anzu-query-replace-regexp))
  :custom
  (anzu-cons-mode-line-p nil)
  :config
  (global-anzu-mode 1))

;;;; Terminal keyboard input

(use-package kkp
  :demand t
  :custom
  ;; KKP normally encodes C-g as a multi-byte sequence.  Temporarily restoring
  ;; legacy input around synchronous subprocesses keeps C-g able to interrupt
  ;; them (notably direnv calls made by envrc).
  (kkp-restore-legacy-keys-around-subprocesses t)
  :config
  (unless noninteractive
    (global-kkp-mode 1)))

(use-package doom-modeline
  :demand t
  :custom
  (doom-modeline-height 25)
  (doom-modeline-icon t)
  (doom-modeline-buffer-file-name-style 'relative-from-project)
  (doom-modeline-project-detection 'project)
  (doom-modeline-buffer-state-icon t)
  (doom-modeline-buffer-modification-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-percent-position nil)
  (doom-modeline-position-column-line-format '("%l:%c"))
  (doom-modeline-vcs-icon t)
  (doom-modeline-vcs-max-length 30)
  (doom-modeline-check-icon t)
  (doom-modeline-check 'simple)
  :config
  ;; Use one intentionally small layout in every buffer.  `matches' is backed
  ;; by Anzu and shows current/total during search and replacement.
  (setq doom-modeline-mode-alist nil)
  (doom-modeline-def-modeline 'main
    '(buffer-info buffer-position matches)
    '(major-mode vcs check))
  (doom-modeline-mode 1))

;;;; Themes

(use-package doom-themes
  :demand t
  :config
  ;; Declare both themes up front so switching only enables already loaded
  ;; definitions and never prompts during an appearance-change callback.
  (load-theme 'doom-tomorrow-night t t)
  (load-theme 'doom-tomorrow-day t t)
  ;; Themes otherwise paint the entire terminal border cell.  Matching its
  ;; background to the buffer leaves only the thin `│' foreground visible.
  (defun pm/style-window-divider (&optional _theme)
    (set-face-background 'vertical-border
                         (face-background 'default nil t)
                         nil))
  (add-hook 'enable-theme-functions #'pm/style-window-divider))

(use-package auto-dark
  :demand t
  :custom
  (auto-dark-allow-osascript t)
  (auto-dark-themes '((doom-tomorrow-night) (doom-tomorrow-day)))
  :config
  (auto-dark-mode 1)
  ;; In a terminal or daemon, NS Emacs exposes the native appearance hook but
  ;; does not necessarily emit an event.  Keep the immediate GUI hook and add
  ;; the package's five-second polling fallback so every frame type switches.
  (when (eq system-type 'darwin)
    (auto-dark-start-timer)))

;;;; Extra file formats retained from the Doom setup

(use-package bazel :mode ("\\.bzl\\'" "BUILD\\(?:\\.bazel\\)?\\'" "WORKSPACE\\(?:\\.bazel\\)?\\'"))
(use-package csv-mode :mode "\\.csv\\'")
(use-package markdown-mode :mode (("README\\.md\\'" . gfm-mode) ("\\.md\\'" . markdown-mode)))
(use-package terraform-mode :mode "\\.tf\\(?:vars\\)?\\'")
(use-package thrift :mode "\\.thrift\\'")
(use-package tmux-mode :mode "\\.tmux\\(?:\\.conf\\)?\\'")
(use-package web-mode :mode "\\.html?\\'")

(setq js-indent-level 2
  org-directory "~/Documents/org/")

;;; init.el ends here
