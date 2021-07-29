;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          Org Mode          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package org
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
  (org-pretty-entities t)
  (org-src-fontify-natively t)
  (org-src-preserve-indentation nil)
  (org-src-tab-acts-natively t)
  (org-yank-adjusted-subtrees t)
  (org-todo-keywords '((sequence "TODO" "IN-PROGRESS" "NEXT" "|" "DONE")
                       (sequence "PAUSED" "SCHEDULED" "|"  "CANCELLED")))
  :hook
  (org-mode . turn-on-flyspell)
  (org-mode . auto-fill-mode)
  :bind (:map org-mode-map ("C-c C-." . org-time-stamp-inactive))
  :config (org-babel-do-load-languages
           'org-babel-load-languages
           '((python . t)
             ;; (http . t)
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

(use-package toc-org
  :hook (org-mode . toc-org-mode))

(use-package org-pretty-table
  :quelpa (org-pretty-table :fetcher github :repo "Fuco1/org-pretty-table")
  :hook (org-mode . org-pretty-table-mode))

(use-package org-table-sticky-header
  :hook (org-mode . org-table-sticky-header-mode))

(use-package org-sticky-header
  :hook (org-mode . org-sticky-header-mode)
  :custom (org-sticky-header-always-show-header nil))

(use-package org-ref
  :custom
  (org-ref-bibliography-notes (concat my-notes-directory "/Papers.org"))
  (org-ref-default-bibliography (list my-bibliography))
  (org-ref-pdf-directory (concat my-data-directory "/Papers/"))
  (org-ref-show-broken-links t))

(use-package org-noter
  :custom
  (org-noter-notes-search-path (list my-notes-directory))
  (org-noter-default-notes-file-names (list "Papers.org"))
  (org-noter-auto-save-last-location t)
  (org-noter-insert-note-no-questions t))

(use-package org-books
  :custom
  (org-books-file (concat my-notes-directory "/Books.org"))
  (org-books-file-depth 0))

(use-package org-special-block-extras)

(use-package org-marginalia
  :quelpa (org-marginalia :fetcher github :repo "nobiot/org-marginalia")
  :hook (org-mode . org-marginalia-mode)
  :commands (org-marginalia-next org-marginalia-prev)
  :preface
  (defun org-marginalia-make-annotation ()
    (interactive)
    (let ((mark-end (region-end)))
      (org-marginalia-mark (region-beginning) (region-end))
      (org-marginalia-save)
      (org-marginalia-open (1- mark-end))
      (goto-char (point-max))))
  (defun org-marginalia-browse-forward ()
    (interactive)
    (let ((buf (current-buffer)))
      (org-marginalia-next) (org-marginalia-open (point))
      (pop-to-buffer buf nil t)))
(defun org-marginalia-browse-backward ()
    (interactive)
    (let ((buf (current-buffer)))
      (org-marginalia-prev) (org-marginalia-open (point))
      (pop-to-buffer buf nil t)))
  :bind
  ("C-c i m" . org-marginalia-make-annotation)
  ("C-c m o" . org-marginalia-open)
  ("C-c m ]" . org-marginalia-browse-forward)
  ("C-c m [" . org-marginalia-browse-backward))

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

(use-package org-linker :quelpa (org-linker :fetcher github :repo "toshism/org-linker"))

(use-package org-super-links
  :quelpa (org-super-links :fetcher github :repo "toshism/org-super-links")
  :bind (:map org-mode-map
              ("C-c s s" . org-super-links-link)
              ("C-c s d" . org-super-links-delete-link)
              ("C-c s l" . org-super-links-store-link)
              ("C-c s i" . org-super-links-insert-link)))

(use-package org-super-links-peek
  :quelpa (org-super-links-peek :fetcher github :repo "toshism/org-super-links-peek")
  :bind (:map org-mode-map ("C-c s p" . org-super-links-peek-link)))

(use-package org-rich-yank
  :bind (:map org-mode-map ("C-M-y" . org-rich-yank)))

(use-package org-link-beautify
  :hook (org-mode . org-link-beautify-mode))

(use-package calfw-org :after calfw
  :custom (cfw:org-overwrite-default-keybinding t)
  :bind
  ("C-c C-f" . cfw:open-org-calendar)
  (:map cfw:calendar-mode-map ("<return>" . cfw:org-open-agenda-day)))

(use-package calfw)

(use-package side-notes
  :custom
  (side-notes-display-alist '((side . right)
                              (window-width . 50)))
  (side-notes-file "Notes.org")
  (side-notes-secondary-file "README.org")
  :bind ("C-c t n" . side-notes-toggle-notes))

(provide 'usta-org)