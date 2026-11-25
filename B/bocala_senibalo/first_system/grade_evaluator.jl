
using Printf

# ==========================================
# SYSTEM 1: STUDENT GRADE EVALUATOR
# Language: Julia
# ==========================================

# SUBJECT LIST
const SUBJECTS = [
    "Mathematics",
    "English",
    "Science",
    "Filipino",
    "Araling Panlipunan"
]

# ==========================================
# FUNCTION 1: INPUT AND VALIDATION
# ==========================================

function input_grade(subject::String)

    while true
        print("Enter grade for ", subject, ": ")

        grade = tryparse(Int, strip(readline()))

        if grade === nothing
            println("Invalid input! Enter a whole number.")

        elseif grade < 60 || grade > 100
            println("Invalid grade! Enter a value from 60 to 100.")

        else
            return grade
        end
    end
end


# ==========================================
# FUNCTION 2: DETERMINE GRADE REMARKS
# ==========================================

function grade_remark(grade::Real)

    if grade >= 95
        return "Outstanding"

    elseif grade >= 90
        return "Very Satisfactory"

    elseif grade >= 85
        return "Satisfactory"

    elseif grade >= 75
        return "Fairly Satisfactory"

    else
        return "Did Not Meet Expectations"
    end
end


# ==========================================
# FUNCTION 3: CALCULATE GRADE RESULTS
# ==========================================

function calculate_grades(grades::Vector{Int})

    # Calculate average grade
    average = sum(grades) / length(grades)

    # Determine highest and lowest grades
    highest = maximum(grades)
    lowest = minimum(grades)

    # Identify best-performing subjects
    best_subjects = String[]

    # Identify worst-performing subjects
    worst_subjects = String[]

    for i in eachindex(grades)

        if grades[i] == highest
            push!(best_subjects, SUBJECTS[i])
        end

        if grades[i] == lowest
            push!(worst_subjects, SUBJECTS[i])
        end
    end

    # Determine final status
    if average >= 75
        status = "PASSED"
    else
        status = "FAILED"
    end

    # Determine overall remarks
    remarks = grade_remark(average)

    return average, highest, lowest, best_subjects, worst_subjects, status, remarks
end


# ==========================================
# FUNCTION 4: DISPLAY GRADE RESULTS
# ==========================================

function display_results(student_name::String, grades::Vector{Int}, results)

    average, highest, lowest, best_subjects, worst_subjects, status, remarks = results

    println()
    println("================================================")
    println("              STUDENT GRADE REPORT")
    println("================================================")

    println("SUBJECT GRADES:")
    println("------------------------------------------------")

    for i in eachindex(SUBJECTS)

        @printf("%-20s : %3d | %s\n",
            SUBJECTS[i],
            grades[i],
            grade_remark(grades[i]))
    end

    println("------------------------------------------------")
    println("OVERALL PERFORMANCE:")
    println("------------------------------------------------")

    println("Student Name  : ", student_name)

    @printf("Average Grade : %.2f\n", average)

    println("Highest Grade : ", highest)
    println("Lowest Grade  : ", lowest)

    println("Best Subject  : ", join(best_subjects, ", "))
    println("Worst Subject : ", join(worst_subjects, ", "))

    println("Remarks       : ", remarks)
    println("Final Status  : ", status)

    println("================================================")
end


# ==========================================
# MAIN PROGRAM
# ==========================================

function main()

    while true

        println()
        println("================================================")
        println("           STUDENT GRADE EVALUATOR")
        println("================================================")

        # ======================================
        # STUDENT NAME INPUT
        # ======================================

        print("Enter student name: ")

        student_name = String(strip(readline()))

        # Use default name if input is blank
        if isempty(student_name)
            student_name = "Student"
        end

        # ======================================
        # COLLECT SUBJECT GRADES
        # ======================================

        grades = Int[]

        for subject in SUBJECTS
            grade = input_grade(subject)
            push!(grades, grade)
        end

        # Calculate grade results
        results = calculate_grades(grades)

        # Display results with student name
        display_results(student_name, grades, results)

        # ======================================
        # EVALUATE ANOTHER STUDENT
        # ======================================

        println()
        print("Evaluate another student? (Y/N): ")

        choice = lowercase(strip(readline()))

        if choice != "y"

            println()
            println("Thank you for using Student Grade Evaluator!")

            break
        end

    end
end

# ==========================================
# START THE PROGRAM
# ==========================================

main()
