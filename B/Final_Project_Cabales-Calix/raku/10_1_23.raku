# The Animal constraint permits a Dog instance because Dog inherits from Animal.
# Calling .sound dispatches to the override on the actual Dog object at runtime.
class Animal { method sound { '?' } }
class Dog is Animal { method sound { 'woof' } }
my Animal $pet = Dog.new;
say $pet.sound;
