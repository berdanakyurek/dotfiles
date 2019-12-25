;; Initialization
(setq gc-cons-threshold 64000000)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq-default use-package-always-defer t)
; (setq-default use-package-always-ensure t)
(setq custom-file "~/.emacs.d/elisp/custom.el")
(load custom-file)

(add-to-list 'load-path (concat user-emacs-directory "elisp/"))
(add-to-list 'load-path "/usr/share/emacs/site-lisp/")
(add-to-list 'custom-theme-load-path (concat user-emacs-directory "elisp/"))
;; Init Done


;; Debug
;; (require 'benchmark-init)
;; (add-hook 'after-init-hook 'benchmark-init/deactivate)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          Defaults & Built-ins          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq-default user-full-name "Furkan Usta"
              user-mail-address "furkanusta17@gmail.com"
              user-bibliography "~/Documents/Nextcloud/Papers/Library.bib"
              save-interprogram-paste-before-kill t
              emacs-load-start-time (current-time)
              ad-redefinition-action 'accept
              ;; backup-inhibited t
              calendar-week-start-day 1
              delete-by-moving-to-trash t
              confirm-nonexistent-file-or-buffer nil
              tab-width 4
              tab-stop-list (number-sequence 4 200 4)
              indent-tabs-mode nil
              backup-directory-alist `(("." . "~/.emacs.d/.gen"))
              auto-save-file-name-transforms `((".*" "~/.emacs.d/.gen/" t))
              ediff-window-setup-function 'ediff-setup-windows-plain
              ediff-split-window-function 'split-window-horizontally
              gdb-many-windows t
              use-file-dialog nil
              use-dialog-box nil
              inhibit-startup-screen t
              inhibit-startup-echo-area-message t
              inhibit-startup-screen t
              cursor-type 'bar
              ring-bell-function 'ignore
              scroll-step 1
              sentence-end-double-space -1
              fill-column 100
              scroll-step 1
              scroll-conservatively 10000
              initial-major-mode 'org-mode
              auto-window-vscroll nil
              comint-prompt-read-only t
              vc-follow-symlinks t
              scroll-preserve-screen-position t
              frame-resize-pixelwise t
              display-time-default-load-average nil
              display-time-24hr-format t
              undo-limit 1280000
              font-use-system-font t)

;; These are not usable with use-package
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-hl-line-mode)
(global-display-line-numbers-mode t)
(blink-cursor-mode 0)
(show-paren-mode 1)
(fset 'yes-or-no-p 'y-or-n-p)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; ;; These are built-in packages and having ensure results in lots of warnings
;; (use-package desktop
;;   :ensure nil
;;   :init (desktop-save-mode 1)
;;   :config (add-to-list 'desktop-modes-not-to-save 'dired-mode))

(use-package dired
  :ensure nil
  :config (setq-default
           dired-listing-switches "-vaBhl  --group-directories-first"
           dired-dwim-target t))

(use-package delsel
  :ensure nil
  :init (delete-selection-mode 1))

(use-package flyspell)

(use-package hideshow
  :diminish hs-minor-mode
  :hook (prog-mode . hs-minor-mode)
  :bind
  ("C-c C-," . hs-toggle-hiding)
  ("C-c C-." . hs-hide-all)
  ("C-c C->" . hs-show-all))

(use-package recentf
  :ensure nil
  :init (recentf-mode t)
  :config (setq-default recent-save-file "~/.emacs.d/recentf"))

(use-package saveplace
  :ensure nil
  :init (save-place-mode 1)
  :config (setq-default server-visit-hook (quote (save-place-find-file-hook))))

(use-package uniquify
  :ensure nil
  :config
  (setq-default uniquify-buffer-name-style 'reverse
                uniquify-separator " • "
                uniquify-after-kill-buffer-p t
                uniquify-ignore-buffers-re "^\\*"))

(use-package windmove
  :bind (("C-c <left>" . windmove-left)
         ("C-c <right>" . windmove-right)
         ("C-c <up>" . windmove-up)
         ("C-c <down>" . windmove-down)))

(use-package which-func :init (which-function-mode t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          Functions and keybindings    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun duplicate-line-or-region (arg)
  (interactive "p")
  (let (beg end (origin (point)))
    (if (and mark-active (> (point) (mark)))
        (exchange-point-and-mark))
    (setq beg (line-beginning-position))
    (if mark-active
        (exchange-point-and-mark))
    (setq end (line-end-position))
    (let ((region (buffer-substring-no-properties beg end)))
      (dotimes (i arg)
        (goto-char end)
        (newline)
        (insert region)
        (setq end (point)))
      (goto-char (+ origin (* (length region) arg) arg)))))

(defun my-align-comments (beginning end)
  (interactive "*r")
  (let (indent-tabs-mode align-to-tab-stop)
    (align-regexp beginning end "\\(\\s-*\\)//")))

(defun kill-other-buffers ()
  (interactive)
  (mapc 'kill-buffer
        (delq (current-buffer) (buffer-list))))

(defun xah-cut-line-or-region ()
  (interactive)
  (if current-prefix-arg
      (progn
        (kill-new (buffer-string))
        (delete-region (point-min) (point-max)))
    (progn (if (use-region-p)
               (kill-region (region-beginning) (region-end) t)
             (kill-region (line-beginning-position) (line-beginning-position 2))))))

(defun xah-copy-line-or-region ()
  (interactive)
  (let (-p1 -p2)
    (if (use-region-p)
        (setq -p1 (region-beginning) -p2 (region-end))
      (setq -p1 (line-beginning-position) -p2 (line-end-position)))
    (progn
      (kill-ring-save -p1 -p2)
      (message "Text copied"))))

(defun endless/fill-or-unfill ()
  "Like `fill-paragraph', but unfill if used twice."
  (interactive)
  (let ((fill-column
         (if (eq last-command 'endless/fill-or-unfill)
             (progn (setq this-command nil) (point-max))
           fill-column)))
    (call-interactively #'fill-paragraph)))

(defun scroll-down-in-place (n)
  (interactive "p")
  (forward-line (* -1 n))
  (unless (eq (window-start) (point-min))
    (scroll-down n)))

(defun scroll-up-in-place (n)
  (interactive "p")
  (forward-line n)
  (unless (eq (window-end) (point-max))
    (scroll-up n)))

(global-set-key (kbd "M-n") 'scroll-up-in-place)
(global-set-key (kbd "M-p") 'scroll-down-in-place)
(global-set-key (kbd "<f7>") 'eww)
(global-set-key (kbd "<f8>") 'shell)
(global-set-key (kbd "C-M-;") 'my-align-comments)
(global-set-key (kbd "C-c C-k") 'kill-other-buffers)
(global-set-key (kbd "C-c d") 'duplicate-line-or-region)
(global-set-key (kbd "C-c e r") 'eval-region)
(global-set-key (kbd "C-S-d") 'delete-backward-char)
(global-set-key (kbd "M-D") 'backward-kill-word)
(global-set-key (kbd "C-w") 'xah-cut-line-or-region) ; cut
(global-set-key (kbd "M-k") 'kill-whole-line)
(global-set-key (kbd "M-w") 'xah-copy-line-or-region) ; copy
(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key [remap fill-paragraph] #'endless/fill-or-unfill)
(define-key prog-mode-map (kbd "<tab>") 'indent-for-tab-command)

(use-package dashboard
  :ensure t
  :init (dashboard-setup-startup-hook)
  :config (setq initial-buffer-choice (lambda () (get-buffer "*dashboard*"))
                dashboard-center-content t
                dashboard-startup-banner 'logo
                dashboard-items '((recents  . 5)
                                  (bookmarks . 5)
                                  (projects . 5)
                                  (agenda . 5))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          Helm          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helm packages for other modules will be near their corresponding modules, not in here

(use-package helm
  :diminish helm-mode
  :commands helm-autoresize-mode
  :init
  (require 'helm-config)
  (helm-mode 1)
  (helm-autoresize-mode 1)
  (global-unset-key (kbd "C-x c"))
  :bind
  (("C-x C-f" . helm-find-files)
   ("M-x" . helm-M-x)
   ("C-s" . helm-occur)
   ("C-x b" . helm-mini)
   ("C-z" .  helm-select-action)
   ("M-y" . helm-show-kill-ring)
   ("C-c s" . isearch-forward)
   ("C-c C-r" . helm-resume)
   ("<f6>" . helm-imenu)
   :map helm-map
   ("<tab>" . helm-execute-persistent-action)
   ("<left>" . helm-previous-source)
   ("<right>" . helm-next-source))
  :config
  (setq helm-split-window-inside-p t
        helm-move-to-line-cycle-in-source t
        helm-scroll-amount 8)
  (setq-default helm-ff-search-library-in-sexp t
                helm-ff-file-name-history-use-recentf t
                helm-ff-allow-non-existing-file-at-point nil
                helm-ff-auto-update-initial-value t
                helm-ff-guess-ffap-filenames t
                helm-ff-guess-ffap-urls nil
                helm-semantic-fuzzy-match t
                helm-M-x-fuzzy-match t
                helm-imenu-fuzzy-match t
                helm-substitute-in-filename-stay-on-remote t
                helm-boring-buffer-regexp-list (list (rx "*magit-") (rx "*helm") (rx "*flycheck"))))

(use-package helm-bibtex
  :config
  (setq-default bibtex-completion-bibliography user-bibliography
                bibtex-completion-library-path "~/Documents/Nextcloud/Papers/"
                bibtex-completion-display-formats '((t . "${=has-pdf=:1}     ${author:50}   | ${year:4} |   ${title:150}"))
                bibtex-completion-notes-path "~/Documents/Nextcloud/Notes/helm-bibtex-notes"))

(use-package helm-tramp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          Visual          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package all-the-icons)

(use-package display-time :init (display-time-mode))

(use-package column-number :init (column-number-mode))

(use-package doom-modeline :init (doom-modeline-mode))

(use-package diminish)

(use-package my-darkokai-theme
  :init (load-theme 'my-darkokai t)
  :config (setq my-darkokai-mode-line-padding 4))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          Tools & Utils          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun disable-line-numbers ()
  (display-line-numbers-mode -1))

(defun toggle-line-numbers ()
  (display-line-numbers-mode (or (not display-line-numbers-mode) 0)))

(use-package image-mode
  :ensure nil
  :hook (image-mode . disable-line-numbers))

(use-package image+
  :after image-mode
  :bind (:map image-mode-map
         ("C-+" . imagex-sticky-zoom-in)
         ("C--" . imagex-sticky-zoom-out)
         ("C-0" . imagex-sticky-restore-original)))

(use-package elfeed
  :config
  (setq-default elfeed-feeds
                '(("http://research.swtch.com/feeds/posts/default" other)
                  ("http://bitbashing.io/feed.xml" other)
                  ("http://preshing.com/feed" other)
                  ("http://danluu.com/atom.xml" other)
                  ("http://tenderlovemaking.com/atom.xml" other)
                  ("http://feeds.feedburner.com/codinghorror/" other)
                  ("http://www.snarky.ca/feed" other)
                  ("http://blog.regehr.org/feed" cpp)
                  ("https://blog.acolyer.org/feed/" other)
                  ("https://www.reddit.com/r/cpp/top/.rss?t=week" cpp)
                  ("https://www.reddit.com/r/programmin/top/.rss?t=month" prog)
                  ("https://www.reddit.com/r/python/top/.rss?t=month" python)
                  ("https://www.reddit.com/r/java/top/.rss?t=month" java)
                  ("https://randomascii.wordpress.com/" other)
                  ("http://planet.emacsen.org/atom.xml" emacs)
                  ("http://planet.gnome.org/rss20.xml" gnome)
                  ("http://arne-mertz.de/feed/" cpp)
                  ("http://zipcpu.com/" fpga)
                  ("https://code-cartoons.com/feed" other)
                  ("https://eli.thegreenplace.net/feeds/all.atom.xml" cpp)
                  ("https://www.evanjones.ca/index.rss" other)
                  ("https://jvns.ca/atom.xml" other)
                  ("https://aphyr.com/posts.atom" other)
                  ("https://brooker.co.za/blog/rss.xml" other)
                  ("https://rachelbythebay.com/w/atom.xml" other)
                  ("https://mrale.ph/feed.xml" other)
                  ("https://medium.com/feed/@steve.yegge" other)
                  ("https://research.swtch.com/" other)
                  ("https://medium.theuxblog.com/feed" ux)
                  ("https://feeds.feedburner.com/uxmovement" ux)
                  ("http://aras-p.info/atom.xml" other)
                  ("http://city-journal.org/rss" other)
                  ("https://writing.kemitchell.com/feed.xml" other)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UC2eEGT06FrWFU6VBnPOR9lg" youtube)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCO-_F5ZEUhy0oKrSa69DLMw" youtube)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UC-xTvXTm-lrLWYk308-Km3A" youtube)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UC7dF9qfBMXrSlaaFFDvV_Yg" youtube)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCK6XWOay4sher8keh2x1jLA" youtube)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCU1Fhn0o5S0_mdcgwCPuLDg" youtube)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCsvn_Po0SmunchJYOWpOxMg" youtube)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UClJ7gpJ9MRXDnbA8N_5NSKQ" youtube)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCaYhcUwRBNscFNUKTjgPFiA" youtube prog)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UC5DNdmeE-_lS6VhCVydkVvQ" youtube prog)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UChti8oyWC3oW91LpfZ2bmSQ" youtube cpp)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCAczr0j6ZuiVaiGFZ4qxApw" youtube cpp)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCJpMLydEYA08vusDkq3FmjQ" youtube cpp)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCQ4JGczdlU3ofHWf3NuCX8g" youtube cpp)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCv2_41bSAa5Y_8BacJUZfjQ" youtube cpp)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCMlGfpWw-RUdWX_JbLCukXg" youtube cpp)
                  ("https://www.youtube.com/feeds/videos.xml?channel_id=UC5e__RG9K3cHrPotPABnrwg" youtube cpp)
                  ("http://xkcd.com/rss.xml" xkcd))))

(use-package vlf
  :after dired
  :hook (vlf-view-mode . disable-line-numbers)
  :init (require 'vlf-setup)
  (add-to-list 'vlf-forbidden-modes-list 'pdf-view-mode))

(defun pdf-view-page-number ()
  (interactive)
  (message " [%s/%s]"
           (number-to-string (pdf-view-current-page))
           (number-to-string (pdf-cache-number-of-pages))))


;; workaround for pdf-tools not reopening to last-viewed page of the pdf:
;; https://github.com/politza/pdf-tools/issues/18#issuecomment-269515117
;; (use-package bookmark+
;;   :load-path "elisp/bookmark-plus/"
;;   :config
;;   (setq-default bookmarks-pdf "~/.emacs.d/bookmarks-pdf"))

;; requires pdf-tools-install
(use-package pdf-tools
  :hook ((pdf-view-mode . (lambda () (cua-mode 0)))
         (pdf-view-mode . disable-line-numbers)
         (pdf-view-mode . pdf-view-midnight-minor-mode))
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (setq-default pdf-view-display-size 'fit-page
                pdf-annot-activate-created-annotations nil
                pdf-view-resize-factor 1.1)
  :bind (:map pdf-view-mode-map ("t" . pdf-view-page-number)))

(use-package pdf-view-restore
  :after pdf-tools
  :config
  (add-hook 'pdf-view-mode-hook 'pdf-view-restore-mode)
  (setq-default pdf-view-restore-filename "~/.emacs.d/.pdf-view-restore"))

(use-package undo-tree
  :diminish undo-tree-mode
  :config
  (global-undo-tree-mode 1)
  (setq-default undo-tree-visualizer-timestamps t
                undo-tree-visualizer-diff t)
  :bind
  ("C-+" . undo-tree-redo)
  ("C-_" . undo-tree-undo))

(use-package immortal-scratch :init (immortal-scratch-mode t))

(use-package yasnippet
  :diminish yas-minor-mode
  :config (yas-global-mode 1)
  :bind ("M-i" . yas-expand)
  (:map yas-minor-mode-map ("<tab>" . nil)))


(use-package pocket-reader
  :bind
  (:map elfeed-search-mode-map
        ("P" . pocket-reader-add-link)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          Programming Tools          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Generic
(use-package company
  :diminish company-mode
  :commands company-complete
  :hook (after-init . global-company-mode)
  :bind ("<C-tab>" . (function company-complete))
  :config (setq-default company-idle-delay nil))

;; ;; Doesn't work with company-quickhelp but can provide fuzzy matching where company-flx cannot
;; (use-package helm-company
;;   :after company
;;   :bind ("<C-tab>" . (function helm-company)))

(use-package company-quickhelp :init (company-quickhelp-mode t))

(use-package helm-ag
  ;; :init (custom-set-variables '(helm-follow-mode-persistent t))
  :bind
  ("C-c h p" . helm-do-ag-project-root)
  ("C-c h s" .  helm-do-ag)
  ("C-c h S" . helm-ag))

(use-package magit
  :bind ("C-c g s" . magit-status))

(use-package magit-todos :init (magit-todos-mode))

(use-package diff-hl :config (setq-default global-diff-hl-mode t))

(use-package hl-todo :config (global-hl-todo-mode))

(use-package flycheck
  :init (global-flycheck-mode)
  :config
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc verilog-verilator)))

(use-package helm-flycheck
  :after flycheck
  :bind (:map flycheck-mode-map ("C-c h f" . helm-flycheck)))

(use-package evil-nerd-commenter :bind ("M-;" . evilnc-comment-or-uncomment-lines))

(use-package projectile
  :init (projectile-mode 1)
  :config (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

(use-package helm-projectile)

(use-package visual-regexp-steroids
  :init (require 'visual-regexp-steroids)
  :bind ("C-r" . vr/replace))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          Navigation          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package bm
  :init (setq-default
         bm-restore-repository-on-load t
         bm-repository-file "~/.emacs.d/bm-repository"
         bm-buffer-persistence t)
  :hook (find-file-hooks . bm-buffer-restore)
  :config (setq-default bm-cycle-all-buffers t)
  :bind
  ("C-c b b" . bm-toggle)
  ("C-c b n" . bm-next)
  ("C-c b p" . bm-previous))

(use-package helm-bm
  :bind
  ("C-c b h" . helm-bm))

(use-package buffer-move
  :bind
  ("C-c S-<up>"    . buf-move-up)
  ("C-c S-<down>"  . buf-move-down)
  ("C-c S-<left>"  . buf-move-left)
  ("C-c S-<right>" . buf-move-right))

(use-package drag-stuff
  :diminish drag-stuff-mode
  :init (drag-stuff-global-mode t)
  :bind (:map drag-stuff-mode-map
         ("<M-up>" . drag-stuff-up)
         ("<M-down>" . drag-stuff-down)))

(use-package eyebrowse
  :init (eyebrowse-mode t)
  :config (setq-default eyebrowse-wrap-around t)
  :bind
  (:map eyebrowse-mode-map
        ("C-c C-w <left>" . eyebrowse-prev-window-config)
        ("C-c C-w l" . eyebrowse-switch-to-window-config)
        ("C-c C-w <right>" . eyebrowse-next-window-config)))

(use-package hungry-delete
  :commands global-hungry-delete-mode
  :init (global-hungry-delete-mode))

(use-package goto-chg :bind ("C-c g ;" . goto-last-change))

(use-package dired-single
  :bind
  (:map dired-mode-map
        ("<return>" . dired-single-buffer)
        ("C-<" . dired-single-up-directory)))

(use-package writeroom-mode
  :init (setq-default writeroom-width 150)
  :bind ("C-c w r" . writeroom-mode)
  :hook (writeroom-mode . toggle-line-numbers))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          Org Mode          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package org
  :config
  (setq-default org-src-fontify-natively t
                org-directory "~/Documents/Nextcloud/Notes"
                org-catch-invisible-edits 'show-and-error
                org-yank-adjusted-subtrees t
                org-hide-emphasis-markers t
                org-src-tab-acts-natively t
                org-edit-src-content-indentation 0
                org-fontify-quote-and-verse-blocks t
                org-cycle-separator-lines 0
                org-src-preserve-indentation nil
                org-imenu-depth 4)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     ;; (http . t)
     (shell . t)
     (emacs-lisp . t)))
  :hook
  (org-mode . turn-on-flyspell)
  (org-mode . auto-fill-mode)
  :bind (:map org-mode-map ("C-c C-." . org-time-stamp-inactive)))

(defadvice org-mode-flyspell-verify (after org-mode-flyspell-verify-hack activate)
  (let* ((rlt ad-return-value)
         (begin-regexp "^[ \t]*#\\+begin_\\(src\\|html\\|latex\\|example\\|quote\\)")
         (end-regexp "^[ \t]*#\\+end_\\(src\\|html\\|latex\\|example\\|quote\\)")
         (case-fold-search t)
         b e)
    (when ad-return-value
      (save-excursion
        (setq b (re-search-backward begin-regexp nil t))
        (if b (setq e (re-search-forward end-regexp nil t))))
      (if (and b e (< (point) e)) (setq rlt nil)))
    (setq ad-return-value rlt)))

(use-package org-journal
  :config
  (setq-default org-journal-dir (concat org-directory "/journal/")
                org-journal-carryover-items nil)
  :bind ("C-c i j" . org-journal-new-entry))

(use-package org-agenda
  :bind ("C-c a" . org-agenda)
  :config (setq-default org-agenda-files (list org-directory)))

;; (defun my/org-ref-open-pdf-at-point ()
;;   "Open the pdf for bibtex key under point if it exists."
;;   (interactive)
;;   (let* ((key (thing-at-point 'filename t))
;;          (pdf-file (funcall org-ref-get-pdf-filename-function key)))
;;     (if (file-exists-p pdf-file)
;;         (find-file pdf-file)
;;       (message "No PDF found for %s" key))))

(use-package org-ref
  :config
  (setq-default reftex-default-bibliography (list user-bibliography)
                org-ref-bibliography-notes (concat org-directory "/Readings.org")
                org-ref-default-bibliography (list user-bibliography)
                org-ref-pdf-directory "~/Documents/Nextcloud/Papers/"
                ;; org-ref-open-pdf-function 'my/org-ref-open-pdf-at-point)
                ))

(use-package ox-latex
  :config
  (setq-default org-latex-pdf-process
                '("pdflatex -interaction nonstopmode -output-directory %o %f"
                  "bibtex %b"
                  "pdflatex -interaction nonstopmode -output-directory %o %f"
                  "pdflatex -interaction nonstopmode -output-directory %o %f")))

(use-package ox)

(use-package ox-hugo
  :after ox)

(use-package org-cliplink
  :bind
  (:map org-mode-map
        ("C-c i l" . org-cliplink)))

;; (use-package interleave
;;   :config
;;   ;; (setq-default interleave-org-notes-dir-list '("~/Documents/Nextcloud/Papers/"))
;;   (setq-default interleave-disable-narrowing t))

(use-package biblio)

(use-package bibtex
  :init
  (setq-default bibtex-maintain-sorted-entries t
                bibtex-align-at-equal-sign t
                bibtex-comma-after-last-field t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          C++          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ccls vs cquery: Overall ccls seems better.
;; ccls vs rtags : It looks like rtags has couple more features, but I had some problems setting it up before

(use-package cc-mode
  :ensure nil
  :mode ("\\.h\\'" . c++-mode)
  :config
  (c-set-offset 'substatement-open 0)
  (c-set-offset 'innamespace 0)
  (custom-set-variables '(c-noise-macro-names '("constexpr")))
  (setq-default c-default-style "stroustrup"
                c-basic-offset 4
                c-indent-level 4
                access-label 0
                tab-stop-list '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60)
                tab-width 4
                indent-tabs-mode nil)
  (with-eval-after-load 'flycheck
    (setq-default flycheck-clang-language-standard "c++1z"
                flycheck-gcc-language-standard "c++1z"
                flycheck-cppcheck-standards "c++1z"
                flycheck-clang-standard-library "libc++")
                ;; flycheck-disabled-checkers '(c/c++-clang))
    (flycheck-add-mode 'c/c++-cppcheck 'c/c++-gcc)
    (flycheck-add-mode 'c/c++-cppcheck 'c/c++-clang)))

(use-package modern-cpp-font-lock
  :diminish modern-c++-font-lock-mode
  :hook (c++-mode . modern-c++-font-lock-mode))

(use-package cmake-mode)

(use-package cmake-font-lock :hook (cmake-mode . cmake-font-lock-activate))

(use-package lsp-mode
  :hook (scala-mode . lsp)
  :init
  (setq-default lsp-auto-execute-action nil
                lsp-before-save-edits nil
                lsp-auto-guess-root t
                lsp-prefer-flymake :none
                lsp-enable-indentation nil
                lsp-enable-snippet nil
                lsp-enable-on-type-formatting nil))

(use-package company-lsp
  :after company
  :config (push 'company-lsp company-backends))

(use-package helm-lsp)

(use-package xref
  :config (setq-default xref-show-xrefs-function 'helm-xref-show-xrefs))

(use-package company-c-headers
  :after company
  :init (add-to-list 'company-backends 'company-c-headers))

;; (use-package flycheck-clang-analyzer
;;   :after flycheck
;;   :config (flycheck-clang-analyzer-setup))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          Perl          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package cperl-mode
  :ensure nil
  :init (defalias 'perl-mode 'cperl-mode)
  :config
  (setq-default cperl-indent-level 4
                cperl-close-paren-offset -4
                cperl-continued-statement-offset 4
                cperl-indent-parens-as-block t
                cperl-tab-always-indent nil)
  (with-eval-after-load 'flycheck (flycheck-add-mode 'perl-perlcritic 'perl)))


;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;          Scala          ;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package scala-mode
  :interpreter ("scala" . scala-mode))

(use-package sbt-mode
  :commands sbt-start sbt-command
  :config
  (setq-default sbt:program-options '("-Dsbt.supershell=false" "-mem" "16384"))
  ;; WORKAROUND: allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          Python          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Although elpy provide refactoring, goto-defitnition didn't work and it messes with defaults
;;   (even though sane defaults weren't selected).
;; jedi is also fine but I am continouing with anaconda simply because I used it before and
;;   since I am not working on huge projects I didn't encounter any performacne issues

(use-package virtualenvwrapper :init (venv-initialize-interactive-shells))
(use-package auto-virtualenvwrapper :after virtualenvwrapper)

;; (use-package anaconda-mode)

;; (use-package company-anaconda
;;   :after company
;;   :init (add-to-list 'company-backends 'company-anaconda))

(use-package python
  :hook ((python-mode . auto-virtualenvwrapper-activate)))
         ;; (python-mode . anaconda-mode)
         ;; (python-mode . anaconda-eldoc-mode)))

;; (use-package flycheck-pycheckers
;;   :after flycheck
;;   :hook (flycheck-mode . flycheck-pycheckers-setup)
;;   :config (setq-default flycheck-pycheckers-checkers '(flake8 pyflakes)
;;                         flycheck-pycheckers-max-line-length 100))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;            Shell          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun colorize-compilation-buffer ()
  (read-only-mode)
  (ansi-color-apply-on-region (point-min) (point-max))
  (read-only-mode -1))

(use-package ansi-color
  :commands ansi-color-apply-on-region
  :hook (compilation-filter . colorize-compilation-buffer)
  :config
  (add-to-list 'comint-output-filter-functions 'ansi-color-process-output)
  (autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t))

(use-package shell
  :bind (:map shell-mode-map ("<tab>" . completion-at-point)))

(add-to-list 'auto-mode-alist '("\\.v\\'" . fundamental-mode))

;; Broken
;; (use-package readline-complete)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;          Docker          ;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (use-package dockerfile-mode :mode ("Dockerfile\\'" "\\.docker"))

;; (use-package docker-compose-mode :mode ("docker-compose\\.yml\\'" "-compose.yml\\'"))

;; (use-package docker-tramp)
