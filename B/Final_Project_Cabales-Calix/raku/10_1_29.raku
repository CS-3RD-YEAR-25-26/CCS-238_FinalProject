# TOP delegates to the named pair subrule. The nested <pair> call makes the rule recursive.
# The 'x' alternative terminates the nesting, and .parse requires the complete input to match.
grammar Nested {
    token TOP { <pair> }
    regex pair { 'a' <pair> 'b' || 'x' }
}
say Nested.parse('aaxbb') ?? 'yes' !! 'no';
