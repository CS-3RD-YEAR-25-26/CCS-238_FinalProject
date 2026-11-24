# The .^name metaoperation reports the class name of the object.
# .^attributes retrieves the class's attribute metadata. .elems counts entries in that result.
class Point { has $.x; has $.y }
my $p = Point.new(x => 3, y => 4);
say $p.^name;
say $p.^attributes.elems;
