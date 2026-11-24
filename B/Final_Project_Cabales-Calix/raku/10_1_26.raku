# rx// builds a Regex value that can be stored and reused in a smartmatch.
# The || alternation tries the left alternative first. The unanchored regex can match within the subject.
my $p = rx/ 'cat' || 'dog' /;
say ('a dog' ~~ $p) ?? 'yes' !! 'no';
