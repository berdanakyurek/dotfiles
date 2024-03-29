;; -*- lexical-binding: t; -*-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          Org Mode          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package org :ensure nil
  :config
  (defvar org-capture-file (concat my-notes-directory "/Capture.org"))
  (setq org-default-notes-file org-capture-file)
  (require 'org-tempo)
  :custom
  (org-startup-folded 'content)
  (org-adapt-indentation t)
  (org-catch-invisible-edits 'show-and-error)
  (org-cycle-separator-lines 0)
  (org-edit-src-content-indentation 0)
  (org-fontify-quote-and-verse-blocks t)
  (org-fontify-done-headline t)
  (org-fontify-whole-heading-line t)
  (org-hide-emphasis-markers t)
  (org-hide-leading-stars t)
  (org-imenu-depth 4)
  (org-indent-indentation-per-level 1)
  (org-log-done t)
  ;; (org-pretty-entities t)
  (org-src-fontify-natively t)
  (org-src-preserve-indentation nil)
  (org-src-tab-acts-natively t)
  (org-yank-adjusted-subtrees t)
  (org-todo-keywords '((sequence "TODO" "IN-PROGRESS" "NEXT" "|" "DONE")
                       (sequence "PAUSED" "SCHEDULED" "WAITING" "|"  "CANCELLED")))
  :hook
  (org-mode . turn-on-flyspell)
  (org-mode . auto-fill-mode)
  (org-mode . smartparens-mode)
  :bind (:map org-mode-map ("C-c C-." . org-time-stamp-inactive))
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (shell . t)
     (emacs-lisp . t))))

(use-package ob-async)

(use-package org-alert
  :commands org-alert-enable
  :config (org-alert-enable))

(use-package org-fragtog
  :hook (org-mode . org-fragtog-mode))

(use-package org-cliplink
  :bind (:map org-mode-map ("C-c i l" . org-cliplink)))

(use-package org-capture :ensure nil
  :after org
  :custom
  (org-capture-templates '(("t" "TODO" entry (file+headline org-capture-file "Tasks")
  						    "* TODO %?\n	%a\n  %i\n")
  					       ("j" "Journal" entry (file+headline org-capture-file "Journal")
  						    "* %U\n	 %a\n	 %i")
  					       ("p" "Protocol" entry (file+headline org-capture-file "Inbox")
  	    				    "* %?\n	 [[%:link][%:description]]\n	%U\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n")
  	    			       ("L" "Protocol Link" entry (file+headline org-capture-file "Inbox")
  						    "* %?\n	 [[%:link][%:description]]\n	%U")))
  :bind ("C-c c" . org-capture))

(use-package org-table :ensure nil
  :preface
  (defun my-org-copy-table-cell ()
    (interactive)
    (when (org-at-table-p)
      (kill-new
       (string-trim
        (substring-no-properties(org-table-get-field))))))
  :bind
  (:map org-mode-map
        ("M-W" . my-org-copy-table-cell)))


(use-package org-protocol :ensure nil)

(use-package org-agenda :ensure nil
  :custom
  (org-agenda-files (list my-notes-directory))
  (org-agenda-include-diary t)
  (org-agenda-span 10)
  (org-agenda-start-day "-2d")
  :bind ("C-c a" . org-agenda))

(use-package org-refile :ensure nil
  :custom
  (org-refile-use-outline-path t)
  (org-refile-targets '((nil :maxlevel . 9)
                        (org-agenda-files :maxlevel . 9)))
  (org-refile-allow-creating-parent-nodes 'confirm))

(use-package org-clock :ensure nil
  :custom
  (org-clock-out-remove-zero-time-clocks t)
  (org-clock-report-include-clocking-task t)
  (org-clock-out-when-done t))

(use-package org-appear
  ;; :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autolinks t)
  (org-appear-autosubmarkers t)
  (org-appear-autoentities t))

