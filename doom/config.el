;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

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
(global-unset-key (kbd "<magnify-up>"))
(global-unset-key (kbd "<magnify-down>"))

(setq org-directory "~/Documents/org/")

;; use consult's buffer explorer and override default
(global-set-key (kbd "C-x b") 'consult-buffer)
(vertico-reverse-mode)
(setq display-line-numbers-type t)
(setq tab-always-indent t)
(setq confirm-kill-emacs nil)

;;;;;; CODING MODES
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

(setq doom-font (font-spec :family "Mononoki Nerd Font" :size 14 :weight 'regular))
(setq doom-theme 'doom-molokai)
;; same as Alacritty
(custom-set-faces
  '(default ((t (:background "#15141b")))))
(custom-set-faces
  '(solaire-default-face ((t (:background "#15141b")))))

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
  ; doom-modeline has fixed this, but it's not yet upgraded in doom-emacs
  (defun doom-modeline-vcs-name ()
    "Display the vcs name."
    (and vc-mode (cadr (split-string (string-trim vc-mode) "^[A-Z]+[-:]+")))))

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
