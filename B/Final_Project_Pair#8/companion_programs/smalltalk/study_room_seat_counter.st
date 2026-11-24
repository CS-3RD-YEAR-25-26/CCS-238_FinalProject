Object subclass: StudyRoom [
    | capacity occupied |
    StudyRoom class >> new [^self capacity: 0]
    StudyRoom class >> capacity: value [
        ^(value isInteger and: [value >= 0])
            ifTrue: [self basicNew capacity: value] ifFalse: [nil]
    ]
    capacity: value [(value isInteger and: [value >= 0]) ifFalse: [^nil]. capacity := value. occupied := 0. ^self]
    occupied [^occupied]
    available [^capacity - occupied]
    "ifTrue: evaluates its block only when the receiver is true."
    reserve [occupied = capacity ifTrue: [^false]. occupied := occupied + 1. ^true]
    cancel [occupied = 0 ifTrue: [^false]. occupied := occupied - 1. ^true]
]
Eval [
    | room check choice accepted |
    room := StudyRoom capacity: 2.
    (Smalltalk arguments includes: '--test') ifTrue: [
        check := [:condition | condition ifFalse: [
            stderr nextPutAll: 'study_room_seat_counter test failed'; nl. ObjectMemory quit: 1]].
        check value: room cancel not.
        check value: (room reserve and: [room reserve and: [room reserve not]]).
        check value: ((room occupied = 2) and: [room available = 0]).
        check value: (room cancel and: [room cancel and: [room cancel not]]).
        check value: ((room occupied = 0) and: [room available = 2]).
        check value: (StudyRoom capacity: -1) isNil.
        check value: (StudyRoom capacity: 0) reserve not.
        check value: (StudyRoom new available = 0).
        stdout nextPutAll: 'study_room_seat_counter tests passed'; nl
    ] ifFalse: [
        [stdout nextPutAll: '1 Reserve | 2 Cancel | 3 Status | 4 Exit'; nl; flush.
            choice := stdin nextLine.
            choice notNil and: [choice ~= '4']] whileTrue: [
            choice = '3' ifTrue: [
                stdout nextPutAll: 'Status: occupied='; nextPutAll: room occupied printString;
                    nextPutAll: '; available='; nextPutAll: room available printString; nl].
            (#('1' '2') includes: choice) ifTrue: [
                accepted := choice = '1' ifTrue: [room reserve] ifFalse: [room cancel].
                stdout nextPutAll: (choice = '1' ifTrue: ['Reserve'] ifFalse: ['Cancel']);
                    nextPutAll: ': '; nextPutAll: (accepted ifTrue: ['accepted'] ifFalse: ['rejected']);
                    nextPutAll: '; occupied='; nextPutAll: room occupied printString;
                    nextPutAll: '; available='; nextPutAll: room available printString; nl].
            (#('1' '2' '3') includes: choice) ifFalse:
                [stdout nextPutAll: 'Choose 1, 2, 3, or 4.'; nl]].
        stdout nextPutAll: 'Goodbye.'; nl
    ]
]
