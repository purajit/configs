;;; early-init.el --- Early startup settings -*- lexical-binding: t; -*-

;; Keep package.el from activating packages before straight.el does.
(setq package-enable-at-startup nil)

;; Redirect files Emacs can create before init.el runs.  This keeps
;; `user-emacs-directory' a read-only-in-practice configuration directory.
(let* ((cache-root (or (getenv "XDG_CACHE_HOME") "~/.cache"))
       (cache (expand-file-name "emacs/" cache-root))
       (eln-cache (expand-file-name "eln-cache/" cache)))
  (make-directory cache t)
  (setq auto-save-list-file-prefix
        (expand-file-name "auto-save-list/.saves-" cache))
  (make-directory (file-name-directory auto-save-list-file-prefix) t)
  (when (fboundp 'startup-redirect-eln-cache)
    (make-directory eln-cache t)
    (startup-redirect-eln-cache eln-cache)))

;; Avoid expensive redisplay and garbage collection while loading init.el.
(setq frame-inhibit-implied-resize t
      gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Apply these before the first GUI frame is drawn.  init.el repeats them for
;; daemon and terminal frames.
(dolist (setting '((menu-bar-lines . 0)
                   (tool-bar-lines . 0)
                   (vertical-scroll-bars)))
  (add-to-list 'default-frame-alist setting))

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 32 1024 1024)
                  gc-cons-percentage 0.1)))

;;; early-init.el ends here
