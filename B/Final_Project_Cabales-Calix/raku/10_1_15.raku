# sub declares a named routine with one parameter.
# The ?? !! expression evaluates only the selected branch, so recursion stops at the base case.
# The routine returns its final expression, which combines the current argument with the recursive result.
sub fact($n) {
    $n <= 1 ?? 1 !! $n * fact($n - 1)
}
say fact(4);
