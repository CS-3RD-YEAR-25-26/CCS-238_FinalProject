(* # Problem 3: Generic Object-Oriented Stack *)
(* # this part defines the generic interface every stack must provide.
   It declares the strict methods for pushing, popping, and checking state. *)
type IStack<'T> =
    abstract member Push : 'T -> unit
    abstract member Pop : unit -> 'T
    abstract member Peek : unit -> 'T
    abstract member IsEmpty : bool
    abstract member Size : unit -> int

(* # this portion defines a concrete class implementing the IStack interface we declared earlier.
   It encapsulates a private, mutable F# list to hold the stack elements. Note that F# list are immutable by default,
   so we use 'mutable' to allow us to reassign 'items' to a new list each time we push or pop. *)
type Stack<'T>() =
    let mutable items : 'T list = []                  // Implementation choice: stack is just a list

    (* # on this part, it overrides ToString to return elements formatted later as [3, 2, 1] top-first. *)
    override this.ToString() =
        let elements = items |> List.map string |> String.concat ", "
        sprintf "[%s]" elements

    interface IStack<'T> with
        (* #this part puts an item at the front of the list.
           '::' builds a new list; the mutable pointer 'items' is updated. *)
        member this.Push(item) =
            items <- item :: items

        (* # this part removes and returns the top element.
           Popping an empty list throws an InvalidOperationException. *)
        member this.Pop() =
            match items with
            | head :: tail -> 
                items <- tail
                head
            | [] -> invalidOp "Stack is empty"

        (* #This part returns only the top element without removing it. *)
        member this.Peek() =
            match items with
            | head :: _ -> head
            | [] -> invalidOp "Stack is empty"

        member this.IsEmpty =
            List.isEmpty items

        member this.Size() =
            List.length items

(* #this part tests the generic object-oriented stack with integers.
   We must upcast the Stack class to its interface (:> IStack) to use its methods. *)
let s0 = Stack<int>() :> IStack<int>

printfn "Test 1: isEmpty=%b size=%d" s0.IsEmpty (s0.Size())

(* # this part mutates the stack by pushing values sequentially.
   Unlike SML, this changes the single stack object in memory. *)
s0.Push(1)
s0.Push(2)
s0.Push(3)

printfn "Test 2: peek=%d size=%d toString=%s" (s0.Peek()) (s0.Size()) (s0.ToString())

let popped1 = s0.Pop()
let popped2 = s0.Pop()

printfn "Test 3: popped=%d,%d size=%d peek=%d" popped1 popped2 (s0.Size()) (s0.Peek())

let popped3 = s0.Pop()
printfn "Test 4: popped=%d isEmpty=%b" popped3 s0.IsEmpty

(* #This part catches the empty stack exception.
   Catches System.InvalidOperationException and formats output to match the SML specification. *)
let test5 =
    try
        sprintf "popped %d" (s0.Pop())
    with
    | :? System.InvalidOperationException -> "Empty stack caught"

printfn "Test 5: %s" test5