(* #Problem 2: Word Counter *)
(* # This program on the other hand uses F# to count word frequencies in a given text.
      So we first initialize our namespaces to access .NET's s built-in data structures and function *)
open System
open System.Collections.Generic

(* #this part defines the input text. Contains punctuation and mixed case on purpose,
   so we have to clean it up before counting. *)
let text = "The cat sat on the mat. The cat slept! A dog barked, and the dog ran. Cat and dog."

(* # this part cleans the input by mapping characters.
   Letters become lowercase; anything else becomes a space. *)
let normalize c =
    if Char.IsLetter(c) then Char.ToLower(c) else ' '

(* #This part applies the normalization and splits the string into words.
   String.Split removes the empty entries created by consecutive spaces. *)
let words =
    let cleanedText = String(text |> Seq.map normalize |> Seq.toArray)
    cleanedText.Split([|' '|], StringSplitOptions.RemoveEmptyEntries)

(* # this part calculates the word frequencies using a mutable .NET Dictionary.
   Unlike SML's pure functional fold, this mutates state internally for performance. *)
let countWords (wordArray: string array) =
    let counts = Dictionary<string, int>()
    for word in wordArray do
        match counts.TryGetValue(word) wth
        | true, count -> counts.[word] <- count + 1   // Found the word: bump this count by 1
        | false, _ -> counts.[word] <- 1              // Not found: start it with a count of 1
    counts

let dictionaryCounts = countWords words

(* #This part converts the dictionary to a sequence and sorts it.
   Order wanted: higher count first (-n); ties broken alphabetically (w). *)
let sorted =
    dictionaryCounts
    |> Seq.map (fun kvp -> (kvp.Key, kvp.Value))
    |> Seq.sortBy (fun (w, n) -> (-n, w))

(* #this part prints one "word count" line per pair using a simple loop. *)
for (w, n) in sorted do
    printfn "%s %d" w n