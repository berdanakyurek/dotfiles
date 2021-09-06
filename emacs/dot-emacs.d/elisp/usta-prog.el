;; -*- lexical-binding: t; -*-
(use-package projectile
  :commands projectile-project-name projectile-project-root
  :preface (defun my-open-readme ()
          (let* ((project-name (projectile-project-name))
                 (project-root (projectile-project-root))
                 (project-files (directory-files project-root nil nil t))
                 (readme-files (seq-filter (lambda (file) (string-prefix-p "readme" file t)) project-files)))
            (if readme-files
                (let ((readme-file (car readme-files)))
                  (find-file (expand-file-name readme-file project-root)))
              (find-file (expand-file-name "README.org" project-root)))))
  :custom
  (projectile-mode 1)
  (projectile-enable-caching t)
  (projectile-switch-project-action 'my-open-readme)
  (projectile-known-projects-file (concat no-littering-var-directory "projectile-bookmarks.eld"))
  (projectile-sort-order 'recentf)
  (projectile-inedxing-method 'hybrid)
  :bind-keymap ("C-c p" . projectile-command-map))

(use-package persp-projectile
  :bind (:map projectile-command-map ("p" . projectile-persp-switch-project)))

(use-package perspective
  :commands persp-current-buffers
  :after helm
  :config (persp-mode t)
  :preface
  (defvar perspective-skip-ignore-list '("*dashboard*" "*Messages*" "*Warnings*" "*elfeed-search*"))
  (defvar perspective-skip-prefix-list '("magit-"))
  (defvar perspective-skip-ignore-prefix-list '("*vterm" "*scratch" "*shell" "*Customize" "*ielm*" "*org" "*ein"))
  (defun perspective-my-skip-buffer-p (window buffer burry-or-kill)
    (let ((name (buffer-name buffer)))
      (or
       (and
        (char-equal ?* (seq-elt name 0))
        (not (seq-contains-p perspective-skip-ignore-list name))
        (cl-every
         (lambda (x) x)
         (mapcar (lambda (pref) (not (string-prefix-p pref name))) perspective-skip-ignore-prefix-list)))
       (cl-some
        (lambda (x) x)
        (mapcar (lambda (pref) (string-prefix-p pref name)) perspective-skip-prefix-list))
       (not (seq-contains-p (persp-current-buffers) buffer)))))
  :custom
  (persp-mode-prefix-key (kbd "C-c w"))
  (switch-to-prev-buffer-skip #'perspective-my-skip-buffer-p))

(use-package magit
  :bind ("C-c g s" . magit-status)
  :init (setq magit-define-global-key-bindings nil)
  :custom
  (magit-blame-echo-style 'headings)
  (magit-repository-directories (list (cons (file-truename "~/Projects") 1))))

(use-package magit-todos
  :config
  (let ((inhibit-message t))
    (magit-todos-mode 1))
  (transient-append-suffix 'magit-status-jump '(0 0 -1)
    '("T " "Todos" magit-todos-jump-to-todos)))

(use-package git-link
  :custom (git-link-use-commit t))

(use-package git-timemachine)

(use-package git-messenger
  :custom
  (git-messenger:show-detail t)
  (git-messenger:use-magit-popup t)
  :bind ("C-c g m" . git-messenger:popup-message))

(use-package github-review)

(use-package gitignore-mode)

(use-package copy-as-format
  :custom (copy-as-format-default "github"))

(use-package diff-hl
  :hook (find-file . diff-hl-mode))

(use-package hl-todo
  :custom (global-hl-todo-mode 1))

(use-package abridge-diff
  :after magit
  :init (abridge-diff-mode 1))

(use-package flycheck
  :commands flycheck-add-mode
  :custom
  (global-flycheck-mode nil)
  (flycheck-disabled-checkers '(emacs-lisp-checkdoc verilog-verilator))
  (flycheck-clang-language-standard "c++17")
  (flycheck-gcc-language-standard "c++17")
  (flycheck-cppcheck-standards "c++17")
  (flycheck-emacs-lisp-load-path 'inherit)
  :config
  (flycheck-add-mode 'c/c++-cppcheck 'c++mode))

(use-package flycheck-pos-tip
  :after flycheck
  :custom (flycheck-pos-tip-mode 1))

(use-package evil-nerd-commenter :bind ("M-;" . evilnc-comment-or-uncomment-lines))

(use-package vterm
  :hook (vterm-mode . (lambda () (setq-local confirm-kill-processes nil)))
  :commands (vterm-next-prompt vterm-prev-prompt)
  :config (add-to-list 'display-buffer-alist (cons "\\*vterm" use-other-window-alist))
  :preface
  (defun vterm-next-prompt () (interactive) (re-search-forward "msi.*\\$ " nil 'move))
  (defun vterm-prev-prompt () (interactive)
         (move-beginning-of-line nil)
         (re-search-backward "msi.*\\$ " nil 'move)
         (re-search-forward "\\$ " nil 'move))
  :bind
  (:map vterm-copy-mode-map
        ("C-<" . vterm-prev-prompt)
        ("C-," . vterm-next-prompt)))

(use-package vterm-toggle
  :custom (vterm-toggle-cd-auto-create-buffer nil)
  :bind
  ("<f8>" . vterm-toggle)
  (:map vterm-mode-map
        ("C-<return>" . vterm-toggle-insert-cd)))


(use-package shx
  :hook (shell-mode . shx-mode))

(use-package compile
  :custom (compilation-scroll-output t)
  :bind ("C-c C-r" . recompile))

(use-package isend-mode)

(use-package repl-toggle
  :config
  (setq-default rtog/mode-repl-alist '((emacs-lisp-mode . ielm))
                rtog/goto-buffer-fun 'pop-to-buffer)
  :bind ("C-c C-z" . rtog/toggle-repl))

(use-package highlight-escape-sequences
  :hook (prog-mode . hes-mode))

(use-package electric-operator
  :hook (cc-mode . electric-operator-mode))

(use-package yasnippet
  :custom (yas-global-mode 1)
  :bind ("M-i" . yas-expand)
  (:map yas-minor-mode-map ("<tab>" . nil)))

(provide 'usta-prog)
