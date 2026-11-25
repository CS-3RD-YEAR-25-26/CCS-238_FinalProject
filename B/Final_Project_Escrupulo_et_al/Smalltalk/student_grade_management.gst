Object subclass: Student [     "creates the Student Class"
    "declaring important student fields"
    | studentID name grades |
    
    passingGrade := 60.
    minGrade := 0.
    maxGrade := 100.
    
    "getter methods that provide a way to read the student information"
    studentID [^studentID]
    name [^name]
    grades [^grades]
    
    "method (id:name:) with two arguments. Used to create a new student object.
    anID and aName are inputs." 
    Student class >> id: anID name: aName [
        | newStudent |
        
        newStudent := self new.
        newStudent initializeId: anID name: aName.
        ^newStudent
    ]
    
    "Sets up newly created student object.
    Saves the received values from the arguments to the student fields"
    initializeId: anID name: aName [
        studentID := anID. 
        name := aName.
        grades := OrderedCollection new. "similar to self.grades = [] and can grow when new grades are added while keeping their order"
        ^self
    ]
    
    "Method for checking if grade is valid and adding it to the student object" 
    addGrade: grade [
        | isFloat | "variable for checking if the grade is a float or not"
        
        "asks whether the grade is an instance of Float or one of its subclasses."
        isFloat := grade isKindOf: Float. 
        ((grade isKindOf: Integer) or: [isFloat]) 
            ifFalse: [
                self error: 'A grade must be a number.']. 
        
        "condition that checks whether the grade is a float that is not finite or is outside 0-100 range"
       ((isFloat and: [grade isFinite not]) or: [(grade between: minGrade and: maxGrade) not])
            ifTrue: [
                self error: 'A grade must be from ', minGrade printString, 'to ', maxGrade printString, '.'].
        
        grades add: grade.
        ^nil   "returns nil and closes the method"
    ]
    
    "Calculate and return student's average, or nil if there are no grades"
    calcAverage [ 
        | sum |
        grades isEmpty 
            ifTrue: [ ^nil ].
            
        sum := 0.
        grades do: [ :grade | sum := sum + grade].
        
        ^(sum / grades size) asFloat
    ]
    
    "Return pass/fail status based on the fixed passing grade"
    getStatus [
        | average | 
        
        average := self calcAverage.
        
        average isNil 
            ifTrue: [^'No grades'].
        
        average >= passingGrade 
            ifTrue: [^'Pass']
            ifFalse:[^'Fail']
    ]
]

"Class for the management system"
Object subclass: StudentGradeManagementSystem [ 
    | students | 
    
    StudentGradeManagementSystem class >> new [
        ^super new initialize "changes where the method lookup begins"
    ]
    
    "defines the setup method and creates an empty dictionary. Returns the management system"
    initialize [
        students := Dictionary new.
        ^self
    ]
    
    "Adds a student and rejects blank names/IDs and duplicate IDs"
    addStudent: anID name: aName [
        (anID trimSeparators isEmpty or: [aName trimSeparators isEmpty]) 
            ifTrue: [
                self error: 'Student ID and name cannot be blank.'].
        
        (students includesKey: anID)
            ifTrue: [
                self error: 'StudentID', anID printString, 'already exists.']. 
        
        students at: anID put: (Student id: anID name: aName).
        
        ^nil
    ]
    
    "Find a student and record a grade"
    recordGrade: anID grade: aGrade [
        (students includesKey: anID) not
            ifTrue: [
                self error: 'Student ID', anID printString, 'was not found.']. 
        
        (students at: anID) addGrade: aGrade.
        ^nil
    ]
    
    "Create a readable summary for one student"
    displayStudent: anID [
        | student average averageText gradesText |
        
        (students includesKey: anID) not
            ifTrue: [
                self error: 'Student ID', anID printString, 'was not found.'].
        
        student := students at: anID.
        average := student calcAverage.
        
        averageText := average isNil
            ifTrue: ['N/A']
            ifFalse: [
                average printString].
        
        gradesText := ''.
        student grades do: [
            :grade | gradesText isEmpty ifFalse: [
                gradesText := gradesText, ', '
            ]. 
            gradesText := gradesText, grade printString. 
        ].
        
        gradesText isEmpty ifTrue: [
            gradesText := 'None' 
        ].
        
        ^student studentID, ' | ', student name, 
            ' | Grades: ', gradesText,
            ' | Average: ', averageText, 
            ' | Status: ', student getStatus
    ]
        
    " Return and displays summarries in Student ID order" 
    displayAllStudents [
        
        ^students keys asSortedCollection asArray collect: [
            :anID | self displayStudent: anID
        ]
    ]
]

"Preparing the sample record"
Eval [ 
    | studentRecords output system| 
    
    studentRecords := OrderedCollection new.
    studentRecords add: #('S1' 'Ari' (80 90)).
    studentRecords add: #('S2' 'Bea' (55 65)).
    studentRecords add: #('S3' 'Cal' (45 50)).
    studentRecords add: #('S4' 'Dee' ()).
    
    system := StudentGradeManagementSystem new. 
    
    "Add students, then record each student's grades"
    studentRecords do: [:record | 
        | studentID name grades |
        
        studentID := record at: 1.
        name := record at: 2.
        grades := record at: 3. 
        
        system addStudent: studentID name: name.
        
        grades do: [:grade |
            system recordGrade: studentID grade: grade.
        ].
    ].
    
    Transcript show: 'Student grade report: '; cr.
    output := system displayAllStudents.
    
    output do: [ :studentSummary | 
        Transcript show: studentSummary; cr]. 
]

