;;; searcheverything.el --- Emacs client for search everything                      -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Milan Stefanovic

;; Author: Milan Stefanovic <stefanovic.milan94@protonmail.com>
;; Keywords: elisp
;; Version: 1.0.0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Emacs client for SearchEverything.exe

;;; Code:
(require 'button)

;;;###autoload
(defcustom searcheverything-cli-path "es.exe"
  "Path to es.exe"
  :type '(string))

;;;###autoload
(defcustom searcheverything-output-buffer-name "*Everything*"
  "Buffer name where results will be stored"
  :type '(string))

;;;###autoload
(defcustom searcheverything-display-process-name "SearchEverything.exe"
  "Process name that will be displayed in emacs"
  :type '(string))

;;;###autoload
(defun searcheverything-execute-query (searchExpression &rest ARGS)
  "Execute regex SearchEverything query and display results in buffer"
  (interactive "s")
  (when (processp (get-process searcheverything-display-process-name))
    (kill-process searcheverything-display-process-name))
  (when (buffer-live-p (get-buffer searcheverything-output-buffer-name))
    (kill-buffer searcheverything-output-buffer-name))
  (switch-to-buffer-other-window (process-buffer (make-process :name searcheverything-display-process-name
                                                               :buffer searcheverything-output-buffer-name
                                                               :command `(,searcheverything-cli-path "-regex" ,searchExpression "-s")
                                                               :filter #'searcheverything--filter-es-output))))
(defun searcheverything--filter-es-output (proc es-output)
  "Filter function used to convert raw SearchEverything output to emacs friendly format"
  (when (buffer-live-p (process-buffer proc))
    (with-current-buffer (process-buffer proc)
      (let ((moving (= (point) (process-mark proc))))
        (save-excursion
          ;; Insert the text, advancing the process marker.
          (goto-char (process-mark proc))
          (searcheverything--modify-process-output es-output)
          (set-marker (process-mark proc) (point)))
        (if moving (goto-char (process-mark proc)))))))

(defun searcheverything--modify-process-output (es-output)
  "Loops trough files and applies modification to each"
  (cl-loop for file-path in (split-string es-output (char-to-string ?\n)) do
        (searcheverything--modify-file-path file-path)))

(defun searcheverything--modify-file-path (file-path)
  "Converts full file path to clickable [FileName | FullPath] format"
  (newline)
  (let* ((file-name (car (last (if (string-match-p (regexp-quote "\\") file-path)
                                   (split-string file-path (regexp-quote "\\"))
                                 (split-string file-path "/")))))
         (file-label (format "%-50s | %s" file-name file-path)))
    (insert-button file-label
                   'action (lambda (btn)
                             (find-file (button-get btn 'file)))
                   'file file-path)))

(provide 'searcheverything)
;;; searcheverything.el ends here
