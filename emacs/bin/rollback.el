;;; rollback.el --- Restore package checkouts from versions.el -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil)

(let* ((config-directory
        (file-name-directory (directory-file-name
                              (file-name-directory load-file-name))))
       (data-directory
        (file-name-as-directory
         (expand-file-name "emacs" (or (getenv "XDG_DATA_HOME") "~/.local/share"))))
       (lockfile (expand-file-name "versions.el" config-directory))
       (repos-directory (expand-file-name "straight/repos/" data-directory)))
  ;; Restore straight.el first, without depending on straight.el being loadable.
  (with-temp-buffer
    (insert-file-contents lockfile)
    (dolist (entry (read (current-buffer)))
      (let ((repo (expand-file-name (format "%s" (car entry)) repos-directory)))
        (when (file-directory-p repo)
          (unless (zerop (call-process "git" nil nil nil
                                      "-C" repo "checkout" "--detach" (cdr entry)))
            (error "Could not restore %s" (car entry)))))))
  (setq straight-base-dir data-directory
        straight-profiles `((nil . ,lockfile))
        straight-use-version-specific-build-dir t)
  (load (expand-file-name "straight/repos/straight.el/bootstrap.el" data-directory)
        nil 'nomessage)
  (straight-thaw-versions)
  (straight-rebuild-all))

;;; rollback.el ends here
