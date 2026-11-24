# The for loop feeds an inclusive range into the pointy block parameter $i.
# The if statement modifier runs last only at the stopping value. last exits the loop before say runs.
for 1..3 -> $i {
    last if $i == 2;
    say $i;
}
