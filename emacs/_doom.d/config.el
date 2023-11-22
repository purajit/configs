;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


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
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "Iosevka Comfy" :size 16 :weight 'regular))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-molokai)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
;; (setq display-line-numbers-type 'nil)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


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

;; cmd as meta
(setq ns-command-modifier 'meta)
(setq ns-option-modifier 'hyper) ; sets the Option key as Hyper
(setq ns-function-modifier 'super) ; sets the Option key as Super
(setq mac-command-modifier 'meta) ; sets the Command key as Meta
(setq mac-option-modifier 'hyper) ; sets the Option key as Hyper

;; key bindings
(global-unset-key (kbd "<magnify-up>"))
(global-unset-key (kbd "<magnify-down>"))
(global-set-key (kbd "M-g") 'goto-line)
(global-set-key (kbd "C-x b") 'consult-buffer)
(global-set-key (kbd "C-c d") '+lookup/definition)
(global-set-key (kbd "C-o") 'better-jumper-jump-backward)
;; C-i inputs a TAB, so there's no way to distinguish universally (input-decode-map) would work in
;; GUI, but not terminal)
;; (global-set-key (kbd "C-i") 'better-jumper-jump-forward)

;; doomemacs allows inserting tabs. we hate that.
(setq tab-always-indent t)

;; run ruff on save
(add-hook 'python-mode-hook 'ruff-format-on-save-mode)

;; run terraform fmt on save
(add-hook 'terraform-mode-hook 'terraform-format-on-save-mode)

;; JavaScript (but also JSON)
(setq js-indent-level 2)
(setq-default js2-basic-offset 2)

;; the default indent-region behavior of json-mode is truly gross
(add-hook 'json-mode-hook (lambda ()
                            (set (make-local-variable 'indent-line-function) 'js-indent-line)
                            (set (make-local-variable 'indent-region-function) 'json-mode-beautify)))

(setq highlight-indent-guides-responsive 'top)
(setq highlight-indent-guides-auto-character-face-perc '75)
(setq highlight-indent-guides-auto-top-character-face-perc '300)

(vertico-reverse-mode)

(add-hook! 'window-setup-hook (x-focus-frame nil))

(setq git-commit-summary-max-length 120)
