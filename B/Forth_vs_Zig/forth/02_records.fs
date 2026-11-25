\ ===========================================================================
\ 02_records.fs  --  Records and memory management in Forth
\ CCS 238 Final Project: Forth (1970) vs. Zig (2016)
\ Run:  gforth 02_records.fs -e bye
\
\ Topics exercised: Names, bindings, scope & lifetime (dictionary memory vs.
\ heap memory), record handling, manual leak accounting.
\
\ Forth has three places to keep data, and the programmer chooses each time:
\   1. the DATA STACK      - transient values, no names, no lifetime rules
\   2. the DICTIONARY      - static memory grown by moving the HERE pointer
\                            (CREATE, ALLOT, ","); released only LIFO
\   3. the HEAP            - ALLOCATE / FREE (optional Memory-Allocation
\                            word set, added by the ANS standard in 1994)
\ ===========================================================================

\ ---------------------------------------------------------------------------
\ Static data in the dictionary.  CREATE makes a word that pushes the address
\ of the next free dictionary cell; "," (comma) stores a cell there and
\ advances HERE.  The table exists from load time until the program ends.
\ ---------------------------------------------------------------------------
create cutoffs  90 , 80 , 70 , 60 , 0 ,

: letter ( score -- char )
  5 0 DO
    dup cutoffs I cells + @ >= IF          \ cells converts an index to bytes
      drop s" ABCDF" drop I + c@           \ c@ fetches one byte (a char)
      UNLOOP EXIT                          \ UNLOOP must precede EXIT in DO
    THEN
  LOOP  drop [char] F ;

\ ---------------------------------------------------------------------------
\ A record type.  Forth has no struct keyword in the core language; the
\ Forth-2012 structure words below are themselves ordinary Forth: each field
\ name becomes a word that ADDS AN OFFSET to an address.  No type checking:
\ any number can be treated as a "student" address.
\ ---------------------------------------------------------------------------
begin-structure student          \ 'student' will push the record size
  field: s.next                  \ cell: address of next record (0 = none)
  field: s.score                 \ cell: score
  field: s.len                   \ cell: length of the name in bytes
  0 +field s.name                \ name bytes start here (variable length)
end-structure

\ ---------------------------------------------------------------------------
\ Heap allocation with hand-made leak accounting.  ALLOCATE returns
\ ( addr ior ); THROW raises an exception if ior (I/O result) is non-zero.
\ ---------------------------------------------------------------------------
variable live-blocks                          \ allocations not yet freed
: alloc   ( u -- addr )  allocate throw  1 live-blocks +! ;
: release ( addr -- )    free throw     -1 live-blocks +! ;

\ The roster is a singly linked list.  tail-link holds the ADDRESS of the
\ cell that must receive the next record: addresses are just numbers.
variable head
variable tail-link
: empty-list ( -- )  0 head !  head tail-link ! ;

: new-student ( c-addr u score -- node )
  >r                              \ park score on the RETURN stack for now
  dup student + alloc             \ ( c-addr u node ): header + name bytes
  0 over s.next !
  r> over s.score !               \ >r and r> must balance inside one word
  2dup s.len !
  dup >r s.name swap move r> ;    \ MOVE ( from to count ) copies the name

: append-node ( node -- )   dup tail-link @ !  s.next tail-link ! ;
: add-student ( c-addr u score -- )   new-student append-node ;

: .student ( node -- )
  ."   " dup s.name over s.len @ tuck type  12 swap - spaces
  s.score @ dup 3 .r  2 spaces letter emit cr ;

\ Iteration idiom: ?DUP duplicates only non-zero values, so the loop ends
\ (leaving nothing behind) when it reaches the 0 that terminates the list.
: .roster ( -- )   head @ BEGIN ?dup WHILE dup .student s.next @ REPEAT ;

: count+total ( -- count total )
  0 0 head @ BEGIN ?dup WHILE          ( count total node )
    rot 1+ -rot                        \ count+1, kept under total and node
    dup s.score @ rot + swap           \ total += score
    s.next @
  REPEAT ;

: better? ( best node -- flag )
  over 0= IF 2drop true EXIT THEN  s.score @ swap s.score @ > ;

: best-student ( -- node|0 )
  0 head @ BEGIN ?dup WHILE            ( best node )
    2dup better? IF nip dup THEN
    s.next @
  REPEAT ;

\ Pictured numeric output: <# ... #> builds digits right-to-left.  The value
\ is average*100, so "# #" emits two decimals before HOLD inserts the point.
: .hundredths ( n -- )   s>d <# # # [char] . hold #s #> type ;

: .stats ( -- )
  count+total                          ( count total )
  ."   count: " over .
  ." average: " 100 * swap / .hundredths
  ."   best: " best-student dup s.name over s.len @ type
  ."  (" s.score @ 0 .r ." )" cr ;

: name= ( c-addr u node -- flag )   dup s.name swap s.len @ compare 0= ;

\ Unlink and free the first record whose name matches.  'link' is the
\ address of the cell pointing at the current node (head, or some s.next).
: remove-student ( c-addr u -- )
  head
  BEGIN dup @ WHILE                    ( c-addr u link )
    >r 2dup r@ @ name= IF
      2drop r>                         ( link )
      dup @                            ( link node )
      dup s.next tail-link @ = IF over tail-link ! THEN   \ removing the tail
      dup s.next @ rot !               \ *link = node.next
      release EXIT                     \ the record's memory is returned now
    THEN
    r> @ s.next
  REPEAT  drop 2drop ;

\ Read s.next BEFORE freeing the node: after FREE the bytes are gone and
\ Forth will not stop you from reading them anyway (use-after-free).
: free-roster ( -- )
  head @ BEGIN ?dup WHILE dup s.next @ swap release REPEAT  empty-list ;

\ Dictionary memory is a stack too: HERE only moves up with ALLOT and can
\ only be given back from the top (negative ALLOT, or a MARKER word).
: dictionary-demo ( -- )
  here  1000 allot  here swap -
  ."   1000 ALLOT moved HERE by " . ." bytes" cr
  -1000 allot
  ."   -1000 ALLOT gave the most recent 1000 bytes back (LIFO only)" cr ;

: main ( -- )
  ." === Dictionary (static) memory ===" cr
  dictionary-demo cr

  ." === Heap records: ALLOCATE / FREE ===" cr
  empty-list
  s" Ana"   92 add-student
  s" Ben"   78 add-student
  s" Carla" 85 add-student
  s" Dan"   64 add-student
  s" Eve"   99 add-student
  .roster .stats
  ."   live heap blocks: " live-blocks @ . cr cr

  ." Removing Dan ..." cr
  s" Dan" remove-student
  .roster .stats
  ."   live heap blocks: " live-blocks @ . cr cr

  free-roster
  ." After free-roster, live heap blocks: " live-blocks @ . cr cr

  ." === A deliberate leak: allocate and forget ===" cr
  64 alloc drop                        \ the address is dropped: unreachable
  ."   live heap blocks: " live-blocks @ .
  ." <- only our own counter knows; Forth itself reports nothing" cr
  ."   data stack at end: " .s cr ;

main
