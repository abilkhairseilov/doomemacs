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

(add-to-list 'custom-theme-load-path "~/.config/emacs/themes/")

(setq doom-font (font-spec :family "Aporetic Sans Mono" :size 20 :weight 'semi-light)
      doom-big-font (font-spec :family "Noto Sans" :size 30)
     doom-variable-pitch-font (font-spec :family "Noto Sans" :size 21)
     doom-symbol-font (font-spec :family "Symbols Nerd Font Mono" :size 20))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'kanagawa-wave)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/notes/org/")


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

;; transparency; pgtk build only
(add-to-list 'default-frame-alist '( alpha-background . 100 ))

(setq shell-file-name (executable-find "zsh"))
(setq vterm-shell (executable-find "zsh"))
(setenv "SHELL" (executable-find "zsh"))

(setq org-agenda-files
      '("~/notes/org/"
        "~/notes/org/workspace/a-level/"
        "~/notes/org/workspace/sat/"))

(defun zhori/toggle-transparency ()
  (interactive)
  (let ((current-alpha (frame-parameter nil 'alpha-background)))
    (if (or (not current-alpha) (= current-alpha 100))
        (set-frame-parameter nil 'alpha-background 85)
      (set-frame-parameter nil 'alpha-background 100))))

(global-set-key (kbd "C-c t t") 'zhori/toggle-transparency)

(use-package! gptel
 :config (setq! gptel-model 'llama3.1
        gptel-backend (gptel-make-ollama "Ollama"
                        :host "blackbox:11434"
                        :stream t
                        :models '("deepseek-r1:8b" "llama3.1")))

 (setq-default gptel-directives
      '((default . "To speak with you is to speak with a sage. Use Markdown for formatting.")
        (programmer . "You are a polyglot programmer. Use Markdown for code blocks.")
        ;; Your new custom directive:
        (org-expert . "You are an Emacs and Org-mode expert.
Always respond using Org-mode syntax.
- Use *bold*, /italic/, and =code=.
- Use asterisks for headings (e.g., * Heading, ** Subheading).
- Use #+BEGIN_SRC and #+END_SRC for code blocks.
- Never use Markdown (no triple backticks).")))
 )

(gptel-make-preset "Org-Agenda-Parser"
  :directives "You are a parser that transforms messy, raw notes into structured Emacs Org-mode entries.
Your goal: Identify dates, deadlines, and action items.
Format:
* TODO [Item Name]
  DEADLINE: <YYYY-MM-DD Day>
  :PROPERTIES:
  :SOURCE: Raw dump
  :END:
  [Brief summary or lecture notes here in bullet points]

If no date is found, just use structured headings.")

(gptel-make-preset "Lecture-Organizer"
  :directives "You are an Org-mode structure expert.
Goal: Convert raw lecture/event notes into structured Org-mode.
Rules:
1. NEVER delete information. If something is messy, keep it messy but under a heading.
2. Use asterisks (*) for hierarchy.
3. Identify 'Deadlines' or 'Dates' and format them as: DEADLINE: <YYYY-MM-DD Day>.
4. Identify 'Tasks' and format them as: * TODO Task Name.
5. Use #+BEGIN_SRC / #+END_SRC for any code or formulas.
6. Preserve mnemonics and acronyms exactly as written.")

(setq org-roam-capture-templates
      '(("d" "default" plain
         "%?"
         :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                            ":PROPERTIES:\n:CREATED: %U\n:CATEGORY:\n:END:\n#+title: ${title}\n#+filetags:\n")
         :unnarrowed t)))


;; Org-capture templates
(after! org
  (setq org-capture-templates
    (append org-capture-templates

                 '(
                   ("S" "Subjects")
                   ("Sc" "Chemistry" entry
                    (file+headline "workspace/a-level/chemistry.org" "Chemistry")
                    "* %U\nTopic: %?\n- %i")
                   ("Sp" "Computer science" entry
                    (file+headline "workspace/a-level/computerscience.org" "Computer Science")
                    "* %U\nTopic: %?\n- %i")
                   ("Sq" "Physics" entry
                    (file+headline "workspace/a-level/physics.org" "Physics")
                    "* %U\nTopic: %?\n- %i")
                  )
                 '(
                   ("M" "Miscellaneous")
                   ("Mp" "Person" entry
                    (file+headline "workspace/misc/people.org" "Inbox")
                    "* %?\n:PROPERTIES:\n:CREATED: %U\n:TYPE: \n:CONTACTS: \n:BIRTHDAY: \n:END:\n")
                   ("Ms" "Skill" entry
                    (file+headline "workspace/misc/skills.org" "Inbox")
                    "* %?\n:PROPERTIES:\n:CREATED: %U\n:TYPE: Skill/Learning\n:SOURCE: Course/Book/Online\n:PROGRESS: Not started/In progress/Completed\n:PRIORITY: \n:END:\n")
                   ("Mm" "Music" entry
                    (file+headline "workspace/misc/music.org" "Inbox")
                    "* %?\n:PROPERTIES:\n:CREATED: %U\n:TYPE: Track/Album/Playlist\n:ARTIST: \n:SOURCE: Streaming/Recommendation/Discovery\n:STATUS: To listen/Listening/Finished\n:END:\n")
                   ("Mg" "Gym progress" entry
                    (file+headline "workspace/misc/gym.org" "Inbox")
                    "* %?\n:PROPERTIES:\n:CREATED: %U\n:TYPE: Exercise/Workout/Plan\n:GOAL: \n:REPS/SETS: \n:WEIGHTS: \n:NOTES: \n:END:\n")
                   ;; Extra “feeling lucky” entries
                   ("Mb" "Books / Reading" entry
                    (file+headline "workspace/misc/books.org" "Inbox")
                    "* %?\n:PROPERTIES:\n:CREATED: %U\n:TYPE: Book/Article/Comic\n:AUTHOR: \n:STATUS: To read/Reading/Finished\n:RATING: \n:END:\n")
                   ("Mi" "Ideas / Notes" entry
                    (file+headline "workspace/misc/ideas.org" "Inbox")
                    "* %?\n:PROPERTIES:\n:CREATED: %U\n:TYPE: Idea/Note/Project\n:SOURCE: Personal/External\n:STATUS: Draft/In progress/Completed\n:TAGS: \n:END:\n")
                   ("Mt" "Travel / Places" entry
                    (file+headline "workspace/misc/travel.org" "Inbox")
                    "* %?\n:PROPERTIES:\n:CREATED: %U\n:TYPE: Location/Trip\n:DESTINATION: \n:DATES: \n:PLANNER: \n:NOTES: \n:END:\n")
                   )

         ;;         '(("a" "AI Brain Dump" entry (file+headline "~/org/inbox.org" "Brain Dump")
         ;; "* %? :AI_READY:\n:PROPERTIES:\n:CREATED: %U\n:CONTEXT: %a\n:END:\n\n%i\n\n#+BEGIN_QUERY\nAnalyze this for patterns or TODOs.\n#+END_QUERY"))
    )
))

(spacious-padding-mode t)

(use-package! websocket
    :after org-roam)

(add-to-list 'auto-mode-alist '("\\.svelte\\'" . web-mode))
(setq web-mode-engines-alist '(("svelte" . "\\.svelte\\'")))

(use-package! lsp-tailwindcss
  :after lsp-mode
  :hook (vcss-mode . (lambda () (require 'lsp-tailwindcss) (lsp)))
  :config
  (setq lsp-tailwindcss-add-on-mode t))

(use-package! org-roam-ui
    :after org-roam ;; or :after org
    ;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
    ;;         a hookable mode anymore, you're advised to pick something yourself
    ;;         if you don't care about startup time, use
;;  :hook (after-init . org-roam-ui-mode)
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t))
