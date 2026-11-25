% ======================================================================
  P2: Parse and average, in 1973 ML (run on HOL88 Classic ML)

  Problem: given a list of texts, turn each one into a whole number,
  report the texts that are not valid numbers (and why), and give the
  average of the valid ones.

  Rules (the same in both languages):
    - a valid number is non-empty and made only of the digits 0 to 9,
      so "-7" and "12a" are rejected
    - the average uses whole-number division (10 / 3 = 3)
    - if no text is valid, report an error instead of an average

  Test data (the same as the Rust version) and expected results:
    "10" "20" "x" "30"  ->  bad: "x" (not a digit)          average: 20
    "12a" "7"           ->  bad: "12a" (not a digit)        average: 7
    "" "-7" "5"         ->  bad: "" (empty) "-7" (not a digit)   average: 5
    "a" "b"             ->  no valid numbers, so the average is an error
    (empty list)        ->  no valid numbers, so the average is an error
    "2147483648" "5"    ->  the one intended difference: ML integers have no
                            size limit, so this number is accepted here, but
                            Rust rejects it as too large for a 32-bit integer

  Run: start hol88 in the ml folder, then type   loadt `p2_parse`;;
  ====================================================================== %


% 1. ONE DIGIT
  ascii_code gives a letter's character code; the digits 0 to 9 have
  codes 48 to 57. This ML has only < and > (no >= or <=), hence the
  bounds 47 and 58. & means "and".
  failwith raises a FAILURE carrying a message. Nothing in the type of
  digit_value, which is string -> int, says that it can fail. %

let digit_value c =
  let n = ascii_code c in
  if n > 47 & n < 58 then n - 48 else failwith `not a digit`;;


% 2. ONE NUMBER
  explode splits the text into a list of one-letter strings.
  digits_to_int works through them left to right:
  new value = 10 * value so far + next digit.
  If digit_value fails, the failure passes straight up through
  digits_to_int and parse_number to whoever called them, without any
  code here mentioning it: in ML a failure propagates INVISIBLY.
  The Rust version marks every such point with ?. %

letrec digits_to_int value ds =
  if null ds then value
  else digits_to_int (10 * value + digit_value (hd ds)) (tl ds);;

let parse_number s =
  if s = `` then failwith `empty`
  else digits_to_int 0 (explode s);;


% 3. SORT THE INPUTS INTO GOOD NUMBERS AND BAD TEXTS
  The result is a pair of lists: (numbers, bad texts). Each bad text is
  kept together with its failure message as a pair (text, message).
  e1 ?\msg e2 is a failure TRAP: if e1 fails, the failure message is
  bound to msg and the result is e2 instead. The dot (.) puts an
  element in front of a list.
  Note that ? traps EVERY failure raised inside e1, not only the ones
  parse_number was meant to raise. %

letrec split_inputs xs =
  if null xs then ([], [])
  else let (good, bad) = split_inputs (tl xs) in
       (parse_number (hd xs) . good, bad) ?\msg (good, (hd xs, msg) . bad);;


% 4. AVERAGE
  / is whole-number division. average fails when there are no numbers,
  which also prevents a division by zero. %

letrec sum xs = if null xs then 0 else hd xs + sum (tl xs);;

let average xs =
  if null xs then failwith `no valid numbers`
  else sum xs / length xs;;


% 5. REPORT
  ^ joins two strings, and string_of_int turns a number into text.
  The ?\msg trap catches the failure from average, so the report can
  say which error happened instead of stopping the program. %

letrec describe_bad xs =
  if null xs then ``
  else let (s, msg) = hd xs in
       `"` ^ s ^ `" (` ^ msg ^ `) ` ^ describe_bad (tl xs);;

let report xs =
  let (good, bad) = split_inputs xs in
  let bad_text = if null bad then `(none) ` else describe_bad bad in
  let avg_text = (string_of_int (average good)) ?\msg (`error: ` ^ msg) in
  `bad: ` ^ bad_text ^ `| average: ` ^ avg_text;;


% 6. TESTS (the same data as the Rust version) %

report [`10`; `20`; `x`; `30`];;
report [`12a`; `7`];;
report [``; `-7`; `5`];;
report [`a`; `b`];;
report [];;
report [`2147483648`; `5`];;
