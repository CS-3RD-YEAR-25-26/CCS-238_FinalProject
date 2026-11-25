;; Functional Programming and Recursion
;; DEFUN defines a reusable function.
;; IF provides conditional execution.
;; The function calls itself until it reaches the base case.
;; MAPCAR applies a function to every element in a list.
;; LAMBDA creates an anonymous function.

(defun factorial (n)

  (if (<= n 1)
      1
      (* n (factorial (1- n)))))

(format t "Factorial of 5: ~A~%"
        (factorial 5))

(format t "Numbers Doubled: ~S~%"
        (mapcar (lambda (number)
                  (* number 2))
                '(1 2 3)))
