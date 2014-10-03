(package-initialize)
(delete-selection-mode t)
(global-visual-line-mode 1)

;; Disable the splash screen (to enable it agin, replace the t with 0)
(setq inhibit-splash-screen t)

;; Use external package archives
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))

;; Add git to the exec-path
(add-to-list 'exec-path "C:/Program Files (x86)/Git/bin")

;; get Orgmode
(require 'package)
(add-to-list 'package-archives
	     '("org" . "http://orgmode.org/elpa/") t)
(require 'ox-taskjuggler)
(package-initialize)

;;;;org-mode configuration
;; Enable org-mode
(require 'org)
(setq org-log-done t)
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)


;; Dynamic range report in org-mode
;; sourced from [[http://sachachua.com/blog/2007/12/clocking-time-with-emacs-org/]Sacha Chua - Clocking time with emacs org]
(defun org-dblock-write:rangereport (params)
  "Display day-by-day time reports."
  (let* ((ts (plist-get params :tstart))
         (te (plist-get params :tend))
         (start (time-to-seconds
                 (apply 'encode-time (org-parse-time-string ts))))
         (end (time-to-seconds
               (apply 'encode-time (org-parse-time-string te))))
         day-numbers)
    (setq params (plist-put params :tstart nil))
    (setq params (plist-put params :end nil))
    (while (<= start end)
      (save-excursion
        (insert "\n\n"
                (format-time-string (car org-time-stamp-formats)
                                    (seconds-to-time start))
                "----------------\n")
        (org-dblock-write:clocktable
         (plist-put
          (plist-put
           params
           :tstart
           (format-time-string (car org-time-stamp-formats)
                               (seconds-to-time start)))
          :tend
          (format-time-string (car org-time-stamp-formats)
                              (seconds-to-time end))))
        (setq start (+ 86400 start))))))

;; Enable transclusion dynamic blocks
;; taken from [[http://stackoverflow.com/questions/15328515/iso-transclusion-in-emacs-org-mode]]
;; Then to include a line range from a given file, you can create a dynamic block like so:
;;
;; #+BEGIN: transclusion :filename "~/testfile.org" :min 2 :max 4
;; #+END:
(defun org-dblock-write:transclusion (params)
  (progn
    (with-temp-buffer
      (insert-file-contents (plist-get params :filename))
      (let ((range-start
	     (or (plist-get params :min) (line-number-at-pos (point-min))))
            (range-end
	     (or (plist-get params :max) (line-number-at-pos (point-max)))))
        (copy-region-as-kill (line-beginning-position range-start)
			     (line-end-position range-end))))
    (yank)))


;; Load packages
(defvar my-packages '(clojure-mode
                      cider))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

;;;; Clojure config

;; RAINBOWS
(add-hook 'clojure-mode-hook 'rainbow-delimiters-mode)
(add-hook 'clojure-mode-hook 'paredit-mode)

;; Configure CIDER and nREPL
;(add-hook 'clojure-mode-hook 'turn-on-eldoc-mode)
(setq nrepl-popup-stacktraces nil)
(add-to-list 'same-window-buffer-names "<em>nrepl</em>")
(setq cider-repl-history-file "~/REPL/history.clj")
(add-hook 'cider-repl-mode-hook 'paredit-mode)

;; General Auto-Complete
(require 'auto-complete-config)
(setq ac-delay 0.0)
(setq ac-quick-help-delay 0.5)
(ac-config-default)

;; Have eldoc in CIDER
(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)

;; ac-nrepl (Auto-complete for the nREPL)
;(require 'ac-nrepl)
;(add-hook 'cider-mode-hook 'ac-nrepl-setup)
;(add-hook 'cider-repl-mode-hook 'ac-nrepl-setup)
;(add-to-list 'ac-modes 'cider-mode)
;(add-to-list 'ac-modes 'cider-repl-mode)

;; Poping-up contextual documentation
;(eval-after-load "cider"
;  '(define-key cider-mode-map (kbd "C-c C-d") 'ac-nrepl-popup-doc))

;;;; Behaviour

;; Start up with color theme ample
(load-theme 'ample t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(custom-safe-themes (quote ("7a9f392481b6e2fb027ab9d8053ab36c0f23bf5cc1271206982339370d894c74" "d8a4e35ee1b219ccb8a8c15cdfed687fcc9d467c9c8b9b93bd25229b026e4703" default)))
 '(org-agenda-files (quote ("~/Org/web_scraping.org")))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "DejaVu Sans Mono" :foundry "outline" :slant normal :weight normal :height 98 :width normal)))))

;; Prevent carriage returns from being printed when a buffer's file encoding is mixed
(defun remove-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))

(add-hook 'prog-mode-hook 'remove-dos-eol)
(add-hook 'compilation-mode-hook 'remove-dos-eol)
(add-hook 'cider-repl-mode-hook 'remove-dos-eol)


;; Transparently make implicitly declared directories
(defadvice find-file (before make-directory-maybe (filename &optional wildcards) activate)
  "Create parent directory if not exists while visiting file."
  (unless (file-exists-p filename)
    (let ((dir (file-name-directory filename)))
      (unless (file-exists-p dir)
        (make-directory dir)))))

;; Configure org-mode LaTeX export
;;(add-to-list 'org-export-latex-classes
;;	     '("letter"
;;	       "\\documentclass{letter}"))

;;(add-to-list 'org-latex-packages-alist
;;	     '("tabularx"))

;; Indent Clojure at syntax-level
(define-key global-map (kbd "RET") 'newline-and-indent)
;;(put 'if 'clojure-indent-function 3)
