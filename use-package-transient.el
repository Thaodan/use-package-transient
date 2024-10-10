;;; use-package-transient.el --- transient- commands in use-package -*- lexical-binding:t -*-

;; Copyright (C) 2018 Toon Claes
;; Copyright (C) 2024 Björn Bidar

;; Author: Björn Bidar <me@thaodan.de>
;; Created: 04 Oct 2024
;; Modified: 04 Oct 2024
;; Version: 0.1
;; Package-Requires: ((emacs "26.1") (use-package "2.4"))
;; Keywords: convenience extensions tools
;; URL: https://codeberg.org/Thaodan/use-package-transient

;; SPDX-License-Identifier: GPL-3.0-or-later

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; Provides support to define transient commands in use-package blocks
;; as keywords.  These are made available by default by requiring
;; `use-package'.  The keywords are:
;; - transient-prefix: -> transient-define-prefix
;; - transient-suffix: -> transient-define-suffix
;;
;; Based upon use-package-hydra hence the reason for the partial
;; copyright to Toon Claes.

;;; Code:


(eval-when-compile
  (require 'cl-lib))

(require 'use-package-core)
(require 'transient)


(defun use-package-transient--name (name)
  "Build transient name for package NAME."
  (cl-gentemp (concat "transient-" (symbol-name name))))

(defun use-package-transient--normalize (name keyword args)
  "Normalize the ARGS to be a list transients of type KEYWORD.
It accepts a single transient, or a list of transients.  It is optional
provide a name for the transient, if so there is a name generated
from NAME."
  (let (name result*)
    (while args
      (cond
       ;; single named transient
       ((symbolp (car args))
        (setq result* (nconc result* (list args))
              args nil))
       ;; single unnamed transient with docstring
       ((stringp (nth 2 args))
        (setq name (use-package-transient--name name)
              result* (nconc result* (list (cons name args)))
              args nil))
       ;; TODO single unnamed transient without docstring

       ;; list of transients
       ((listp (car args))
        (setq result*
              (nconc result* (use-package-transient--normalize name keyword (car args)))
              args (cdr args)))
       ;; Error!
       (t
        (use-package-error
         (format
          "%s wants arguments acceptable to the `transient-define-%s' macro or a list of such values"
          (symbol-name name) name )))))
    result*))

(defalias 'use-package-normalize/:transient-prefix 'use-package-transient--normalize
  "Normalize for the definition of one or more transient prefixes.")

(defalias 'use-package-normalize/:transient-suffix 'use-package-transient--normalize
  "Normalize for the definition of one or more transient suffixes.")

(defun use-package-handler--transient-command (command name _keyword args rest state)
  "Wrap command transient-handler for each transient command of type COMMAND.
Generates a transient with NAME of type COMMAND for KEYWORD.
NAME, ARGS, REST and STATE are prepared by the appropriate handler function."
  (use-package-concat
   (mapcar #'(lambda (def) `(,(intern (concat "transient-define-" command)) ,@def))
           args)
   (use-package-process-keywords name rest state)))

;;;###autoload
(defun use-package-handler/:transient-prefix (name keyword args rest state)
  "Generate deftransient with NAME for `:transient-prefix' KEYWORD.
ARGS, REST, and STATE are prepared by `use-package-normalize/:transient-prefix'."
  (use-package-handler--transient-command "prefix" name keyword args rest state))

;;;###autoload
(defun use-package-handler/:transient-suffix (name keyword args rest state)
  "Generate deftransient with NAME for `:transient' KEYWORD.
ARGS, REST, and STATE are prepared by `use-package-normalize/:transient-suffix'."
  (use-package-handler--transient-command "suffix" name keyword args rest state))

(cl-pushnew :transient-suffix use-package-keywords)
(cl-pushnew :transient-prefix use-package-keywords)


(provide 'use-package-transient)
;;; use-package-transient.el ends here
