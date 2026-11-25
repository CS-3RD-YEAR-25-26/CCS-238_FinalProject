;; Macro Systems
;; DEFMACRO defines a macro that receives unevaluated forms.
;; Backquote creates the generated expression.
;; Comma inserts the condition into the generated expression.
;; Comma-at inserts all body expressions into PROGN.

(defmacro unless* (test &body body)
  `(if (not ,test)
       (progn ,@body)
       nil))

(unless* nil
  (format t "The condition is false!~%"))
