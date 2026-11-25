\ ===========================================================================
\ 01_recursion.fs  --  Recursion and parameter passing in Forth
\ CCS 238 Final Project: Forth (1970) vs. Zig (2016)
\ Run:  gforth 01_recursion.fs -e bye
\
\ Topics exercised: Subprograms & parameter passing (the implicit data stack),
\ Syntax & semantics (postfix), integer overflow behaviour.
\ ===========================================================================

\ ---------------------------------------------------------------------------
\ Forth syntax primer used throughout this file
\   \ ...           a comment to end of line ("\" is itself a word)
\   ( a b -- c )    a STACK-EFFECT comment: what the word takes off the data
\                   stack (left of --) and what it leaves (right of --).
\                   The compiler never checks these; they are documentation.
\   : name ... ;    a colon definition: compiles a new word into the dictionary
\   recurse         calls the word currently being defined (its name is not
\                   yet visible while it is being compiled)
\ ---------------------------------------------------------------------------

\ ---------------------------------------------------------------------------
\ 1. Factorial.  Parameters and results travel on the data stack; there are
\    no named parameters and no declared types.  A "cell" is 64 bits here.
\ ---------------------------------------------------------------------------
: factorial ( n -- n! )
  dup 2 < IF           \ dup copies n so the test does not consume it
    drop 1             \ IF ... ELSE ... THEN is postfix: the flag comes first
  ELSE
    dup 1- recurse     \ ( n n-1 ) -> ( n (n-1)! )
    *                  \ ( n! )   -- '*' wraps silently on overflow
  THEN ;

: .factorials ( -- )
  ." n    n! (64-bit cell arithmetic, no overflow check)" cr
  22 0 DO                       \ DO ... LOOP: counted loop, I = loop index
    I 2 .r  ."   "              \ .r prints a number right-aligned in 2 columns
    I factorial . cr            \ 21! does not fit in 64 bits: watch the sign
  LOOP ;

\ ---------------------------------------------------------------------------
\ 2. Towers of Hanoi.  Four parameters (n from to via) must be juggled on
\    the stack with PICK, because Forth words have no parameter names.
\    "k pick" copies the k-th item below the top (0 pick = dup).
\ ---------------------------------------------------------------------------
variable moves                      \ a global cell; lives for the whole run

: .move ( n from to -- )
  rot ."   move disk " .  swap ." from peg " emit ."  to peg " emit cr
  1 moves +! ;                      \ +! adds to the value stored at an address

\ Pure stack version: every argument is located by its depth on the stack.
: hanoi ( n from to via -- )
  3 pick 0= IF  2drop 2drop EXIT  THEN          \ base case: n = 0
  3 pick 1-  3 pick  2 pick  4 pick             \ ( n f t v  n-1 f v t )
  recurse                                       \ hanoi(n-1, from, via, to)
  3 pick 3 pick 3 pick .move                    \ print move of disk n f->t
  3 pick 1-  1 pick  3 pick  5 pick             \ ( n f t v  n-1 v t f )
  recurse                                       \ hanoi(n-1, via, to, from)
  2drop 2drop ;                                 \ discard our 4 arguments

\ The same algorithm with Gforth local variables.  { a b -- } pops the stack
\ into named, read-only locals (Forth-2012 spells this {: a b :}).  Locals
\ were not part of Moore's Forth; they were standardised only in 1994.
: hanoi-locals { n from to via -- }
  n 0= IF EXIT THEN
  n 1- from via to recurse
  n from to .move
  n 1- via to from recurse ;

\ ---------------------------------------------------------------------------
\ Driver.  .s prints the data stack non-destructively: it should be empty
\ ("<0>") after each call, which is the only evidence that every word
\ consumed exactly the arguments it promised in its stack comment.
\ ---------------------------------------------------------------------------
: main ( -- )
  ." === Factorial (recursive) ===" cr
  .factorials cr
  ." === Towers of Hanoi, 3 disks, pure-stack version ===" cr
  0 moves !  3 [char] A [char] C [char] B hanoi
  ." total moves: " moves @ . ."   stack after call: " .s cr cr
  ." === Towers of Hanoi, 3 disks, locals version ===" cr
  0 moves !  3 [char] A [char] C [char] B hanoi-locals
  ." total moves: " moves @ . ."   stack after call: " .s cr ;

main
