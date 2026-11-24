# The public $.name attribute gets a reader and can be initialized with the named argument name.
# The greet method runs against the receiver, using its name to build the greeting.
class Person {
    has $.name;
    method greet { 'Hi ' ~ $.name }
}
say Person.new(name => 'Zuriel').greet;
