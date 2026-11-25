"Recursive Merge Sort"
Object subclass: MergeSort [  "defines a class named MergeSort that inherits the the behavior of Object (parent class)"
    sort: arr [   "defines the method named sort with arr as the argument inside it"
        "declaring array variables (temporary helpers for the method)"
        | midIndex leftHalf rightHalf result i j k leftValue rightValue | 

        "the base case for stopping the recursion"
        (arr size <= 1) ifTrue: [ ^ arr].
            midIndex := arr size // 2.0.   "divides the array into two"
            "splits and sorts the halves"
            leftHalf := self sort: (arr copyFrom: 1 to: midIndex).                 
            rightHalf := self sort: (arr copyFrom: (midIndex + 1) to: arr size).
            
            "creates and prepares a new array for the answer"
            result := Array new: arr size.
            i := 1.
            j := 1.
            k := 1.
            
            "compares two halves before merging"
            [ (i <= leftHalf size) and:  [j <= rightHalf size]] whileTrue: [
            
                leftValue := leftHalf at: i.
                rightValue := rightHalf at: j.
            
                Transcript show: ('Comparing ', leftValue printString, ' and ', rightValue printString); cr.
                "chooses the smaller number" 
                (leftValue <= rightValue)
                    ifTrue: [
                        result at: k put: leftValue.
                        i := i + 1
                    ]
                    ifFalse: [
                        result at: k put: rightValue.
                        j := j + 1
                    ].
                k := k + 1
            ].
            
            "Checking if any element was left." 
            [ i <= leftHalf size] whileTrue: [
                leftValue := leftHalf at: i.
                Transcript show: ('Adding remaining element from left half: ', leftValue printString); cr.
                result at: k put: leftValue.
                i := i + 1.
                k := k + 1.
            ].
            
            [ j <= rightHalf size] whileTrue: [
                rightValue := rightHalf at: j.
                Transcript show: ('Adding remaining element from right half: ', rightValue printString); cr.
                result at: k put: rightValue.
                j := j + 1.
                k := k + 1.
            ].
            
            ^result  "returns the sorted answer"
    ]
]

"runs the sorting program"
Eval [
    
    | inputArr outputArr |
    
    inputArr := #( 12 31 4 3 9 5 8 24).
    Transcript show: ('Array before sorting: ', inputArr printString); cr.
    outputArr := MergeSort new sort: inputArr.
    Transcript show: ('Sorted array is: ', outputArr printString); cr.
]
         