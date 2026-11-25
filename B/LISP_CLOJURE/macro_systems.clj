;; Macro Systems
;; defmacro defines a macro that receives unevaluated forms.
;; Syntax-quote creates the generated expression.
;; ~ inserts the condition into the generated expression.
;; ~@ inserts all body expressions into the generated do block.


(defmacro unless* [test & body]
`(if (not ~test)
(do ~@body)
nil))

(unless* false
(println "The condition is false!"))