(use-package oc
  :ensure org
  :demand t
  :custom
  (org-cite-export-processors '((latex biblatex) (t csl)))
  (org-support-shift-select t))

(use-package oc-biblatex :after oc :ensure org)
(use-package oc-csl :after oc :ensure org)
(use-package oc-natbib :after oc :ensure org)

(use-package toc-org
  :hook (org-mode . toc-org-mode))

(use-package org-pretty-table
  :quelpa (org-pretty-table :fetcher github :repo "Fuco1/org-pretty-table")
  :hook (org-mode . org-pretty-table-mode))

(use-package org-table-sticky-header)

(use-package org-sticky-header
  :hook (org-mode . org-sticky-header-mode)
  :custom (org-sticky-header-always-show-header nil))

(use-package org-ref
  :demand t
  :custom
  (org-ref-bibliography-notes (concat my-notes-directory "/Papers.org"))
  (org-ref-default-bibliography (list my-bibliography))
  (org-ref-pdf-directory (concat my-data-directory "/Papers/"))
  (org-ref-show-broken-links t))

(use-package org-ref-prettify
  :after org-ref
  :hook (org-mode . org-ref-prettify-mode))

(use-package org-pdftools
  :hook (org-mode . org-pdftools-setup-link))

(use-package org-noter-pdftools
  :after org-noter
  :config
  (defun org-noter-pdftools-insert-precise-note (&optional toggle-no-questions)
    (interactive "P")
    (org-noter--with-valid-session
     (let ((org-noter-insert-note-no-questions (if toggle-no-questions
                                                   (not org-noter-insert-note-no-questions)
                                                 org-noter-insert-note-no-questions))
           (org-pdftools-use-isearch-link t)
           (org-pdftools-use-freestyle-annot t))
       (org-noter-insert-note (org-noter--get-precise-info)))))
  ;; fix https://github.com/weirdNox/org-noter/pull/93/commits/f8349ae7575e599f375de1be6be2d0d5de4e6cbf
  (defun org-noter-set-start-location (&optional arg)
    "When opening a session with this document, go to the current location.
With a prefix ARG, remove start location."
    (interactive "P")
    (org-noter--with-valid-session
     (let ((inhibit-read-only t)
           (ast (org-noter--parse-root))
           (location (org-noter--doc-approx-location (when (called-interactively-p 'any) 'interactive))))
       (with-current-buffer (org-noter--session-notes-buffer session)
         (org-with-wide-buffer
          (goto-char (org-element-property :begin ast))
          (if arg
              (org-entry-delete nil org-noter-property-note-location)
            (org-entry-put nil org-noter-property-note-location
                           (org-noter--pretty-print-location location))))))))
  (with-eval-after-load 'pdf-annot
    (add-hook 'pdf-annot-activate-handler-functions #'org-noter-pdftools-jump-to-note)))

(use-package org-noter
  :quelpa (org-noter :fetcher github :repo "furkanusta/org-noter")
  :custom
  (org-noter-notes-search-path (list my-notes-directory))
  (org-noter-always-create-frame nil)
  (org-noter-doc-split-fraction (cons 0.7  0.3))
  (org-noter-kill-frame-at-session-end nil)
  (org-noter-default-notes-file-names (list "Notes.org"))
  (org-noter-auto-save-last-location t)
  (org-noter-insert-note-no-questions t))

(use-package org-special-block-extras)

(use-package org-remark
  :quelpa (org-remark :fetcher github :repo "nobiot/org-remark")
  :bind
  (:map org-remark-mode-map
        ("C-c i m" . org-remark-mark)
        ("C-c m o" . org-remark-open)
        ("C-c m r" . org-remark-remove)
        ("C-c m ]" . org-remark-next)
        ("C-c m [" . org-remark-prev)))

(use-package org-journal
  :bind ("C-c i j" . org-journal-new-entry)
  :custom
  (org-journal-dir (concat my-notes-directory "/Journal"))
  (org-journal-file-format "%Y-%m-%d.org"))

(use-package org-super-links
  :quelpa (org-super-links :fetcher github :repo "toshism/org-super-links"))

(use-package binder
  :custom (binder-default-file-extension "org"))

(use-package inherit-org
  :quelpa (inherit-org :repo "chenyanming/inherit-org" :fetcher github)
  :hook ((eww-mode nov-mode info-mode helpful-mode) . inherit-org-mode))

(use-package shrface
  :after org
  :commands (shrface-basic shrface-trial shrface-outline-cycle org-at-heading-p)
  :config
  (shrface-basic)
  (shrface-trial)
  :preface
  (defun org-tab-or-next-heading ()
    (interactive)
    (if (org-at-heading-p)
        (shrface-outline-cycle)
      (progn
        (org-next-visible-heading 1)
        (unless (org-at-heading-p)
          (org-previous-visible-heading 1)))))
  :hook (inherit-org-mode . shrface-mode)
  :custom (shrface-href-versatile t)
  :bind (:map shrface-mode-map
              ("TAB" . #'org-tab-or-next-heading)
              ("<backtab>" . shrface-outline-cycle-buffer)
              ("M-<down>" . org-next-visible-heading)
              ("M-<up>" . org-previous-visible-heading)))

(use-package ob-ipython
  :hook (org-babel-after-execute . org-display-inline-images)
  :config
  (add-to-list 'org-latex-minted-langs '(ipython "python"))
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((ipython . t))))

(use-package org-transclusion
  :quelpa (org-transclusion :fetcher github :repo "nobiot/org-transclusion")
  ;; :hook (org-mode . org-transclusion-mode)
  :custom (org-transclusion-activate-persistent-message nil))

(use-package org-ql)

(use-package org-super-links
  :quelpa (org-super-links :fetcher github :repo "toshism/org-super-links")
  :bind (:map org-mode-map
              ("C-c s l" . org-super-links-link)
              ("C-c s d" . org-super-links-delete-link)
              ("C-c s s" . org-super-links-store-link)
              ("C-c s i" . org-super-links-insert-link)))

(use-package org-super-links-peek
  :quelpa (org-super-links-peek :fetcher github :repo "toshism/org-super-links-peek")
  :bind (:map org-mode-map ("C-c s p" . org-super-links-peek-link)))

(use-package org-rich-yank
  :demand t
  :after org
  :bind (:map org-mode-map ("C-M-y" . org-rich-yank)))

;; (use-package org-link-beautify
;;   :hook (org-mode . org-link-beautify-mode))

(use-package calfw-org :ensure calfw
  :custom (cfw:org-overwrite-default-keybinding t)
  :bind
  ("C-c o c" . cfw:open-org-calendar)
  (:map cfw:calendar-mode-map ("<return>" . cfw:org-open-agenda-day)))

(use-package calfw
  :quelpa (calfw :fetcher github :repo "furkanusta/emacs-calfw"))

(use-package side-notes
  :custom
  (side-notes-display-alist '((side . right)
                              (window-width . 50)))
  (side-notes-file "Notes.org")
  (side-notes-secondary-file "README.org")
  :bind ("C-c t n" . side-notes-toggle-notes))

(use-package org-roam
  :init (setq org-roam-v2-ack t)
  :after org-ref
  :demand t
  :custom
  (org-roam-directory my-notes-directory)
  (org-roam-auto-replace-fuzzy-links nil)
  (org-roam-capture-templates
   '(("d" "default" plain "%?" :target  (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")  :unnarrowed t)
     ("p" "Paper Note" plain "* %^{citekey}" :target (file "Papers.org" "#+title: ${title}"))))
  :bind
  ("C-c n l" . org-roam-buffer-toggle)
  ("C-c n f" . org-roam-node-find)
  ("C-c n g" . org-roam-graph)
  ("C-c n i" . org-roam-node-insert)
  ("C-c n c" . org-roam-capture)
  ;; Dailies
  ("C-c n j" . org-roam-dailies-capture-today)
  :config
  (org-roam-setup)
  (add-to-list 'completion-at-point-functions 'org-roam-complete-link-at-point)
  (require 'org-roam-protocol))

(use-package org-roam-bibtex
  :after org-roam org-ref
  :config (require 'org-ref))

(use-package org-roam-ui
  :quelpa (org-roam-ui :fetcher github :repo "org-roam/org-roam-ui")
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

(use-package org-roam-timestamps
  :quelpa (org-roam-timestamps :fetcher github :repo "ThomasFKJorna/org-roam-timestamps")
  :after org-roam
  :config (org-roam-timestamps-mode))

(use-package highlight
  :preface
  (defun hlt-general()
    (interactive)
    (unless (bound-and-true-p enriched-mode)
      (enriched-mode t))
    (hlt-highlight-region (region-beginning) (region-end) 'highlight))
  (defun highlight-on-capture ()
    (when (equal (plist-get org-capture-plist :key) "f")
      (save-excursion
        (with-current-buffer (plist-get org-capture-plist :original-buffer)
          (hlt-general)))))
  :hook (org-capture-after-finalize . highlight-on-capture)
  :bind (("C-c o h" . hlt-general)
         ("C-c o H" . hlt-unhighlight-region)))

(use-package ox-gfm)

(use-package ox-pandoc)

(use-package org-pandoc-import
  :quelpa (org-pandoc-import
           :fetcher github
           :repo "tecosaur/org-pandoc-import"
           :files ("*.el" "filters" "preprocessors")))
  ;; :hook (after-init . org-pandoc-import-transient-mode)

(use-package org-web-tools)

(use-package ein)

;; (use-package ob-ein :ensure ein)

(use-package jupyter)

(use-package code-cells
  :bind
  (:map code-cells-mode-map
        ("C-c C-C" . code-cells-eval)
        ("C-c C-p" . code-cells-backward-cell)
        ("C-c C-n" . code-cells-forward-cell)))

(use-package ox-ipynb
  :quelpa (ox-ipynb :fetcher github :repo "jkitchin/ox-ipynb"))

(use-package org-habit :ensure org)

(use-package org-agenda-property
  :custom (org-agenda-property-list '(LOCATION)))

(use-package org-timeline
  :hook (org-agenda-finalize-hook . org-timeline-insert-timeline))

(use-package org-radiobutton)

(use-package org-clock-budget
  :quelpa (org-clock-budget :fetcher github :repo "Fuco1/org-clock-budget"))

(use-package nano-theme
  :quelpa (nano-theme :fetcher github :repo "rougier/nano-theme") )

(use-package lentic)

(use-package company-org-block
  :custom (company-org-block-edit-style 'inline)
  :hook ((org-mode . (lambda ()
                       (setq-local company-backends '(company-capf company-org-block))
                       (company-mode +1)))))

(use-package org-pomodoro
  :custom (org-pomodoro-length 35)
  :bind (:map org-mode-map
              ("C-c C-x i" . org-pomodoro)))

(use-package org-download
  :hook
  (dired-mode . org-download-enable)
  (org-mode . org-download-enable))

(use-package org-mru-clock
  :bind
  ("C-c C-x c" . org-mru-clock-in)
  ("C-c C-x C-c" . org-mru-clock-select-recent-task))

(use-package org-dashboard
  :custom (org-dashboard-files (list (concat my-notes-directory "TODO.org"))))

(use-package orgit)
(use-package orgit-forge)

(use-package ox-hugo)
(use-package orgtbl-aggregate)
(use-package orgtbl-join)
;; (use-package orgtbl-edit)
(use-package mysql-to-org)
(use-package ob-sql-mode)
(use-package ox-timeline)
(use-package org-latex-impatient)
(use-package org-board)
(use-package org-reverse-datetree)

(use-package ob-blockdiag)
(use-package ob-mermaid)
(use-package ob-diagrams)
(use-package ob-napkin)
(use-package ob-reticulate)
(use-package axiom-environment)

(use-package org-clock-convenience)
(use-package ox-report)
(use-package org-babel-eval-in-repl)

(use-package org-latex-impatient
  :custom
  (org-latex-impatient-tex2svg-bin "/home/eksi/.local/prog/node_modules/mathjax-node-cli/bin/tex2svg"))

(use-package org-time-budgets
  :custom
  (org-time-budgets '((:title "Business" :match "+business" :budget "30:00" :blocks (workday week))
                      (:title "Sideprojects" :match "+personal+project" :budget "14:00" :blocks (day week))
                      (:title "Practice Music" :match "+music+practice" :budget "2:55" :blocks (nil week))
                      (:title "Exercise" :match "+exercise" :budget "5:15" :blocks (day))
                      (:title "Language" :match "+lang" :budget "5:15" :blocks (day week)))))

(use-package org-tanglesync
  ;; :hook ((org-mode . org-tanglesync-mode)
  ;;        ((prog-mode text-mode) . org-tanglesync-watch-mode))
  :bind
  (( "C-c M-i" . org-tanglesync-process-buffer-interactive)
   ( "C-c M-a" . org-tanglesync-process-buffer-automatic)))

(use-package notebook
  :quelpa (notebook :fetcher github :repo "rougier/notebook-mode"))

(use-package org-bib-mode
  :load-path "elisp/"
  ;; :quelpa (org-bib-mode :fetcher github :repo "rougier/org-bib-mode")
  :custom
  (org-bib-pdf-directory my-papers-directory))

(provide 'usta-org)
