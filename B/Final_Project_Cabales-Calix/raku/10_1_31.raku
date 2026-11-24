# TOP names each operand with <x=.num> and <y=.num>. The num token accepts a nonempty run of digits.
# Passing an actions object makes the matching TOP rule call the corresponding action method with the Match.
# The action converts captures to Int and attaches the computed value with make. The caller reads it with .made.
grammar Command {
    token TOP { <op> '(' <x=.num> ',' <y=.num> ')' }
    token op { 'ADD' | 'MUL' }
    token num { <[0..9]>+ }
}

class Evaluate {
    method TOP($/) {
        my $a = $<x>.Str.Int;
        my $b = $<y>.Str.Int;
        make ($<op>.Str eq 'ADD' ?? $a + $b !! $a * $b);
    }
}

my $m = Command.parse('MUL(6,7)', actions => Evaluate.new);
say $m ?? 'Result: ' ~ $m.made !! 'invalid';
