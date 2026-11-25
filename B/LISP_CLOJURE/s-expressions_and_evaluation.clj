;; S-Expressions and Evaluation
;; quote preserves the expression as data.
;; eval evaluates the stored expression.

(def expression '(+ 5 7))

(println "Stored Expression:" expression)
(println "Evaluated Result:" (eval expression))
