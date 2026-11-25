#lang scheme
;; DrRacket loads the Scheme compatibility language for this file.


;; Symbols and pairs carry event names and any data.
;; The procedure takes the prior state and an event as ordinary values.
(define (step total event)
  ;; cond chooses the first matching clause. 'reset denotes a symbol.
  (cond ((eq? event 'reset) 0)
        ;; and short-circuits before car when the event is not a pair.
        ((and (pair? event) (eq? (car event) 'inc))
         ;; cdr retrieves the numeric payload from the increment's dotted pair.
         (+ total (cdr event)))
        ;; The decrement uses the same pair representation with a different
        ;; tag.
        ((and (pair? event) (eq? (car event) 'dec))
         ;; Subtraction returns a new total while the input remains available.
         (- total (cdr event)))
        ;; The else branch raises a Racket error for an unrecognized event.
        (else (error 'step "unknown event ~a" event))))

;; The replay procedure accepts the starting state explicitly.
(define (replay total events)
  ;; Named let carries the total, remaining events, and reversed history.
  (let loop ((current total) (rest events) (reversed '()))
    ;; null? identifies the base case before the body reads the next event.
    (if (null? rest)
        ;; Reverse restores event order. cons puts the final total first.
        (cons current (reverse reversed))
        ;; Apply step to car of the remaining list and bind the returned total.
        (let ((next (step current (car rest))))
          ;; The tail call passes cdr and adds one result with cons.
          (loop next (cdr rest) (cons next reversed))))))

;; Use an output helper so step and replay perform no terminal I/O.
(define (emit label value)
  ;; display prints the label. write shows the Scheme representation.
  (display label) (display " ") (write value) (newline))

;; set! changes the lexical location captured by this closure.
;; Each call to this factory creates an independent ticker closure.
(define (make-ticker)
  ;; let creates a private binding initialized to zero.
  (let ((total 0))
    ;; A zero-argument lambda can still read its surrounding environment.
    (lambda ()
      ;; set! reassigns the captured binding in place.
      (set! total (+ total 1))
      ;; The last expression returns the current value of that binding.
      total)))

;; Quote makes a literal list of tagged pairs and a reset symbol.
(define events '((inc . 3) (dec . 1) reset (dec . 2)))
;; Bind the result of one pure transition for use in later branches.
(define snapshot (step 0 '(inc . 3)))
;; Evaluate the factory once so later calls share one captured binding.
(define ticker (make-ticker))
;; Use '() for a replay with no events.
(emit "empty" (replay 0 '()))
;; Pass the event list as data, then print the returned history.
(emit "replay" (replay 0 events))
;; list collects results of independent calls from the same snapshot.
(emit "branch" (list (step snapshot '(inc . 5))
                     ;; Apply the reset branch and include the original
                     ;; snapshot as evidence.
                     (step snapshot 'reset) snapshot))
;; let* fixes the order of the two calls for this diagnostic.
;; let* evaluates the first ticker call before the second.
(let* ((first (ticker)) (second (ticker)))
  ;; list displays the two successive values from the stateful closure.
  (emit "mutable-probe" (list first second)))
