# my creates a lexical binding, so the inner $x in g shadows the outer one only inside g.
# f resolves $x in the scope where f was declared, even when g calls it.
my $x = 1;
sub f() { $x }
sub g() { my $x = 2; f() }
say g();
say $x;
