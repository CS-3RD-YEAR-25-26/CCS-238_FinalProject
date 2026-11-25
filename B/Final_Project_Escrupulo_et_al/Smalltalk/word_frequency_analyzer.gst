"Word Frequency Analyzer" 

Object subclass: WordAnalyzer [  "creates the analyzer"

    "declares four instance variables of the analyzer object"  
    | inputText output totalWordCount mostCommonWords |
    
    "defines a class-side creation method the inherits object creation, initialize the new analyzer, and return it"
    WordAnalyzer class >> new [
        ^super new initialize
    ]
    
    " setting initial values" 
    initialize [
        inputText := 'Hello, world! hello.'.
        output := Dictionary new.
        totalWordCount := 0.
        mostCommonWords := OrderedCollection new.
        ^self
    ]
    
    " where the analysis starts"
    analyzeText: text [
        | words lowerCase wordCounts alphabeticalCounts rankedWords | 
        
        " Convert to lowercase and extract words."
        lowerCase := text asLowercase.
        words := lowerCase allOccurrencesOfRegex: '[^\W_]+'. "Equivalent to Python:re.findall(r[^\W_]+, text.lower()) the caret is a regex string not Smalltalk's return symbol"

        "Count how many times each word appears"
        wordCounts := Dictionary new. 
        
        words do: [:word |
            | currentCount |
            
            currentCount := wordCounts at: word ifAbsent: [0]. "Counting loop"
            wordCounts at: word put: currentCount + 1. 
        ].
        
        "Sort words alphabetically"
        alphabeticalCounts := (wordCounts associations asSortedCollection: [
            :a :b | a key <= b key]) asArray.
        
        "Sort by descending count but alphabetical for ties"
        rankedWords := (wordCounts associations asSortedCollection: [
            :a :b | a value = b value
                ifTrue: [ a key <= b key]
                ifFalse: [a value > b value]
            ]) asArray.
        
        ^{alphabeticalCounts. words size. rankedWords}
    ]
]
    "Runs the analyzer"
    Eval [
        | analyzer inputText result output totalWordCount rankedWords mostCommonWords |
        
        inputText := 'Hello, world! hello.'.
        analyzer := WordAnalyzer new.
        Transcript show: 'Paragraph: ', inputText; cr. 
        result := analyzer analyzeText: inputText.
        
        output := result at: 1.
        totalWordCount := result at: 2. 
        rankedWords := result at: 3. 
        
        mostCommonWords := rankedWords
            copyFrom: 1
            to: (3 min: rankedWords size).
            
        Transcript show: 'Word Frequencies (alphabetical): '; cr. 
        
        output do: [ :entry | 
            Transcript
                show: entry key;
                show: ': ';
                show: entry value printString;
                cr.
        ].
        
        Transcript show: 'Text summary:'; cr.
        Transcript show: 'Total words: ', totalWordCount printString; cr. 
        Transcript show: 'Unique words: ', output size printString; cr.
        Transcript show: 'Most frequent words: '.
        
        mostCommonWords do: [:entry | 
            Transcript 
                show: entry key;
                show: ' (';
                show: entry value printString;
                show: ') '; cr 
        ]. 
    ]

