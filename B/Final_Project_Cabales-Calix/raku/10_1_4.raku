# Lexical declarations use $ for a scalar, @ for an array, and % for a hash.
# Array indices start at zero. %scores<Lean> looks up a literal string key in the hash.
# The & sigil names a callable. The pointy block -> $x supplies its parameter.
my $word = 'Lean';
say $word;


my @colors = 'red', 'blue';
say @colors[0] ~ ' | ' ~ @colors[1];



my %scores = 'Lean' => 9, 'Zuriel' => 7;
say 'Lean:' ~ %scores<Lean> ~ ' | Zuriel:' ~ %scores<Zuriel>;



my &greet = -> $x { 'Hi ' ~ $x };
say greet($word);
