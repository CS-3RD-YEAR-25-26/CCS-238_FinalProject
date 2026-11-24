# The := operator binds @b to the same array container as @a.
# Indexing at [0] through either name accesses the same element after the assignment.
my @a = 2;
my @b := @a;
@a[0] = 9;
say @b[0];
