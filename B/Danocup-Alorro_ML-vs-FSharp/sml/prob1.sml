(* Define a new type 'expr' representing arithmetic expression trees.
   Each constructor is one kind of node in the tree:
   - Const holds a plain integer (a leaf)
   - Add/Sub/Mul/Divide each hold a pair of sub-expressions (left, right) *)
(* NOTE: this constructor is named 'Divide', not 'Div', because SML already has
   a built-in exception called Div (raised by 'div'). Constructors and exceptions
   share one namespace, so naming it Div would shadow the exception and break
   the 'handle Div' in Test 6. *)
datatype expr = Const of int | Add of expr * expr | Sub of expr * expr | Mul of expr * expr | Divide of expr * expr;

(* 'eval' recursively computes the integer value of an expression.
   It uses pattern matching: SML picks the clause matching the constructor. *)
fun eval (Const n) = n                           (* Base case: a constant evaluates to itself *)
  | eval (Add (e1, e2)) = eval e1 + eval e2      (* Evaluate both sides, then add *)
  | eval (Sub (e1, e2)) = eval e1 - eval e2      (* Evaluate both sides, then subtract *)
  | eval (Mul (e1, e2)) = eval e1 * eval e2      (* Evaluate both sides, then multiply *)
  | eval (Divide (e1, e2)) = eval e1 div eval e2;  (* Integer division; raises Div if e2 is 0 *)

(* Test 1: a lone constant -> 5.
   Int.toString converts the int to a string, ^ concatenates strings,
   "\n" adds a newline, and 'val _ =' discards print's unit result. *)
val _ = print ("Test 1: " ^ Int.toString (eval (Const 5)) ^ "\n");

(* Test 2: 2 + 3 -> 5 *)
val _ = print ("Test 2: " ^ Int.toString (eval (Add (Const 2, Const 3))) ^ "\n");

(* Test 3: (2 + 3) * 4 -> 20. Nested tree: Add is a child of Mul. *)
val _ = print ("Test 3: " ^ Int.toString (eval (Mul (Add (Const 2, Const 3), Const 4))) ^ "\n");

(* Test 4: 10 - (2 * 3) -> 4. Mul is evaluated first as the right child of Sub. *)
val _ = print ("Test 4: " ^ Int.toString (eval (Sub (Const 10, Mul (Const 2, Const 3)))) ^ "\n");

(* Test 5: 7 / 2 -> 3. 'div' is integer division and truncates (floors) the result. *)
val _ = print ("Test 5: " ^ Int.toString (eval (Divide (Const 7, Const 2))) ^ "\n");

(* Test 6: 1 / 0 raises the Div exception.
   'handle' catches it and the whole expression evaluates to the fallback string instead of crashing. *)
val test6 = (Int.toString (eval (Divide (Const 1, Const 0)))) handle Div => "Division by zero caught";

(* Print the result of test 6: either a number or the caught-error message. *)
val _ = print ("Test 6: " ^ test6 ^ "\n");
