# The grammar's TOP token is the default entry point. The quantifier + requires at least one digit.
# .parse requires a complete match. The ?? !! expression selects an output based on whether a Match was returned.
grammar Digits {
    token TOP { \d+ }
}
say Digits.parse('123') ?? 'valid' !! 'invalid';
