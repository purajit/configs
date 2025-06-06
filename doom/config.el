;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;;; See https://github.com/doomemacs/doomemacs/blob/master/templates/config.example.el

(setq user-full-name "purajit")
;; (setq user-mail-address "")

;;;;;; KEYS
;; option-as-meta, command-as-hyper
(setq ns-command-modifier 'hyper)
(setq mac-command-modifier 'hyper)
(setq ns-option-modifier 'meta)
(setq mac-option-modifier 'meta)
(setq ns-function-modifier 'super)
;; sensible defaults aka muscle memory
(global-set-key (kbd "M-g") 'goto-line)
(global-set-key (kbd "M-.") 'lsp-find-definition)
(global-set-key (kbd "M-,") 'pop-global-mark)
(global-set-key (kbd "C-c SPC") 'avy-goto-char-timer)
;; to get replacement info in modeline
(global-set-key [remap query-replace] 'anzu-query-replace)
(global-set-key [remap query-replace-regexp] 'anzu-query-replace-regexp)
;; use consult's buffer explorer and override default
(global-set-key (kbd "C-x b") 'consult-buffer)
(setq tab-always-indent t)

;;;;;; Reformatting
(add-hook! 'before-save-hook 'delete-trailing-whitespace)
(apheleia-global-mode +1)
(use-package apheleia
  :config
  (with-eval-after-load 'apheleia
    ;; apheleia uses black by default
    (setf (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-isort ruff)))
  )

;;;;;; CODING MODES
(use-package treesit-auto
  :demand t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))
(setq treesit-load-name-override-list '((js "libtree-sitter-js" "tree_sitter_javascript")))
(setq doom-scratch-initial-major-mode 'text-mode)

(setq lsp-pyright-langserver-command "basedpyright")
(add-hook! 'python-ts-mode-hook 'lsp-deferred)
(setq js-indent-level 2)
(setq-default js2-basic-offset 2)
(add-hook
 'json-mode-hook
 (lambda ()
   (set (make-local-variable 'indent-line-function) 'js-indent-line)
   (set (make-local-variable 'indent-region-function) 'json-mode-beautify)))
(setq highlight-indent-guides-responsive 'top)
(setq highlight-indent-guides-auto-character-face-perc '75)
(setq highlight-indent-guides-auto-top-character-face-perc '300)
(after! git-commit
  ;; 72 is the GitHub limit
  (setq git-commit-summary-max-length 72))
(after! magit (setq git-commit-summary-max-length 72))
(after! lsp-mode
  (setq lsp-ui-sideline-enable nil)
  (setq lsp-enable-suggest-server-download nil)
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-ui-sideline-enable nil)
  (setq lsp-signature-auto-activate nil)
  (setq lsp-signature-render-documentation nil)
  )
(setq show-paren-delay 0)

;;;;;; APPEARANCE
;; font, themes, coordinate background with terminal
;; treat doom-tomorrow-night/day as safe themes
(custom-set-variables
 '(custom-safe-themes
   '("e1f4f0158cd5a01a9d96f1f7cdcca8d6724d7d33267623cc433fe1c196848554" "7e377879cbd60c66b88e51fad480b3ab18d60847f31c435f15f5df18bdb18184" default)))
;; scratch and mini buffer use the same background as normal buffers
(custom-theme-set-faces! 'doom-tomorrow-night
  '(vertical-border :background "#1d1f21")
  '(solaire-default-face :background "#1d1f21"))
(custom-theme-set-faces! 'doom-tomorrow-day
  '(vertical-border :background "#ffffff")
  '(solaire-default-face :background "#ffffff"))
;; (setq doom-theme
;;       ;; dark mode
;;       ;; 'doom-tomorrow-night
;;       ;; light mode
;;       ;; 'doom-tomorrow-day
;;       )
;;;; follow system theme and switch
(setq auto-dark-allow-osascript t)
(after! doom-ui
  (setq! auto-dark-themes '((doom-tomorrow-night) (doom-tomorrow-day)))
  (auto-dark-mode 1))
(setq doom-font (font-spec :family "Mononoki Nerd Font" :size 14 :weight 'regular))
;; bring GUI window opened from terminal to focus
(select-frame-set-input-focus (selected-frame))
(setq
 default-frame-alist
 '(
   (left . 0)
   (width . 120)
   (fullscreen . fullheight)
   ;; Prevents some cases of Emacs flickering.
   (inhibit-double-buffering . t)))
;; prettier window dividers in term
(add-hook!
 'window-configuration-change-hook
 (let ((display-table (or buffer-display-table standard-display-table)))
   (set-display-table-slot display-table 5 ?│)
   (set-window-display-table (selected-window) display-table)))
;; (custom-set-faces
;;  '(vertical-border ((t (:background "#1d1f21" :foreground "#0d0d0d")))))
;; line numbers are a _massive_ hit to performance
(setq display-line-numbers-type nil)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-hl-line-mode -1)
(vertico-reverse-mode)
;; to get search result counts in modeline
(global-anzu-mode +1)
(anzu-mode +1)
(after! hl-line
  (remove-hook 'doom-first-buffer-hook #'global-hl-line-mode))
;; modeline
(after! doom-modeline
  (remove-hook 'doom-modeline-mode-hook #'size-indication-mode)
  (setq doom-modeline-height 25)
  (setq doom-modeline-bar-width 3)

  (setq doom-modeline-icon t)
  (setq doom-modeline-major-mode-icon t)
  (setq doom-modeline-major-mode-color-icon t)
  (setq doom-modeline-buffer-state-icon t)
  (setq doom-modeline-buffer-modification-icon t)

  (setq doom-modeline-buffer-encoding nil)
  (setq doom-modeline-env-version t)
  (setq doom-modeline-indent-info nil)
  (setq doom-modeline-minor-modes nil)
  (setq doom-modeline-percent-position nil)

  (setq doom-modeline-vcs-max-length 30))

;;;;;; MISC
(setq org-directory "~/Documents/org/")
(setq confirm-kill-emacs nil)
