# The parentheses capture the numeric text after the literal 'ID='.
# The smartmatch returns a Match. $m[0] selects the first positional capture, and unary ~ stringifies it.
my $m = 'ID=69' ~~ / 'ID=' (<[0..9]>+) /;
say ~$m[0];
