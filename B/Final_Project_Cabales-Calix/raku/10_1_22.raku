# Dog inherits from Animal via is and overrides the kind method.
# Owner composes a Dog through a typed pet attribute. The reader exposes the nested object for the call.
class Animal { method kind { 'animal' } }
class Dog is Animal { method kind { 'dog' } }
class Owner { has Dog $.pet }
say Owner.new(pet => Dog.new).pet.kind;
