% ======================================================================
  P3: Generic binary search tree, in 1973 ML (run on HOL88 Classic ML)

  Problem: store values of any type in a binary search tree, then
  insert, look up, and list them in order.

  Test data (the same as the Rust version):
    numbers 5, 3, 8, 1, 4   ->  in order 1 3 4 5 8; 4 is present, 7 is not
    words pear, apple, fig  ->  in order apple fig pear

  Run: start hol88 in the ml folder, then type   loadt `p3_bst`;;
  ====================================================================== %


% 1. THE TREE TYPE
  1973 ML has no user-defined datatypes, so there is no way to declare
  "a tree is either Empty or a Node". Instead the tree is ENCODED with a
  disjoint sum (+), which has exactly two sides:
    left side  : void                  ->  the empty tree (carries no data)
    right side : (left, value, right)  ->  a node
  The # in the type is the pair/tuple type.

  absrectype ("abstract recursive type") hides that encoding behind the
  name  * tree , where * is a type variable: a tree of ANY element type.
  Inside the "with" part only, abs_tree wraps a raw sum value into a tree
  and rep_tree unwraps it. Outside, only the four functions defined here
  exist, so no other code can build or inspect a malformed tree. %

absrectype * tree = void + (* tree # * # * tree)
  with empty = abs_tree (inl ())
  and node l x r = abs_tree (inr (l, x, r))
  and is_empty t = isl (rep_tree t)
  and parts t = outr (rep_tree t);;


% 2. COMPARING ELEMENTS
  ML's built-in < works on int only: comparing two strings with < is a
  type error, and the language has no way to give < a meaning for other
  types. So every tree function below takes the ordering as an extra
  argument, lt ("less than"). The Rust version uses the trait bound
  T: Ord instead.

  \a b. a < b  is an anonymous function (a lambda) of two arguments. %

let int_less = \a b. a < b;;

% Strings are compared letter by letter using character codes.
  explode splits a string into a list of one-letter strings, and
  ascii_code gives the code of a letter. hd and tl return the first
  element and the rest of a list; null tests whether a list is empty.
  letrec (not let) is needed because the function calls itself. %

letrec letters_less a b =
  if null b then false
  else if null a then true
  else let x = ascii_code (hd a) and y = ascii_code (hd b) in
       if x < y then true
       else if y < x then false
       else letters_less (tl a) (tl b);;

let string_less s1 s2 = letters_less (explode s1) (explode s2);;


% 3. INSERT
  1973 ML has no case expression, so each function first TESTS which kind
  of tree it has (is_empty), then takes a node apart by binding a tuple
  pattern:  let (l, y, r) = parts t in ...
  If parts were called on an empty tree it would fail only at run time;
  no compiler check prevents that mistake.

  No type annotations appear anywhere in this file. ML infers the most
  general type of every function, which HOL88 prints when the file loads.

  insert never changes a tree in place: it builds a new tree that shares
  the unchanged subtrees with the old one. %

letrec insert lt x t =
  if is_empty t then node empty x empty
  else let (l, y, r) = parts t in
       if lt x y then node (insert lt x l) y r
       else if lt y x then node l y (insert lt x r)
       else t;;


% 4. MEMBER: is x stored in the tree? %

letrec member lt x t =
  if is_empty t then false
  else let (l, y, r) = parts t in
       if lt x y then member lt x l
       else if lt y x then member lt x r
       else true;;


% 5. IN-ORDER LISTING: left subtree, then the value, then right subtree.
  @ joins two lists. %

letrec inorder t =
  if is_empty t then []
  else let (l, y, r) = parts t in inorder l @ [y] @ inorder r;;


% 6. BUILD A TREE FROM A LIST, inserting the elements left to right %

letrec build lt xs t =
  if null xs then t
  else build lt (tl xs) (insert lt (hd xs) t);;


% 7. TESTS (the same data as the Rust version) %

let numbers = build int_less [5; 3; 8; 1; 4] empty;;
inorder numbers;;
member int_less 4 numbers;;
member int_less 7 numbers;;

let words = build string_less [`pear`; `apple`; `fig`] empty;;
inorder words;;
member string_less `fig` words;;

% Type safety check: delete the two percent signs on the next line, then
  reload, to see ML reject a word inserted into a tree of numbers. %
% insert int_less `kiwi` numbers;; %
