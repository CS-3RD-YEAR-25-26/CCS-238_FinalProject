\ ===========================================================================
\ 03_compile_time_crc32.fs  --  Compile-time execution in Forth
\ CCS 238 Final Project: Forth (1970) vs. Zig (2016)
\ Run:  gforth 03_compile_time_crc32.fs -e bye
\
\ Topic exercised: Language implementation -- running code while the
\ program is being compiled.  Problem: CRC-32 checksums using a 256-entry
\ lookup table that is computed before the program runs.
\
\ Key idea: Forth has no separate "compile phase".  The text interpreter
\ reads this file word by word and either EXECUTES each word (interpret
\ state) or COMPILES it into the current definition (compile state, between
\ ":" and ";").  Four ways to run code at compile time appear below:
\   1. plain interpretation while the file loads       (table construction)
\   2. CREATE ... DOES> defining words                 (a "CRC type" maker)
\   3. IMMEDIATE words that generate code              (loop unrolling)
\   4. [ ... ] LITERAL inside a definition             (precomputed constant)
\ plus [IF] ... [THEN] conditional compilation for a load-time self-test.
\ ===========================================================================

\ ---------------------------------------------------------------------------
\ 3. An IMMEDIATE word: it runs while the NEXT definition is being compiled.
\    ' (tick) parses the following word and returns its execution token (xt);
\    COMPILE, appends a call to that xt into the definition being built.
\    So "unroll8 foo" compiles eight calls to foo: unrolling done by user code.
\ ---------------------------------------------------------------------------
: unroll8 ( "name" -- )   ' 8 0 DO dup compile, LOOP drop ; IMMEDIATE

\ One bit-step of the reflected CRC algorithm.
: crc-bit ( poly c -- poly c' )
  dup 1 and IF  1 rshift over xor  ELSE  1 rshift  THEN ;

\ Table entry for byte c.  unroll8 executes NOW, during compilation, so the
\ compiled body is "swap crc-bit crc-bit ... crc-bit nip" with no loop.
: crc-entry ( c poly -- entry )   swap unroll8 crc-bit nip ;

\ ---------------------------------------------------------------------------
\ 2. A DEFINING WORD.  The part before DOES> runs when a new CRC is DEFINED
\    (at compile time): it builds the 256-entry table in the dictionary with
\    "," (comma).  The part after DOES> is the RUN-TIME behaviour shared by
\    every word created this way; it receives the table address.
\    This is Forth's way to make a family of related words -- comparable to
\    a generic type in Zig.
\ ---------------------------------------------------------------------------
: crc-algorithm: ( poly "name" -- )
  CREATE  256 0 DO  I over crc-entry ,  LOOP  drop
  DOES>  ( c-addr u table -- crc )
    $FFFFFFFF  2swap  bounds ?DO        ( table crc )  \ ?DO skips empty input
      over  over I c@ xor $FF and  cells + @  \ ( table crc entry )
      swap 8 rshift xor                       \ ( table crc' )
    LOOP  nip  $FFFFFFFF xor ;

\ ---------------------------------------------------------------------------
\ 1. Plain interpretation while loading: these two lines EXECUTE
\    crc-algorithm:, which runs the 256 x 8 table computation right now,
\    before any "run time" exists.  $ marks a hexadecimal literal.
\ ---------------------------------------------------------------------------
$EDB88320 crc-algorithm: crc32         \ IEEE 802.3 / zip / PNG
$82F63B78 crc-algorithm: crc32c        \ Castagnoli (iSCSI, ext4)

\ ---------------------------------------------------------------------------
\ Conditional compilation: [IF] decides at load time whether to keep
\ compiling.  If the table were wrong, loading stops here -- the closest
\ Forth analogue of a compile error, but it is just ordinary code running.
\ ---------------------------------------------------------------------------
s" 123456789" crc32 $CBF43926 <>
[IF] .( CRC-32 self-test FAILED while loading) cr abort [THEN]

\ ---------------------------------------------------------------------------
\ 4. [ ... ] LITERAL.  "[" switches to interpret state INSIDE a colon
\    definition, so the CRC below is computed during compilation; "]"
\    switches back, and LITERAL compiles the result as a constant.
\ ---------------------------------------------------------------------------
: check-value ( -- crc )   [ s" 123456789" crc32 ] LITERAL ;

\ Print a 32-bit value as 8 hex digits.  BASE is a variable holding the
\ current number base; we save it on the return stack and restore it.
: .hex32 ( u -- )
  base @ >r hex  0 <# # # # # # # # # #> type  r> base ! ;

: .crcs ( c-addr u -- )
  2dup [char] " emit type [char] " emit  cr
  2dup ."     crc32  = " crc32  .hex32 cr
       ."     crc32c = " crc32c .hex32 cr ;

: main ( -- )
  ." === CRC tables built at compile (load) time ===" cr
  ." check value computed during compilation: " check-value .hex32 cr
  ." crc32 table[1] = "
  ['] crc32 >body 1 cells + @ .hex32 cr cr     \ >body: xt -> its data (the table)
  s" 123456789" .crcs
  s" The quick brown fox jumps over the lazy dog" .crcs
  s" Forth vs. Zig" .crcs
  s" " .crcs
  cr ." Decompiled crc-entry (note: no loop, eight crc-bit calls):" ;

main
see crc-entry                     \ SEE parses a name, so it runs at top level
