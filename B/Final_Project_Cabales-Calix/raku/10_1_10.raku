# Division and multiplication share precedence and associate left to right in this expression.
# The && operator checks its right operand only after a truthy left operand. ?? !! selects the output.
say 8 / 2 * 2;
say (8 > 5 && 8 < 10) ?? 'yes' !! 'no';
