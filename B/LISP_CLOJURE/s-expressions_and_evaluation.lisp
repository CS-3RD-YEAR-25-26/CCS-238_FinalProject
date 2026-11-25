
;; S-Expressions and Evaluation
;; QUOTE (') prevents the expression from being evaluated immediately.
;; EVAL explicitly evaluates the stored expression.

(defparameter *expression* '(+ 5 7))

(format t "Stored Expression: ~S~%" *expression*)
(format t "Evaluated Result: ~A~%" (eval *expression*))
