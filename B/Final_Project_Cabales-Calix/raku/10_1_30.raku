# TOP composes the key and value tokens around a literal '='.
# .parse returns a Match with named captures. Unary ~ stringifies each capture before concatenation.
grammar Pair {
    token TOP { <key> '=' <value> }
    token key { <[a..z]>+ }
    token value { <[0..9]>+ }
}
my $m = Pair.parse('age=42');
say ~$m<key> ~ ':' ~ ~$m<value>;
