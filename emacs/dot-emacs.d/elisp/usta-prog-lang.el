;; -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          C++          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package cc-mode :ensure nil
  :mode
  ("\\.h\\'" . c++-mode)
  :config
  (c-set-offset 'substatement-open 0)
  (c-set-offset 'innamespace 0)
  :custom
  (c-default-style "stroustrup")
  (c-basic-offset 4)
  (c-indent-level 4)
  (access-label 0)
  (c-noise-macro-names '("constexpr")))

(use-package modern-cpp-font-lock
  :diminish modern-c++-font-lock-mode
  :hook (c++-mode . modern-c++-font-lock-mode))

(use-package cmake-mode)

(use-package flycheck-clang-analyzer
  :after flycheck
  :config (flycheck-clang-analyzer-setup))

(use-package cmake-font-lock
  :hook (cmake-mode . cmake-font-lock-activate))

(use-package meson-mode
  :hook (meson-mode . company-mode))

(use-package dap-lldb)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;          Scala          ;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package scala-mode
  :interpreter ("scala" . scala-mode)
  :mode ("\\.sc\\'" . scala-mode))

(use-package sbt-mode
  :commands sbt-start sbt-command
  :custom (sbt:program-options '("-Dsbt.supershell=false"))
  :config (substitute-key-definition
           'minibuffer-complete-word
           'self-insert-command
           minibuffer-local-completion-map))

(use-package lsp-metals
  :hook  (scala-mode . lsp-deferred)
  :custom (lsp-metals-treeview-show-when-views-received nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;            Shell          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package ansi-color
  :commands ansi-color-apply-on-region
  :hook (compilation-filter . colorize-compilation-buffer)
  :preface (defun colorize-compilation-buffer ()
             (read-only-mode)
             (ansi-color-apply-on-region (point-min) (point-max))
             (read-only-mode -1))
  :config (add-to-list 'comint-output-filter-functions 'ansi-color-process-output)
  :custom (ansi-color-for-comint-mode 1))

(use-package shell
  :after window
  :hook (shell-mode . company-mode)
  :config (add-to-list 'display-buffer-alist (cons "\\*shell\\*" use-other-window-alist))
  :bind ("C-<f8>" . shell))

(use-package eshell
  :config (add-to-list 'display-buffer-alist (cons "\\*eshell\\*" use-other-window-alist))
  :bind ("M-<f8>" . eshell))

(use-package eshell-syntax-highlighting
  :hook (eshell-mode . eshell-syntax-highlighting-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;            Docker         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package dockerfile-mode
  :mode ("Dockerfile\\'" "\\.docker"))
(use-package docker-compose-mode
  :mode ("docker-compose\\.yml\\'" "-compose.yml\\'"))

(use-package docker)

(use-package docker-tramp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package verilog-mode
  :mode
  ("\\.v\\'" . verilog-mode)
  ("\\.sv\\'" . verilog-mode)
  :custom
  ;; (verilog-auto-inst-sort t)
  (verilog-library-directories '("." "../sim" "../rtl"))
  (verilog-auto-declare-nettype "none")
  (verilog-case-fold nil)
  (verilog-auto-newline nil)
  (verilog-tab-always-indent nil)
  (verilog-auto-indent-on-newline t)
  (verilog-case-indent 4)
  (verilog-cexp-indent 4)
  (verilog-indent-begin-after-if nil)
  (verilog-indent-level 4)
  (verilog-indent-level-behavioral 4)
  (verilog-indent-level-directive 4)
  (verilog-indent-level-declaration 4)
  (verilog-indent-level-module 4))


(use-package tree-sitter
  :hook (tree-sitter-after-on . tree-sitter-hl-mode))

(use-package tree-sitter-langs)

(use-package graphviz-dot-mode
  :custom (graphviz-dot-indent-width 4))

;;;;;;;;;;;;;;;;;;;;;;;;;
;;         LISP        ::
;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package sly
  :config (sly-setup '(sly-mrepl)))

(use-package smartparens
  :hook (prog-mode . smartparens-mode)
  :init (require 'smartparens-config))

(use-package lisp-extra-font-lock
  :hook (emacs-lisp-mode . lisp-extra-font-lock-mode))

(use-package comment-or-uncomment-sexp
  :bind ("C-M-;" . comment-or-uncomment-sexp))

(use-package refine)

;;;;;;;;;;;;;;;;;;;;;;;;;
;;        Python       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; (use-package blacken
;;   :hook (python-mode . blacken-mode)
;;   :custom (blacken-line-length 100))

(use-package gitlab-ci-mode
  :mode "\\.gitlab-ci\\.yml\\'")

(use-package apheleia
  :hook (python-mode . apheleia-mode))

(use-package format-all)

(use-package python-mls
  :hook
  (inferior-python-mode . python-mls-mode)
  (python-mode . python-mls-python-setup))

;; Built-in Python utilities
(use-package python
  :hook (python-mode . (lambda ()
                         (flycheck-add-next-checker 'lsp 'python-mypy)))
  :custom
  (python-indent-guess-indent-offset-verbose nil)
  :config
  (cond
   ((executable-find "ipython")
    (progn
      (setq python-shell-buffer-name "IPython")
      (setq python-shell-interpreter "ipython")
      (setq python-shell-interpreter-args "-i --simple-prompt")))
   ((executable-find "python3")
    (setq python-shell-interpreter "python3"))
   ((executable-find "python2")
    (setq python-shell-interpreter "python2"))
   (t
    (setq python-shell-interpreter "python")))
  :preface
  (defun yasnippet-radical-snippets--python-split-args (arg-string)
    "Split the python ARG-STRING into ((name, default)..) tuples."
    (mapcar (lambda (x)
              (split-string x "[[:blank:]]*=[[:blank:]]*" t))
            (split-string arg-string "[[:blank:]]*,[[:blank:]]*" t)))

  (defun yasnippet-radical-snippets--python-args-to-google-docstring (text &optional make-fields)
    "Return a Google docstring for the Python arguments in TEXT.
Optional argument MAKE-FIELDS will create yasnippet compatible
field that the can be jumped to upon further expansion."
    (let* ((indent (concat "\n" (make-string (current-column) 32)))
           (args (yasnippet-radical-snippets--python-split-args text))
    	   (nr 0)
           (formatted-args
    	    (mapconcat
    	     (lambda (x)
    	       (concat "   " (nth 0 x)
    		           (if make-fields (format " ${%d:arg%d}" (cl-incf nr) nr))
    		           (if (nth 1 x) (concat " \(default " (nth 1 x) "\)"))))
    	     args
    	     indent)))
      (unless (string= formatted-args "")
        (concat
         (mapconcat 'identity
    		        (list "" "Args:" formatted-args)
    		        indent)
         "\n")))))

(use-package pyvenv
  :hook
  (python-mode . pyvenv-try-activate)
  (pyvenv-post-activate . (lambda () (pyvenv-restart-python)))
  :preface
  (defun pyvenv-try-activate ()
    (pyvenv-mode t)
    (if (not pyvenv-virtual-env)
        (pyvenv-activate (concat (projectile-project-root) "venv"))
        (pyvenv-activate (concat (projectile-project-root) ".venv")))
    (if (not pyvenv-virtual-env)
        (pyvenv-activate (read-directory-name "Activate venv: " nil nil nil
					                          pyvenv-default-virtual-env-name)))))

(use-package pyinspect
  :bind
  (:map python-mode-map
        ("C-c C-i" . pyinspect-inspect-at-point)))

(use-package python-pytest)

(use-package py-isort
  :hook (before-save . py-isort-before-save))

(use-package dap-python :ensure dap-mode)

;; (use-package tox :custom (tox-runner py.test))
;; (use-package poetry)

(provide 'usta-prog-lang)
