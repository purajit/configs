;;; .emacs -- This file is designed to be re-evaled; use the variable first-time
;; to avoid any problems with this.
;;; Commentary:
;;; Code:

(defvar first-time t
  "Flag signifying this is the first time that .emacs has been evaled.")

;; Spacemacs
(load-file "~/.emacs.d/init.el")

;; Appearance
(setq ring-bell-function 'ignore)
(scroll-bar-mode -1)
(menu-bar-mode -1)

;; Basic global modes
;; (setq show-trailing-whitespace t)
;; (smartparens-global-mode t)
;; (smartparens-strict-mode -1)
(setq-default tab-width 4)

;; key bindings
(setq ns-command-modifier 'meta)
(setq ns-option-modifier 'hyper) ; sets the Option key as Hyper
(setq ns-function-modifier 'super) ; sets the Option key as Super
(setq mac-command-modifier 'meta) ; sets the Command key as Meta
(setq mac-option-modifier 'hyper) ; sets the Option key as Hyper
(global-unset-key (kbd "<magnify-up>"))
(global-unset-key (kbd "<magnify-down>"))
(global-set-key "\M-g" 'goto-line)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Modes
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; JavaScript
(setq js-indent-level 2)
(setq-default js2-basic-offset 2)
(add-hook 'java-mode-hook (lambda ()
                            (setq c-basic-offset 2)))

;; use spaces only. no tabs
;; and don't use tabs for indentation
(customize-set-variable 'indent-tabs-mode nil)
(setq-default indent-tabs-mode nil)
(add-hook 'python-mode-hook
          (lambda ()
            (setq tab-width 4)
            (setq python-indent-offset 4)
            (setq python-indent-level 4)
            (setq-default indent-tabs-mode nil)
            (setq indent-tabs-mode nil)
            (let ((ptw (if (boundp 'me-my-python-tab-width) me-my-python-tab-width 4)))
              (progn (setq tab-width ptw)
                     (set-variable 'py-indent-offset ptw)
                     (setq python-indent ptw)))))

(require 'indent-guide)
(add-hook 'python-mode-hook 'indent-guide-mode)
(add-hook 'ruby-mode-hook 'indent-guide-mode)

(defcustom TeX-buf-close-at-warnings-only t
  "Close TeX buffer if there are only warnings."
  :group 'TeX-output
  :type 'boolean)

(defun my-tex-close-TeX-buffer (_output)
  "Close compilation buffer if there are no errors.
Hook this function into `TeX-after-compilation-finished-functions'."
  (let ((buf (TeX-active-buffer)))
    (when (buffer-live-p buf)
      (with-current-buffer buf
        (when (progn (TeX-parse-all-errors)
                     (or
                      (and TeX-buf-close-at-warnings-only
                           (null (cl-assoc 'error TeX-error-list)))
                      (null TeX-error-list)))
          (cl-loop for win in (window-list)
                   if (eq (window-buffer win) (current-buffer))
                   do (delete-window win)))))))
(add-hook 'TeX-after-compilation-finished-functions #'my-tex-close-TeX-buffer)

(add-hook 'terraform-mode-hook #'terraform-format-on-save-mode)

(message "Configuration loaded.")
(provide '.emacs)
;;; .emacs ends here
