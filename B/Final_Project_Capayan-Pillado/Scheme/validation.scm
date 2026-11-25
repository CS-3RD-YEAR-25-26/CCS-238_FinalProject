#lang scheme
;; Use the Scheme language selected by the source in DrRacket.

;; A question mark conventionally marks a predicate returning a boolean.
(define (decimal-text? text)
  ;; let* binds sequentially, so first can use the earlier size binding.
  (let* ((size (string-length text))
         ;; and checks the length before evaluating a character access.
         (first (if (and (> size 0)
                         ;; char=? checks a character literal written with
                         ;; Scheme's character syntax.
                         (char=? (string-ref text 0) #\-))
                    ;; if returns the zero-based index where the digit sequence
                    ;; starts.
                    1 0)))
    ;; A chained <= bounds the count after any leading sign.
    (and (<= 1 (- size first) 6)
         ;; Named let reuses a tail call to check the next character.
         ;; Named let binds index and gives the function a name for recursion.
         (let loop ((index first))
           ;; or stops at the end, so the later string-ref stays in bounds.
           (or (= index size)
               ;; let gives the current character a name limited to this
               ;; expression.
               (let ((ch (string-ref text index)))
                 ;; char<=? tests the inclusive digit range before recursion
                 ;; continues.
                 (and (char<=? #\0 ch #\9)
                      ;; The last operand of and can call loop in tail
                      ;; position.
                      (loop (+ index 1)))))))))

;; A procedure receives a Scheme value whose type is checked at runtime.
(define (validate-reading input)
  ;; The boundary checks the value's runtime type before parsing.
  ;; unless evaluates the body when the string? predicate returns false.
  (unless (string? input)
    ;; Racket's error names the procedure and formats the offending value.
    (error 'validate-reading "expected a string reading, got ~e" input))
  ;; not inverts the predicate for the malformed-data branch.
  (if (not (decimal-text? input))
      ;; Quote treats malformed as a symbol inside a literal result list.
      '(malformed)
      ;; Parse the checked string using 10 as the default radix.
      (let ((value (string->number input 10)))
        ;; The numeric comparison distinguishes parsing from the range rule.
        (if (< value 0)
            ;; Use a tag-only list for the negative result.
            '(negative)
            ;; list constructs a successful result containing a tag and a
            ;; value.
            (list 'accepted value)))))

;; Keep display operations in a helper that can receive any fixture.
(define (emit input)
  ;; write preserves the quotes on string inputs. display prints the separator.
  (write input) (display " -> ")
  ;; Print the tagged result and end the current output row.
  (write (validate-reading input)) (newline))

;; DrRacket and the Racket CLI expose script arguments as a vector.
;; Convert Racket's argument vector to a list for member's search.
(if (member "--wrong-type" (vector->list (current-command-line-arguments)))
    ;; Pass an integer deliberately so the guard shows a runtime error.
    (validate-reading 42)
    ;; for-each calls the output helper for effects over a quoted list.
    (for-each emit '("42" "0" "-0" "-3" "4.5" "#x10"
                     ;; The list includes whitespace and radix cases as literal
                     ;; strings.
                     "oops" "" " 7" "1/2" "999999" "1000000")))
