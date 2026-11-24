# Num on the declaration constrains the lexical scalar to a floating-point value.
# Smartmatching against Num checks its type. The ?? !! operator selects one of the two strings.
my Num $x = 2.5e0;
say (($x ~~ Num) ?? 'yes' !! 'no');
