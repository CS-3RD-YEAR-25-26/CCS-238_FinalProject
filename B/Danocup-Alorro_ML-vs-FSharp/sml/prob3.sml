(* Problem 3: a generic stack built with SML's module system.
   Three module-level ideas are used here:
     signature = an interface (what operations exist, and their types)
     structure = an implementation (the actual code)
     functor   = a function from structures to structures *)

(* exception Empty: declared ONCE at top level, outside any module.
   If it were declared inside the functor body, every MakeStack application would create
   its own brand-new exception that merely shares the name Empty. The 'handle Empty' at
   the bottom of the file would then be looking for a different exception and would not
   catch it. Declaring it here means there is exactly one Empty, visible to both the
   functor (which raises it) and the test code (which handles it). *)
exception Empty;

(* signature PRINTABLE: the interface for "something we can print".
   'type t' is ABSTRACT in a signature: it only says "some type called t exists",
   without saying which one.
   'val toString : t -> string' says that whatever t is, there is a function to show it. *)
signature PRINTABLE =
sig
  type t
  val toString : t -> string
end;

(* structure IntElem: a concrete implementation of PRINTABLE for integers.
   Here 'type t = int' is CONCRETE: it states exactly what t is.
   Int.toString has type int -> string, so it satisfies 'toString : t -> string'.
   The ': PRINTABLE' is ascription, a contract the compiler checks. IntElem must supply
   everything PRINTABLE lists, with the right types, or compilation fails. *)
structure IntElem : PRINTABLE =
struct
  type t = int
  val toString = Int.toString
end;

(* signature STACK: the interface every stack must provide.
   It has two abstract types, 'elem' (what the stack holds) and 'stack' (the stack itself).
   Then eight operations: empty, push, pop, peek, isEmpty, size, toString.
   The types describe a purely functional stack: push and pop return a NEW stack
   rather than changing the old one. pop returns a pair (top element, remaining stack). *)
signature STACK =
sig
  type elem
  type stack
  val empty : stack
  val push : elem * stack -> stack
  val pop : stack -> elem * stack
  val peek : stack -> elem
  val isEmpty : stack -> bool
  val size : stack -> int
  val toString : stack -> string
end;

(* functor MakeStack: a function at the MODULE level. It takes a structure
   (Elem, which must match PRINTABLE) and returns a structure (which must match STACK).
   Elem.t and Elem.toString use the parameter: the functor knows nothing about the actual
   element type, only what PRINTABLE promises. That is what makes the stack generic.
   ': STACK' after the parameter checks that the result fulfils the STACK contract. *)
functor MakeStack (Elem : PRINTABLE) : STACK =
struct
  (* An element is whatever type the parameter's t is. *)
  type elem = Elem.t
  (* Implementation choice: a stack is just a list, with the top at the head. *)
  type stack = elem list
  (* The empty stack is the empty list. *)
  val empty = []
  (* push: put x at the front of the list. '::' builds a new list; the old one is untouched. *)
  fun push (x, s) = x :: s
  (* pop: popping an empty stack is an error, so raise the top-level Empty exception.
     Otherwise return the top element together with the rest of the list as the new stack. *)
  fun pop [] = raise Empty
    | pop (x::xs) = (x, xs)
  (* peek: like pop, but returns only the top element; the stack is not needed back.
     '_' means "I don't care about the rest". *)
  fun peek [] = raise Empty
    | peek (x::_) = x
  (* isEmpty: 'null' tests whether a list is empty. *)
  fun isEmpty s = null s
  (* size: the number of elements, which is the length of the list. *)
  fun size s = List.length s
  (* toString: convert each element with the parameter's Elem.toString (List.map),
     join them with ", " (String.concatWith), then wrap in brackets. *)
  fun toString s =
    "[" ^ String.concatWith ", " (List.map Elem.toString s) ^ "]"
end;

(* Apply the functor: build a stack of ints by passing IntElem in.
   Ascribing ': STACK' again checks the contract on the result.
   Note on ascription: ':' is TRANSPARENT. It checks the contract but does not hide how
   the types are really defined, so IntStack.stack is still known to be int list.
   Because of that, code outside could technically treat a stack as a plain list
   (the REPL printing [3,2,1] : IntStack.stack is a hint of this). To truly hide the
   representation you would use OPAQUE ascription, ':>' instead of ':'.
   Transparency on IntElem is what lets IntStack.elem be known as int, so that
   pushing the literal 3 works. *)
structure IntStack : STACK = MakeStack (IntElem);

(* Test 1: a brand-new empty stack. s0 is the starting value. *)
val s0 = IntStack.empty;
(* Bool.toString / Int.toString turn values into strings so '^' can join them.
   The expression continues on the next line; SML ignores line breaks. *)
val _ = print ("Test 1: isEmpty=" ^ Bool.toString (IntStack.isEmpty s0)
               ^ " size=" ^ Int.toString (IntStack.size s0) ^ "\n");

(* Test 2: push 1, then 2, then 3 (the innermost push runs first).
   This gives a NEW stack s3 = [3, 2, 1]. s0 is unchanged and is still empty.
   Nothing is mutated anywhere in this file: each step produces a new value
   (s0 -> s3 -> s3a -> s3b -> s4) and old ones remain valid. *)
val s3 = IntStack.push (3, IntStack.push (2, IntStack.push (1, s0)));
val _ = print ("Test 2: peek=" ^ Int.toString (IntStack.peek s3)
               ^ " size=" ^ Int.toString (IntStack.size s3)
               ^ " toString=" ^ IntStack.toString s3 ^ "\n");

(* Test 3: pop returns a pair (element, new stack).
   'val (popped1, s3a) = ...' is tuple destructuring: it matches the pair and binds
   both names at once. popped1 = 3, and s3a = [2, 1] is a new stack.
   The second pop works on s3a, giving popped2 = 2 and s3b = [1]. *)
val (popped1, s3a) = IntStack.pop s3;
val (popped2, s3b) = IntStack.pop s3a;
val _ = print ("Test 3: popped=" ^ Int.toString popped1 ^ "," ^ Int.toString popped2
               ^ " size=" ^ Int.toString (IntStack.size s3b)
               ^ " peek=" ^ Int.toString (IntStack.peek s3b) ^ "\n");

(* Test 4: pop the last element. popped3 = 1, and s4 is the empty stack again. *)
val (popped3, s4) = IntStack.pop s3b;
val _ = print ("Test 4: popped=" ^ Int.toString popped3
               ^ " isEmpty=" ^ Bool.toString (IntStack.isEmpty s4) ^ "\n");

(* Test 5: popping the empty stack s4 raises Empty.
   #1 picks the first component of a tuple (the popped element), but the pop fails before
   that. 'raise Empty' inside pop propagates out, and 'handle Empty' catches it, so
   test5 becomes the fallback string instead of the program crashing. *)
val test5 = ("popped " ^ Int.toString (#1 (IntStack.pop s4))) handle Empty => "Empty stack caught";
val _ = print ("Test 5: " ^ test5 ^ "\n");
