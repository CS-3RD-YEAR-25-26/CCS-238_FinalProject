Object subclass: RegularPassenger [
    fareFor: baseCentavos [
        ^(baseCentavos isInteger and: [baseCentavos >= 0]) ifTrue: [baseCentavos] ifFalse: [nil]
    ]
]
Object subclass: StudentPassenger [
    fareFor: baseCentavos [
        ^(baseCentavos isInteger and: [baseCentavos >= 0])
            ifTrue: [(baseCentavos * 4 + 2) // 5] ifFalse: [nil]
    ]
]
Eval [
    | passengers check input base valid |
    passengers := {RegularPassenger new. StudentPassenger new}.
    (Smalltalk arguments includes: '--test') ifTrue: [
        check := [:condition | condition ifFalse: [
            stderr nextPutAll: 'campus_fare_pass test failed'; nl.
            ObjectMemory quit: 1
        ]].
        check value: ((passengers first fareFor: 2000) = 2000).
        check value: ((passengers last fareFor: 2000) = 1600).
        check value: ((passengers last fareFor: 1) = 1).
        check value: ((passengers last fareFor: 2) = 2).
        check value: ((passengers last fareFor: 3) = 2).
        check value: ((passengers last fareFor: 4) = 3).
        check value: ((passengers last fareFor: 5) = 4).
        check value: ((passengers last fareFor: 6) = 5).
        check value: ((passengers last fareFor: 9223372036854775807) = 7378697629483820646).
        check value: (passengers first fareFor: -1) isNil.
        check value: (passengers last fareFor: 1.5) isNil.
        stdout nextPutAll: 'campus_fare_pass tests passed'; nl
    ] ifFalse: [
        stdout nextPutAll: 'Base fare in centavos (2000 = PHP 20):'; nl; flush.
        input := stdin nextLine.
        input isNil ifTrue: [stdout nextPutAll: 'Input ended.'; nl] ifFalse: [
        valid := input notEmpty and: [input allSatisfy: [:ch | ch between: $0 and: $9]].
        valid ifTrue: [base := input asInteger. valid := base <= 9223372036854775807].
        valid ifFalse: [stdout nextPutAll: 'Enter a whole number from 0 to 9223372036854775807.'; nl] ifTrue: [
        "The caller sends fareFor: without inspecting the passenger class."
        passengers with: #('Regular fare: ' 'Student fare: ') do: [:passenger :label |
            stdout nextPutAll: label;
                nextPutAll: (passenger fareFor: base) printString;
                nextPutAll: ' centavos'; nl
        ]
        ]]
    ]
]
