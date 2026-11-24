# The Int $!balance declaration is private and defaults to 5 for each new object.
# The deposit parameter is constrained to Int. Its if modifier gates the update on a positive amount.
# The method's final expression returns the current balance regardless of whether it changed.
class Account {
    has Int $!balance = 5;

    method deposit(Int $n) {
        $!balance += $n if $n > 0;
        $!balance
    }
}

say Account.new.deposit(2);
