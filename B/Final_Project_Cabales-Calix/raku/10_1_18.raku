# Box[::T] is a parameterized role. IntBox composes Box[Int], fixing the attribute type to Int.
# The public $.item declaration supplies a reader, and item => 7 initializes the attribute at construction.
role Box[::T] { has T $.item }
class IntBox does Box[Int] {}
say IntBox.new(item => 7).item;
