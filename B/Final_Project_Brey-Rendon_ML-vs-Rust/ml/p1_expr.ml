 % ======================================================================
  P1: Expression evaluator, in 1973 ML (run on HOL88 Classic ML)

  Problem: represent arithmetic expressions as a tree (a syntax tree),
  then compute each expression's value and print it with brackets that
  show how the tree is grouped.
  An expression is one of four kinds:
    a number, an addition, a multiplication, or a negation.

  Test data (the same as the Rust version) and expected results:
    (2 + 3) * 4          ->  ((2 + 3) * 4) = 20
    2 + 3 * 4            ->  (2 + (3 * 4)) = 14
    -(2 + 3)             ->  -(2 + 3) = -5
    (1 + 2) * (3 + 4)    ->  ((1 + 2) * (3 + 4)) = 21

  Run: start hol88 in the ml folder, then type   loadt `p1_expr`;;
  ====================================================================== %


% 1. THE EXPRESSION TYPE
  1973 ML has no user-defined datatypes, so the four kinds of expression
  cannot be declared by name. They are ENCODED as nested disjoint sums.
  A sum (+) has only two sides, so four kinds need three nested levels:
    number          ->  left                          (holds an int)
    addition        ->  right, then left              (holds a pair)
    multiplication  ->  right, right, then left       (holds a pair)
    negation        ->  right, right, right           (holds one expr)
  (HOL88 prints nested sums without brackets: a + b + c means a + (b + c).)

  absrectype hides the encoding behind the name expr. Inside "with",
  abs_expr wraps a raw sum value and rep_expr unwraps it. The functions
  defined there follow the style LCF itself used for its own abstract
  types (HOL88 still has mk_comb, is_comb and dest_comb for terms):
    num, add, mul, neg    build an expression
    is_num ... is_neg     test which kind an expression is
    dest_num ... dest_neg take an expression apart
  Every position (inl, outr, ...) must be written by hand and kept
  consistent; a mistake that still type-checks is found only at run time.
  & means "and", and it stops early: if its left side is false, the right
  side is never evaluated, so outr is never applied to the wrong side. %

absrectype expr = int + (expr # expr) + (expr # expr) + expr
  with num n = abs_expr (inl n)
  and add a b = abs_expr (inr (inl (a, b)))
  and mul a b = abs_expr (inr (inr (inl (a, b))))
  and neg a = abs_expr (inr (inr (inr a)))
  and is_num e = isl (rep_expr e)
  and is_add e = let v = rep_expr e in
      not (isl v) & isl (outr v)
  and is_mul e = let v = rep_expr e in
      not (isl v) & not (isl (outr v)) & isl (outr (outr v))
  and is_neg e = let v = rep_expr e in
      not (isl v) & not (isl (outr v)) & not (isl (outr (outr v)))
  and dest_num e = outl (rep_expr e)
  and dest_add e = outl (outr (rep_expr e))
  and dest_mul e = outl (outr (outr (rep_expr e)))
  and dest_neg e = outr (outr (outr (rep_expr e)));;


% 2. EVALUATE
  With no case expression, eval asks "which kind is it?" one test at a
  time, then takes the expression apart with the matching dest_ function.
  The last line cannot happen with the four kinds above. If a fifth kind
  (for example subtraction) were added to the type but not to eval,
  nothing would warn the programmer: the program would load normally and
  fail only when such an expression is evaluated. The Rust version's
  match refuses to compile in that situation. %

letrec eval e =
  if is_num e then dest_num e
  else if is_add e then (let (a, b) = dest_add e in eval a + eval b)
  else if is_mul e then (let (a, b) = dest_mul e in eval a * eval b)
  else if is_neg e then 0 - eval (dest_neg e)
  else failwith `eval: unknown kind of expression`;;


% 3. SHOW: turn an expression back into text, with full brackets.
  string_of_int turns a number into text, and ^ joins two strings. %

letrec show e =
  if is_num e then string_of_int (dest_num e)
  else if is_add e then (let (a, b) = dest_add e in `(` ^ show a ^ ` + ` ^ show b ^ `)`)
  else if is_mul e then (let (a, b) = dest_mul e in `(` ^ show a ^ ` * ` ^ show b ^ `)`)
  else if is_neg e then `-` ^ show (dest_neg e)
  else failwith `show: unknown kind of expression`;;

let report e = show e ^ ` = ` ^ string_of_int (eval e);;


% 4. TESTS (the same data as the Rust version)
  The tree, not the text, decides the grouping: the first two tests use
  the same numbers and operators but build different trees. %

report (mul (add (num 2) (num 3)) (num 4));;
report (add (num 2) (mul (num 3) (num 4)));;
report (neg (add (num 2) (num 3)));;
report (mul (add (num 1) (num 2)) (add (num 3) (num 4)));;
