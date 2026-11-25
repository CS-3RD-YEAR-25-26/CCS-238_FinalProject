Object subclass: LostAndFound [
    LostAndFound class >> items [
        ^OrderedCollection withAll: #(('Blue umbrella' 'umbrella' 'library')
            ('Black umbrella' 'umbrella' 'library') ('Red umbrella' 'umbrella' 'canteen')
            ('Steel bottle' 'bottle' 'library') ('Notebook' 'stationery' 'lobby'))]
    "select: keeps items for which the predicate block answers true."
    LostAndFound class >> matches: items category: category location: location [
        ^items select: [:item | (item at: 2) = category and: [(item at: 3) = location]]]
    LostAndFound class >> register: fields in: items [
        (fields anySatisfy: [:field | field allSatisfy: [:c | c isSeparator]]) ifTrue: [^false].
        items add: fields. ^true]]
Eval [
    | items check matches choice fields menuChoice location |
    items := LostAndFound items.
    (Smalltalk arguments includes: '--test') ifTrue: [
        check := [:condition | condition ifFalse: [
            stderr nextPutAll: 'lost_and_found_matcher test failed'; nl. ObjectMemory quit: 1]].
        matches := LostAndFound matches: items category: 'umbrella' location: 'library'.
        check value: ((matches collect: [:item | item first]) asArray = #('Blue umbrella' 'Black umbrella')).
        check value: (LostAndFound matches: items category: 'bottle' location: 'canteen') isEmpty.
        check value: (LostAndFound register: #(' ' 'jewelry' 'gym') in: items) not.
        check value: items size = 5.
        stdout nextPutAll: 'lost_and_found_matcher tests passed'; nl
    ] ifFalse: [
        [stdout nextPutAll: '1 Register | 2 Search | 3 Inventory | 4 Exit'; nl; flush.
            choice := stdin nextLine. choice notNil and: [choice ~= '4']] whileTrue: [
            menuChoice := choice.
            menuChoice = '1' ifTrue: [
                fields := OrderedCollection new.
                #('Item name:' 'Category:' 'Location:') do: [:prompt |
                    stdout nextPutAll: prompt; nl; flush. choice := stdin nextLine.
                    choice isNil ifTrue: [stdout nextPutAll: 'Input ended.'; nl. ^nil]. fields add: choice].
                stdout nextPutAll: ((LostAndFound register: fields in: items)
                    ifTrue: ['Item registered.'] ifFalse: ['Fields must not be blank.']); nl].
            menuChoice = '2' ifTrue: [
                stdout nextPutAll: 'Category:'; nl; flush. fields := stdin nextLine.
                fields isNil ifTrue: [stdout nextPutAll: 'Input ended.'; nl. ^nil].
                stdout nextPutAll: 'Location:'; nl; flush. location := stdin nextLine.
                location isNil ifTrue: [stdout nextPutAll: 'Input ended.'; nl. ^nil].
                matches := LostAndFound matches: items category: fields location: location.
                matches isEmpty ifTrue: [stdout nextPutAll: 'No matches.'; nl]
                    ifFalse: [matches do: [:item | stdout nextPutAll: item first; nl]]].
            menuChoice = '3' ifTrue: [
                items isEmpty ifTrue: [stdout nextPutAll: 'Inventory is empty.'; nl]
                    ifFalse: [items do: [:item | stdout nextPutAll: item first; nextPutAll: ' | ';
                        nextPutAll: (item at: 2); nextPutAll: ' | '; nextPutAll: (item at: 3); nl]]].
            (#('1' '2' '3') includes: menuChoice) ifFalse:
                [stdout nextPutAll: 'Choose 1, 2, 3, or 4.'; nl]].
        stdout nextPutAll: 'Goodbye.'; nl]]
