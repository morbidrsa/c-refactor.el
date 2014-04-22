(require 'cc-mode)

(defgroup c-refactor nil
  "Refactoring helpers for C."
  :version "0.1"
  :group 'files)

(defcustom c-refactor-keymap-prefix (kbd "C-c C-r")
  "c-refactor keymap prefix."
  :group 'c-refactor
  :type 'sexp)

(defvar c-refactor-mode-map
  (let ((map (make-sparse-keymap)))
    (let ((prefix-map (make-sparse-keymap)))
      (define-key prefix-map (kbd "e") 'c-refactor-extract-to-method)
      (define-key map c-refactor-keymap-prefix prefix-map))
    map)
  "Keymap to use in C refactor minor mode.")


(defvar c-refactor-mode-hook nil
  "Hooks run during mode start.")

(defun c-refactor-ends-with-newline-p (region-start region-end)
  "Return if last character is a newline ignoring trailing spaces."
  (let ((text (replace-regexp-in-string " *$" "" (buffer-substring-no-properties region-start region-end))))
    (string-match "\n" (substring text -1))))

;;;###autoload
(defun c-refactor-extract-to-method (region-start region-end)
  "Extract region to method"
  (interactive "r")
  (save-restriction
    (save-match-data
      (widen)
      (let ((ends-with-newline (c-refactor-ends-with-newline-p region-start region-end))
	    (function-guts (buffer-substring-no-properties region-start region-end))
	    (function-name (read-from-minibuffer "Method name? "))
	    (function-return-type (read-from-minibuffer "Return type? ")))
	(delete-region region-start region-end)
	(c-indent-line)
	(insert function-name "();")
	(if ends-with-newline
	    (progn
	      (c-indent-line)
	      (insert "\n")
	      (c-indent-line)))
	(c-beginning-of-defun)
	(insert function-return-type " " function-name "(void)\n{\n" function-guts "\n}\n\n")
	(c-beginning-of-defun)
	(indent-region (point)
		       (progn
			 (forward-paragraph)
			 (point)))
	(search-forward function-name)
	(backward-sexp)
	))))

;;;###autoload
(define-minor-mode c-refactor-mode
  "C Refactor mode"
  :global nil
  :group c-refactor
  :keymap c-refactor-mode-map
  )

;;;###autoload
(defun c-refactor-mode-launch ()
  "Turn on 'c-refactor-mode'."
  (c-refactor-mode 1))

(provide 'c-refactor)