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
(global-set-key (kbd "C-c SPC") 'avy-goto-char-timer)
(global-set-key (kbd "C-c C-g") 'magit-status)
;; to get replacement info in modeline
(global-set-key [remap query-replace] 'anzu-query-replace)
(global-set-key [remap query-replace-regexp] 'anzu-query-replace-regexp)
(global-unset-key (kbd "<magnify-up>"))
(global-unset-key (kbd "<magnify-down>"))
;; use consult's buffer explorer and override default
(global-set-key (kbd "C-x b") 'consult-buffer)
(setq tab-always-indent t)


;;;;;; CODING MODES
(setq doom-scratch-initial-major-mode 'text-mode)
(add-hook 'python-mode-hook 'ruff-format-on-save-mode)
(add-hook 'terraform-mode-hook 'terraform-format-on-save-mode)
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
(after! lsp-mode
  (setq lsp-enable-symbol-highlighting nil
        ;; If an LSP server isn't present when I start a prog-mode buffer, you
        ;; don't need to tell me. I know. On some machines I don't care to have
        ;; a whole development environment for some ecosystems.
        lsp-enable-suggest-server-download nil))


;;;;;; APPEARANCE
(vertico-reverse-mode)
;; font, themes, coordinate background with terminal
(setq doom-font (font-spec :family "Mononoki Nerd Font" :size 14 :weight 'regular))
(setq doom-theme 'doom-tomorrow-night)
(custom-set-faces
 '(default ((t (:background "#181818"))))
 '(solaire-default-face ((t (:background "#181818")))))
;; bring GUI window opened from terminal to focus
(select-frame-set-input-focus (selected-frame))
(setq default-frame-alist '((left . 0) (width . 120) (fullscreen . fullheight)))
;; Prevents some cases of Emacs flickering.
(add-to-list 'default-frame-alist '(inhibit-double-buffering . t))
(menu-bar-mode -1)
(scroll-bar-mode -1)
;; line numbers are a _massive_ hit to performance
(setq display-line-numbers-type nil)
;; to get search result counts in modeline
(global-anzu-mode +1)
(anzu-mode +1)
;; the long-awaited modeline!
(after! doom-modeline
  (setq doom-modeline-height 25)
  (setq doom-modeline-bar-width 3)

  (setq doom-modeline-icon t)
  (setq doom-modeline-major-mode-icon t)
  (setq doom-modeline-major-mode-color-icon t)
  (setq doom-modeline-buffer-state-icon t)
  (setq doom-modeline-buffer-modification-icon t)

  (setq doom-modeline-buffer-encoding t)
  (setq doom-modeline-env-version t)
  (setq doom-modeline-indent-info nil)
  (setq doom-modeline-minor-modes nil)
  (setq doom-modeline-percent-position nil)

  (setq doom-modeline-vcs-max-length 30)
  ;; doom-modeline has fixed this, but it's not yet upgraded in doom-emacs
  (defun doom-modeline-vcs-name ()
    "Display the vcs name."
    (and vc-mode (cadr (split-string (string-trim vc-mode) "^[A-Z]+[-:]+")))))


;;;;;; MISC
(setq org-directory "~/Documents/org/")
(setq confirm-kill-emacs nil)
