;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "JetBrains Mono" :size 14)
      doom-variable-pitch-font (font-spec :family "Avenir Next LT Pro" :size 16)
      doom-big-font (font-spec :family "JetBrains Mono" :size 25))

;; Set reusable font name variables
(defvar my/fixed-width-font "JetBrains Mono"
  "The font to use for monospaced (fixed width) text.")

(defvar my/variable-width-font "Iosevka Aile"
  "The font to use for variable-pitch (document) text.")

(setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
      doom-themes-enable-italic t) ; if nil, italics is universally disabled

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:

(setq doom-theme 'doom-dracula)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;
;; copy-paste:
cua-mode 1
;;
;; Custum Keybindings:
(map! :leader
       :desc "citar-open"
       "n B" #'citar-open
       :desc "Open UI Graph "
       "n r G" #'org-roam-ui-open)

;; Citar
(use-package citar
  :custom
  (citar-bibliography '("~/org/config/bibliography.bib")))

;; LaTeX export:
(with-eval-after-load 'ox-latex
  (setq org-latex-src-block-backend 'listings)
  (add-to-list 'org-latex-classes
               '("org-plain-latex"
                 "\\documentclass{article}
           [NO-DEFAULT-PACKAGES]
           [PACKAGES]
           [EXTRA]"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))
;;



;;
;; Org-Mode:
(after! org
  :config
  (setq org-directory "~/org/"
        org-cite-global-bibliography (list "~/org/config/bibliography.bib")
        org-agenda-skip-scheduled-if-done t
        org-startup-indented t
        display-line-numbers-type nil
        org-startup-align-all-tables t
        org-todo-keywords '((sequence "TODO(t)" "TOREAD(r)" "TOBUY(b)" "INPROGRESS(i)" "WAITING(w)" "SOMEDAY(s)" "|" "DONE(d)" "CANCELLED(c)"))
        org-todo-keyword-faces
        '(("TODO" :foreground "#8be9fd" :weight bold :underline nil)
          ("TOREAD" :foreground "#8be9fd" :weight normal :underline nil)
          ("TOBUY" :foreground "#8be9fd" :weight normal :underline nil)
          ("INPROGRESS" :foreground "#f1fa8c" :weight normal :underline nil)
          ("WAITING" :foreground "#f1fa8c" :weight normal :underline nil)
          ("SOMEDAY" :foreground "#8be9fd" :weight normal :underline nil)
          ("DONE" :foreground "#50fa7b" :weight bold :underline nil)
          ("CANCELLED" :foreground "#ff5555" :weight bold :underline nil))
        org-agenda-files (list "~/org/org-agenda/")
        org-log-done 'time
        org-capture-templates '(
                                ("j" "Journal" entry
                                (file+datetree "~/org/org-agenda/journal.org")
                                "* %<%H:%M>\n%?"
                                :jump-to-captured t
                                :immediate-finish t)
                                ("t" "Journal ToDo" entry
                                (file+datetree  "~/org/org-agenda/journal.org")
                                "* %<%H:%M> Daily Todo's\n** TODO %?\nSCHEDULED: %<%Y-%m-%d %a>"
                                :jump-to-captured t))
        )

;; Org-Roam:
(use-package! org-roam
  :after org
  :ensure t
  :custom
  (org-roam-directory "~/org/roam/")
  (org-roam-completion-everywhere t)
  (org-roam-db-autosync-mode t)
  (org-roam-capture-templates
   '(("d" "default" plain
      "* notes\n\n%?\n\n* links\n\n* sources\n\n"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: %^G\n")
      :unnarrowed t
      :jump-to-captured t)
     ("t" "to be done" plain
      "* notes\n\n%?\n\n* links\n\n* sources\n\n"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: tbd:%^G\n")
      :unnarrowed t
      :immediate-finish t)
     ("T" "topic" plain
      "%?"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: topic:%^G\n")
      :unnarrowed t
      :immediate-finish t)
     ("n" "literature note" plain
         "* notes\n\n%?\n\n* sources\n[cite:@${citekey}]\n\n* links\n\n"
         :if-new (file+head "%(expand-file-name (or citar-org-roam-subdir \"\") org-roam-directory)/%<%Y%m%d%H%M%S>-${citekey}.org"
          "#+title: ${title}.\n#+created: %U\n#+last_modified: %U\n#+filetags: bib:%^G\n\n")
         :unnarrowed t
         :jump-to-captured t))))

;; Org-Roam-Bibtex
;; (use-package! org-roam-bibtex
;;   :after org-roam
;;   :config
;;   (setq orb-roam-ref-format 'org-cite))
;;
;; Citar
(use-package citar
  :custom
  (citar-bibliography '("~/org/config/bibliography.bib")))

(use-package! citar-org-roam
  :after (citar org-roam)
  :config
  (setq citar-org-roam-capture-template-key "n")
  (citar-org-roam-mode))

(setq bibtex-completion-bibliography '("~/org/config/bibliography.bib")
      bibtex-completion-pdf-field "File")


;; Org-Roam-UI
(use-package! org-roam-ui
  :ensure t
  :after org-roam
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

;; encryption:
  (require 'org-crypt)
  (require 'epa-file)
  (epa-file-enable)
  (org-crypt-use-before-save-magic)
  (setq org-tags-exclude-from-inheritance '("crypt"))
  (setq org-crypt-key nil))

;; Presentations:
(defun my/org-present-start ()
  ;; Set a blank header line string to create blank space at the top
  (setq header-line-format " ")
  ;; Display inline images automatically
  (org-display-inline-images)
  ;; Change the font settings to make it bigger
  (setq-local face-remapping-alist '((default (:height 1.5) variable-pitch)
                                     (header-line (:height 2.0) variable-pitch)
                                     (org-level-1 (:height 2.0 :weight bold :foreground "#ff79c6") variable-pitch)
                                     (org-document-title (:height 1.75) org-document-title)
                                     (org-code (:height 1.55) org-code)
                                     (org-verbatim (:height 1.55) org-verbatim)
                                     (org-block (:height 1.25) org-block)
                                     (org-block-begin-line (:height 0.7) org-block)))

  ;; Make sure certain org faces use the fixed-pitch face when variable-pitch-mode is on
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)


  (display-line-numbers-mode 0)
  (visual-fill-column-mode 1)
  (visual-line-mode 1)
  (setq visual-fill-column-width 110
        visual-fill-column-center-text t))

(defun my/org-present-end ()
  ;; Clear the header line string so that it isn't displayed
  (setq header-line-format nil)
  ;; Stop displaying inline images
  (org-remove-inline-images)
  ;; reset font-settings
  (setq-local face-remapping-alist nil))

(defun my/org-present-prepare-slide (buffer-name heading)
  ;; Show only top-level headlines
  (org-overview)

  ;; Unfold the current entry
  (org-fold-show-entry)

  ;; Show only direct subheadings of the slide but don't expand them
  (org-fold-show-children))

;; Register hooks with org-present
(add-hook 'org-present-mode-hook 'my/org-present-start)
(add-hook 'org-present-mode-quit-hook 'my/org-present-end)
(add-hook 'org-present-after-navigate-functions 'my/org-present-prepare-slide)

;; Org-Download
 (use-package! org-download
    :after org
    :defer nil
    :custom
    (org-download-method 'directory)
    (org-download-image-dir "images")
    (org-download-heading-lvl nil)
    (org-download-timestamp "%Y%m%d-%H%M%S_")
    (org-image-actual-width 300)
    (org-download-screenshot-method "/usr/local/bin/pngpaste %s")
    :bind
    ("C-M-y" . org-download-screenshot)
    :config
    (require 'org-download))

;; Org-Super-Agenda
(use-package! org-super-agenda
  :after org-agenda
  :init
  (setq org-super-agenda-groups '((:name "today"
                                         :time-grid t
                                         :scheduled today)
                                  (:name "Due today"
                                         :deadline today)
                                  (:name "Important"
                                         :priority "A")
                                  (:name "Overdue"
                                         :deadline past)
                                  (:name "Due soon"
                                         :deadline future)))
  :config
  (org-super-agenda-mode))

;; Visual-fill-column
(use-package! visual-fill-column
  :hook (org-mode . visual-fill-column-mode)
  :init
  (setq visual-fill-column-width 110
        visual-fill-column-center-text t))

;; completion:
(after! company
    ;;; Prevent suggestions from being triggered automatically. In particular,
  ;;; this makes it so that:
  ;;; - TAB will always complete the current selection.
  ;;; - RET will only complete the current selection if the user has explicitly
  ;;;   interacted with Company.
  ;;; - SPC will never complete the current selection.
  ;;;
  ;;; Based on:
  ;;; - https://github.com/company-mode/company-mode/issues/530#issuecomment-226566961
  ;;; - https://emacs.stackexchange.com/a/13290/12534
  ;;; - http://stackoverflow.com/a/22863701/3538165
  ;;;
  ;;; See also:
  ;;; - https://emacs.stackexchange.com/a/24800/12534
  ;;; - https://emacs.stackexchange.com/q/27459/12534

  ;; <return> is for windowed Emacs; RET is for terminal Emacs
  (dolist (key '("<return>" "RET"))
    ;; Here we are using an advanced feature of define-key that lets
    ;; us pass an "extended menu item" instead of an interactive
    ;; function. Doing this allows RET to regain its usual
    ;; functionality when the user has not explicitly interacted with
    ;; Company.
    (define-key company-active-map (kbd key)
      `(menu-item nil company-complete
                  :filter ,(lambda (cmd)
                             (when (company-explicit-action-p)
                              cmd)))))
  ;; (define-key company-active-map (kbd "TAB") #'company-complete-selection)
  (map! :map company-active-map "TAB" #'company-complete-selection)
  (map! :map company-active-map "<tab>" #'company-complete-selection)
  (define-key company-active-map (kbd "SPC") nil)

  ;; Company appears to override the above keymap based on company-auto-complete-chars.
  ;; Turning it off ensures we have full control.
  (setq company-auto-commit-chars nil))
