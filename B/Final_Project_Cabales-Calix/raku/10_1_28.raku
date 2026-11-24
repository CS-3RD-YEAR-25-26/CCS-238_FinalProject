# The :g adverb makes s/// replace every nonoverlapping match in this run.
# Smartmatching targets the left-hand scalar, so the substitution updates $s in place.
my $s = 'cat cat';
$s ~~ s:g/cat/dog/;
say $s;
