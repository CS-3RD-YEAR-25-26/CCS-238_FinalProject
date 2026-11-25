;; Persistent Vectors
;; let binds local names.
;; assoc returns a new vector with the modified value.
;; The original vector remains unchanged because
;; Clojure's persistent collections are immutable.

(let [original ["Ana" "Ben" "Cara"]
      alias original
      updated (assoc original 1 "Bea")]

  (println "Original Vector:" original)
  (println "Alias Vector:   " alias)
  (println "Updated Vector: " updated))
