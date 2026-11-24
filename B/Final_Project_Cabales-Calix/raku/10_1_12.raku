# The .Int conversion turns the string into an integer before the addition.
# .Str returns the display string. .^name queries the type of the original scalar value.
my $n = '12'.Int + 3;
say $n.Str;
say $n.^name;
