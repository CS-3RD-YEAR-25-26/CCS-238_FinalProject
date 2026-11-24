# The $!bal twigil keeps the attribute private to the class.
# The deposit and balance methods provide separate interfaces for changing and reading the stored value.
class Account {
    has $!bal = 5;
    method deposit($n) { $!bal += $n }
    method balance { $!bal }
}
my $a = Account.new;
$a.deposit(2);
say $a.balance;
