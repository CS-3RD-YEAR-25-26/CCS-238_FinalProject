# The type constraints after my restrict what each scalar can store.
# Exponent notation gives a Num here. The decimal literal 1.1 gives an exact Rat.
# The .^name metaoperation reports the runtime type name. The == comparison produces a Bool.
my Str $s = 'John';
my Int $i = 6;
my Num $r = 1.1e0;
my Rat $q = 1.1;
my Bool $ok = $i == 6;
say $s.^name;
say $i.^name;
say $r.^name;
say $q.^name;
say $ok;
