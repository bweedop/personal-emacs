(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
		                        (not (gnutls-available-p))))
              (proto (if no-ssl "http" "https")))
    (when no-ssl
      (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (jedi bibtex-utils dracula-theme julia-shell multiple-cursors auto-complete ess elpy markdown-mode latex-preview-pane)))
 '(safe-local-variable-values (quote ((TeX-master . t)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(require 'auto-complete-config)
(ac-config-default)
(define-key ac-completing-map (kbd "M-h") 'ac-quick-help)
;; Get tab completion in R script files
;; See this page here
;; https://stat.ethz.ch/pipermail/ess-help/2013-March/008719.html
;; Make sure that this is after the auto-complete package initialization
(setq  ess-tab-complete-in-script t)
;; Show parentheses completions
(show-paren-mode 1)
;; Add left and right margins, when file is markdown or text.
(defun center-window (window) ""
       (let* ((current-extension (file-name-extension (or (buffer-file-name) "foo.unknown")))
	      (max-text-width 80)
	      (margin (max 0 (/ (- (window-width window) max-text-width) 2))))
	 (if (and (not (string= current-extension "md"))
		  (not (string= current-extension "txt"))
		  (not (string= current-extension "tex"))
		  (not (string= current-extension "bib")))
	     ;; Do nothing if this isn't an .md or .txt file.
	     ()
	   (set-window-margins window margin margin))))

;; Adjust margins of all windows.
(defun center-windows () ""
       (walk-windows (lambda (window) (center-window window)) nil 1))

;; Listen to window changes.
(add-hook 'window-configuration-change-hook 'center-windows)
;; Set path for python3
(setq python-shell-interpreter "/usr/bin/python3")
(defun python-shell-send-region-or-line ()
  "Call `python-shell-send-region' with selected region or current line (if none selected)."
  (interactive)
  (if (and transient-mark-mode mark-active)
          (python-shell-send-region (point) (mark))
	      (python-shell-send-region (point-at-bol) (point-at-eol))))
(add-hook 'python-mode-hook
	            (lambda () (local-set-key "\C-c\C-r" 'python-shell-send-region-or-line)))
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t) 
;; Multiple cursors
(global-set-key (kbd "C-c m c") 'mc/edit-lines)
;; Added support for julia
(add-to-list 'load-path "path-to-julia-mode")
(require 'julia-mode)
;; auto close bracket insertion. New in emacs 24
(electric-pair-mode 1)
(load-theme 'dracula t)
(defun my-bibtex-mode-setup ()
  (local-set-key (kbd "TAB") 'indent-for-tab-command))
(add-hook 'bibtex-mode-hook 'my-bibtex-mode-setup)
