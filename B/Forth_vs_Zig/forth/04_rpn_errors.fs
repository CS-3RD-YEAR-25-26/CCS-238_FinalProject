\ ===========================================================================
\ 04_rpn_errors.fs  --  A reverse-Polish calculator with error handling
\ CCS 238 Final Project: Forth (1970) vs. Zig (2016)
\ Run:  gforth 04_rpn_errors.fs -e bye
\
\ Topics exercised: Exception handling (CATCH / THROW), Syntax & semantics
\ (postfix evaluation, division rounding), the shared data stack.
\
\ Forth is itself a postfix language, so the calculator's operand stack IS
\ the Forth data stack.  The price: parser state cannot live on that stack
\ too (it would mix with the operands), so it is kept in VARIABLEs.
\ ===========================================================================

\ User-defined THROW codes.  The standard reserves -1 .. -255 for its own
\ codes (e.g. -10 = division by zero) and -256 .. -4095 for the Forth
\ system, so the application codes here are positive.
1 constant err-underflow
2 constant err-overflow
3 constant err-divzero
4 constant err-unknown
5 constant err-malformed

8 constant capacity              \ max operands, same limit as the Zig version

variable src         \ address of the not-yet-scanned input
variable len         \ characters left in the input
variable base-depth  \ stack depth when evaluation started

: operands ( -- n )   depth base-depth @ - ;    \ DEPTH = items on the stack
: need ( n -- )   operands 1- > IF err-underflow throw THEN ;
: check-capacity ( -- )   operands capacity > IF err-overflow throw THEN ;

\ ---------------------------------------------------------------------------
\ Tokenizer.  BEGIN ... WHILE ... WHILE ... REPEAT THEN is a standard loop
\ with two exit tests; the extra THEN closes the second WHILE.
\ ---------------------------------------------------------------------------
: advance ( -- )   1 src +!  -1 len +! ;

: skip-spaces ( -- )
  BEGIN len @ WHILE src @ c@ bl = WHILE advance REPEAT THEN ;

: next-token ( -- c-addr u )                    \ u = 0 at end of input
  skip-spaces  src @ 0
  BEGIN len @ WHILE src @ c@ bl <> WHILE 1+ advance REPEAT THEN ;

\ >NUMBER converts as many digits as it can into a double-cell number and
\ returns the unconverted remainder; the token is a number if nothing is left.
: to-number ( c-addr u -- n true | false )
  0 0 2swap >number nip nip 0= IF true ELSE drop false THEN ;

\ ---------------------------------------------------------------------------
\ Operators.  CASE ... OF ... ENDOF ... ENDCASE: OF compares and, on a match,
\ DROPS the selector, so each branch sees only the operands.  Note that the
\ arithmetic words themselves check nothing: + and * wrap silently, and /
\ rounds toward negative infinity in Gforth (Forth-94 leaves the rounding
\ implementation-defined).
\ ---------------------------------------------------------------------------
: apply-op ( char -- )
  CASE
    [char] + OF 2 need  +  ENDOF
    [char] - OF 2 need  -  ENDOF
    [char] * OF 2 need  *  ENDOF
    [char] / OF 2 need  dup 0= IF err-divzero throw THEN  /  ENDOF
    err-unknown throw                   \ default branch: no OF matched
  ENDCASE ;

: eval-token ( c-addr u -- )
  2dup to-number IF  nip nip check-capacity EXIT  THEN   \ a number: leave it
  1 <> IF drop err-unknown throw THEN                    \ operators are 1 char
  c@ apply-op ;

: (rpn) ( c-addr u -- n )
  len ! src !  depth base-depth !
  BEGIN next-token dup WHILE eval-token REPEAT 2drop
  operands 1 <> IF err-malformed throw THEN ;

\ ---------------------------------------------------------------------------
\ CATCH ( i*x xt -- j*x 0 | i*x code ) executes xt.  If anything inside it
\ THROWs, control returns here with the stack DEPTH restored to what it was
\ before CATCH (the 2 input cells), and the throw code on top.  Leftover
\ operands from a failed evaluation are discarded automatically.
\ ---------------------------------------------------------------------------
: .rpn-error ( code -- )
  CASE
    err-underflow OF ." error: stack underflow"  ENDOF
    err-overflow  OF ." error: stack overflow"   ENDOF
    err-divzero   OF ." error: division by zero" ENDOF
    err-unknown   OF ." error: unknown token"    ENDOF
    err-malformed OF ." error: malformed expression (not exactly 1 result)" ENDOF
    dup ." error: system THROW code " .
  ENDCASE ;

: rpn ( c-addr u -- )
  2dup [char] " emit type [char] " emit  ."  => "
  ['] (rpn) catch                     \ ['] compiles the xt of (rpn)
  ?dup IF  nip nip .rpn-error  ELSE  .  THEN  cr ;

: main ( -- )
  ." === RPN calculator: Forth CATCH / THROW ===" cr
  s" 3 4 + 2 *"                rpn
  s" 5 1 2 + 4 * + 3 -"        rpn
  s" 0 7 - 2 /"                rpn     \ -7 / 2: floored division gives -4
  s" 1 +"                      rpn
  s" 10 0 /"                   rpn
  s" 2 x *"                    rpn
  s" 2 3 4"                    rpn
  s" 1 2 3 4 5 6 7 8 9"        rpn
  s" 9223372036854775807 1 +"  rpn     \ max signed 64-bit + 1: wraps
  s" "                         rpn
  ." data stack after all evaluations: " .s cr ;

main
