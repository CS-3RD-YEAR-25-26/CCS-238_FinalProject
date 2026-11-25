;; Functional Programming and Recursion
;; defn defines a reusable function.
;; if provides conditional execution.
;; The function calls itself until it reaches the base case.
;; map applies a function to each collection element.
;; #() creates an anonymous function.

(defn factorial [n]
  (if (<= n 1)
    1
    (* n (factorial (dec n)))))

(println "Factorial of 5:"
         (factorial 5))

(println "Numbers Doubled:"
         (doall (map #(* % 2) [1 2 3])))
