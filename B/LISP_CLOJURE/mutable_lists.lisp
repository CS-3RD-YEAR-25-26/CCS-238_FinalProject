;; Mutable Lists
;; LIST creates a linked list using cons cells.
;; LET* creates local variables in sequential order.
;; SETF modifies the existing list through NTH.
;; Both variables refer to the same list object.

(let* ((original (list "Ana" "Ben" "Cara"))
       (alias original))

  (setf (nth 1 original) "Bea")

  (format t "Original List: ~S~%" original)
  (format t "Alias List:    ~S~%" alias))
