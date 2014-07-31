;;; c-refactor.el -- A minor mode which presents various C refactoring helpers

;; Copyright (C) 2014 Johannes Thumshirn

;; Authors: Johannes Thumshirn <morbidrsa@gmail.com>
;; Keywords: refactor C
;; Version: 0.1
;; URL: https://github.com/morbidrsa/c-refactor.el
;; Package-Requires: ((cc-mode))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; C Refactor is inspired by ruby-refactor by Andrew J Vargo <ajvargo@gmail.com>
;; and Jeff Morgan <jeff.morgan@leandog.com> (https://github.com/ajvargo/ruby-refactor)

;; I've only implemented one refactoring yet
;; - Extract to Method

;;; TODOs
;; When extracting to a function, create needed variables in the new
;; function. Varibles that are used in the old and new function are passeed as
;; parameters. Variables that are only used in the new function are removed from
;; the old function and re-created in the new function.

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