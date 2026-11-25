(* Problem 2: word frequency counter.
   Pipeline: raw text -> cleaned lowercase text -> list of words
             -> (word, count) pairs -> sorted pairs -> printed output.
   Nothing here is ever mutated; every step builds a NEW value from the old one. *)

(* The input text. Contains punctuation and mixed case on purpose, so we have
   to clean it up before counting. *)
val text = "The cat sat on the mat. The cat slept! A dog barked, and the dog ran. Cat and dog.";

(* normalize: char -> char
   Letters become lowercase; anything else (spaces, '.', '!', ',') becomes a space.
   #" " is SML's syntax for a single CHARACTER literal (type char).
   A plain " " would be a string, and the if/else branches must have the same type. *)
fun normalize c = if Char.isAlpha c then Char.toLower c else #" ";

(* Two higher-order functions (functions that take functions as arguments):
   - String.map normalize text : applies 'normalize' to every character, giving a new string.
   - String.tokens Char.isSpace : splits a string on every char where Char.isSpace is true
     and drops empty pieces, so runs of spaces don't produce "" entries.
   Result: a string list, e.g. ["the", "cat", "sat", ...]. Evaluated inside-out. *)
val words = String.tokens Char.isSpace (String.map normalize text);

(* addWord: adds one occurrence of a word to the association list.
   An association list is a list of (key, value) pairs, here (word, count).
   It stands in for a dictionary, but it is PURE: SML has no mutation here, so
   "updating" a count means returning a brand-new list with that entry changed.

   Its inferred type is  ''a * (''a * int) list -> (''a * int) list.
   The double-prime ''a is an EQUALITY type variable: it may only be instantiated
   with types that support '='. It is needed because we compare keys with 'w = w2'.
   SML/NJ may print a "polyEqual" warning: it means the generic '=' is being used
   on a polymorphic type, which is slower than a type-specific comparison.
   It is harmless here, since we only ever use strings.

   The two clauses cover every list shape (recursion on the list):
     - Empty list: the word is new, so start it with a count of 1. *)
fun addWord (w, []) = [(w, 1)]
  (* Non-empty list: split into the first entry (w2, n) and the remaining entries 'rest'. *)
  | addWord (w, (w2, n)::rest) =
      (* Found the word: keep everything else and bump this count by 1.
         '::' builds a new list; 'rest' is shared, not copied or modified. *)
      if w = w2 then (w2, n + 1)::rest
      (* Not this entry: keep it unchanged and keep searching in the rest of the list. *)
      else (w2, n)::addWord (w, rest);

(* List.foldl f init list walks the list left to right, THREADING an accumulator:
     acc0 = []
     acc1 = addWord (word1, acc0)
     acc2 = addWord (word2, acc1) ... and so on.
   Each step receives the accumulator built so far and returns the next one.
   The final accumulator is the full list of (word, count) pairs.
   foldl passes (element, accumulator), which matches addWord's argument order. *)
val counts = List.foldl addWord [] words;

(* insert: puts one (word, count) pair into an already sorted list.
   Order wanted: higher count first; ties broken alphabetically (A to Z).
   Empty list: the pair is the whole list. *)
fun insert ((w, n), []) = [(w, n)]
  | insert ((w, n), (w2, n2)::rest) =
      (* The new pair goes BEFORE the head if it has a bigger count, or the same count
         and a word that comes first alphabetically.
         String.compare returns LESS, EQUAL or GREATER, so we compare its result to LESS.
         We use it instead of '<' because nothing in this function says w is a string.
         SML would then fall back to its default for the overloaded '<', which is int,
         and the code would not type-check against strings. String.compare removes the guess. *)
      if n > n2 orelse (n = n2 andalso String.compare (w, w2) = LESS)
      then (w, n)::(w2, n2)::rest
      (* Otherwise keep the head where it is and keep looking further down the list. *)
      else (w2, n2)::insert ((w, n), rest);

(* isort: insertion sort. Sorting an empty list gives an empty list.
   Otherwise sort the tail first, then insert the head into the sorted result. *)
fun isort [] = []
  | isort (x::xs) = insert (x, isort xs);

(* Sort the counted pairs into the final display order. *)
val sorted = isort counts;

(* printCounts: prints one "word count" line per pair.
   Base case: nothing left to print. () is the unit value, SML's "no meaningful result".
   Both clauses must return the same type, and 'print' returns unit, so we return () too. *)
fun printCounts [] = ()
  | printCounts ((w, n)::rest) =
      (* Parentheses with ';' form a sequence: run the first expression for its side
         effect (printing), discard its unit result, then evaluate and return the second.
         Int.toString is needed because '^' only joins strings. *)
      (print (w ^ " " ^ Int.toString n ^ "\n"); printCounts rest);

(* Run it. 'val _ =' throws away the unit value that printCounts returns. *)
val _ = printCounts sorted;
