# my declares $s as a lexical scalar.
# Smartmatching $s against s/// applies an in-place substitution to the first match.
my $s = 'cat bat';
$s ~~ s/cat/dog/;
say $s;
