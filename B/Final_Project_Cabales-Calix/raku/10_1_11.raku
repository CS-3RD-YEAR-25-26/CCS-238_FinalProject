# A sub declared as infix:<§> defines an operator used between two operands.
# The is equiv trait places § at the same precedence as the existing infix + operator.
sub infix:<§>($a,$b) is equiv(&infix:<+>) { $a + $b }
say 3 § 4;
