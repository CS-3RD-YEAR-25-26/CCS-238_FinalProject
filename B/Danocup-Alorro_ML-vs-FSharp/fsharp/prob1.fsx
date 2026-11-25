(* # Problem 1: Expression Tree Evaluator*)
(* #In this section, we define a new type called 'Expr' representing arithmetic expression trees.
   So each case is one kind of node in the tree:
   - Value holds a plain integer (represents the leaf)
   - Add/Subtract/Multiply/Divide each hold a tuple of sub-expressions (left, right) *)
type Expr =
    | Value of int
    | Add of Expr * Expr
    | Subtract of Expr * Expr
    | Multiply of Expr * Expr
    | Divide of Expr * Expr

(* # this portion is where we bind our recursion function named 'evaluate'. It recursively computes the integer value of an expression.
   It uses pattern matching: F# picks the clause matching the discriminated union case. *)
let rec evaluate expr =
    match expr with
    | Value v -> v                                       // Base case: a constant evaluates to itself
    | Add (e1, e2) -> evaluate e1 + evaluate e2          // Evaluate both sides, then add
    | Subtract (e1, e2) -> evaluate e1 - evaluate e2     // Evaluate both sides, then subtract
    | Multiply (e1, e2) -> evaluate e1 * evaluate e2     // Evaluate both sides, then multiply
    | Divide (e1, e2) -> evaluate e1 / evaluate e2       // Integer division; raises exception if e2 is 0

(* #this part contains the execution tests printing the results to the console.
   Brief explanation that 'printfn' is F#'s built-in formatted printing function. *)
printfn "Test 1: %d" (evaluate (Value 5))
printfn "Test 2: %d" (evaluate (Add (Value 2, Value 3)))
printfn "Test 3: %d" (evaluate (Multiply (Add (Value 2, Value 3), Value 4)))
printfn "Test 4: %d" (evaluate (Subtract (Value 10, Multiply (Value 2, Value 3))))
printfn "Test 5: %d" (evaluate (Divide (Value 7, Value 2)))

(* #This part demonstrates catching the division by zero error.
   'try ... with' catches exceptions and allows the program to continue instead of crashing. *)
let test6 =
    try
        let eq6 = evaluate (Divide (Value 1, Value 0))
        printfn "Test 6: %d" eq6
    with
    | :? System.DivideByZeroException ->                 // catches the division by zero error
        printfn "Test 6: Division by zero caught"