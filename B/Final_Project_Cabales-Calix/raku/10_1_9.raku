# The Int constraint on $x rejects a string assignment before changing the container.
# try traps the exception from the assignment, so execution reaches the read of the previous Int value.
my Int $x = 42;
try { $x = 'cat' };
say $x;
