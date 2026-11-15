20 INPUT "Student name: ", STUDENT$
40 INPUT "Grade: ", GRADE
52 PRINT "Student: "; STUDENT$
54 PRINT "Grade: "; GRADE
60 IF GRADE >= 75 THEN GOTO 100
70 GOTO 120
100 PRINT "Status: Passed": END
120 PRINT "Status: Failed": END
