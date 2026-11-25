#lang scheme
;; DrRacket uses its Scheme compatibility language for this source.

;; The inner lambda closes over the parameter of this invocation.
;; Procedure-style define binds a name and takes one offset argument.
(define (make-offset offset)
  ;; The returned lambda captures offset in its lexical environment.
  (lambda (reading) (+ offset reading)))

;; This helper keeps terminal effects outside the offset calculation.
(define (emit label value)
  ;; display prints plain text. write keeps Scheme list notation.
  (display label) (display " ") (write value) (newline))

;; Bind the closure returned by calling the factory with offset 3.
(define add-three (make-offset 3))
;; This offset belongs to the caller's parameter list, outside the closure.
;; The formal parameter offset creates a separate local binding.
(define (under-shadow offset reading)
  ;; Read offset in the caller's lexical scope to show the local value.
  (emit "caller-offset" offset)
  ;; Apply the saved closure to reading in the procedure's tail position.
  (add-three reading))

;; map accepts a procedure as a value. Quote keeps the inputs as data.
(emit "map" (map add-three '(0 4 -2)))
;; Call the shadowing procedure with a different offset and reading.
(emit "shadowed-call" (under-shadow 100 4))
;; The inner call returns a procedure used as the outer call's operator.
(emit "second-closure" ((make-offset -2) 4))
;; The quoted empty list gives map no elements to transform.
(emit "empty" (map add-three '()))
