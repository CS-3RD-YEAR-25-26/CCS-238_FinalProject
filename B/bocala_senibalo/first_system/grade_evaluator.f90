
module grade_evaluator_module
    use, intrinsic :: iso_fortran_env, only: real64
    implicit none

    ! ==========================================
    ! SYSTEM 1: STUDENT GRADE EVALUATOR
    ! Language: FORTRAN
    ! ==========================================

    integer, parameter :: NUM_SUBJECTS = 5

    character(len=20), parameter :: SUBJECTS(NUM_SUBJECTS) = &
        [character(len=20) :: &
        "Mathematics", "English", "Science", &
        "Filipino", "Araling Panlipunan"]

contains

    ! ==========================================
    ! FUNCTION 1: INPUT AND VALIDATION
    ! ==========================================

    integer function input_grade(subject) result(grade)
        character(len=*), intent(in) :: subject
        character(len=100) :: input_line
        integer :: value, ios

        do
            write(*, '(A)', advance='no') &
                "Enter grade for " // trim(subject) // ": "

            read(*, '(A)', iostat=ios) input_line

            if (ios /= 0) then
                print '(A)', "Input ended or could not be read."
                stop 1
            end if

            read(input_line, *, iostat=ios) value

            if (ios /= 0) then
                print '(A)', &
                    "Invalid input! Enter a whole number."

            else if (value < 60 .or. value > 100) then
                print '(A)', &
                    "Invalid grade! Enter a value from 60 to 100."

            else
                grade = value
                return
            end if
        end do
    end function input_grade


    ! ==========================================
    ! FUNCTION 2: DETERMINE GRADE REMARKS
    ! ==========================================

    function grade_remark(grade) result(remark)
        real(real64), intent(in) :: grade
        character(len=30) :: remark

        if (grade >= 95.0_real64) then
            remark = "Outstanding"

        else if (grade >= 90.0_real64) then
            remark = "Very Satisfactory"

        else if (grade >= 85.0_real64) then
            remark = "Satisfactory"

        else if (grade >= 75.0_real64) then
            remark = "Fairly Satisfactory"

        else
            remark = "Did Not Meet Expectations"
        end if
    end function grade_remark


    ! ==========================================
    ! SUBROUTINE 3: CALCULATE GRADE RESULTS
    ! ==========================================

    subroutine calculate_grades(grades, average, highest, &
                                lowest, status, remarks)

        integer, intent(in) :: grades(NUM_SUBJECTS)
        real(real64), intent(out) :: average
        integer, intent(out) :: highest, lowest
        character(len=*), intent(out) :: status, remarks

        average = real(sum(grades), kind=real64) / &
                  real(size(grades), kind=real64)

        highest = maxval(grades)
        lowest = minval(grades)

        if (average >= 75.0_real64) then
            status = "PASSED"
        else
            status = "FAILED"
        end if

        remarks = grade_remark(average)

    end subroutine calculate_grades


    ! ==========================================
    ! SUBROUTINE 4: BEST/WORST SUBJECTS
    ! ==========================================

    subroutine show_tied_subjects(label, grades, target)
        character(len=*), intent(in) :: label
        integer, intent(in) :: grades(NUM_SUBJECTS), target
        integer :: i
        logical :: first

        write(*, '(A)', advance='no') label

        first = .true.

        do i = 1, NUM_SUBJECTS

            if (grades(i) == target) then

                if (.not. first) then
                    write(*, '(A)', advance='no') ", "
                end if

                write(*, '(A)', advance='no') trim(SUBJECTS(i))

                first = .false.
            end if

        end do

        print '(A)', ""

    end subroutine show_tied_subjects


    ! ==========================================
    ! SUBROUTINE 5: DISPLAY GRADE RESULTS
    ! ==========================================

    subroutine display_results(student_name, grades, average, &
                               highest, lowest, status, remarks)

        character(len=*), intent(in) :: student_name
        integer, intent(in) :: grades(NUM_SUBJECTS)
        integer, intent(in) :: highest, lowest
        real(real64), intent(in) :: average
        character(len=*), intent(in) :: status, remarks
        integer :: i

        print *
        print '(A)', "================================================"
        print '(A)', "              STUDENT GRADE REPORT"
        print '(A)', "================================================"

        print '(A)', "SUBJECT GRADES:"
        print '(A)', "------------------------------------------------"

        do i = 1, NUM_SUBJECTS

            write(*, '(A20, " : ", I3, " | ", A)') &
                SUBJECTS(i), grades(i), &
                trim(grade_remark(real(grades(i), kind=real64)))

        end do

        print '(A)', "------------------------------------------------"
        print '(A)', "OVERALL PERFORMANCE:"
        print '(A)', "------------------------------------------------"

        print '(A)', "Student Name  : " // trim(student_name)

        write(*, '(A, F0.2)') "Average Grade : ", average
        write(*, '(A, I0)') "Highest Grade : ", highest
        write(*, '(A, I0)') "Lowest Grade  : ", lowest

        call show_tied_subjects("Best Subject  : ", &
                                grades, highest)

        call show_tied_subjects("Worst Subject : ", &
                                grades, lowest)

        print '(A)', "Remarks       : " // trim(remarks)
        print '(A)', "Final Status  : " // trim(status)

        print '(A)', "================================================"

    end subroutine display_results

end module grade_evaluator_module


! ==========================================
! MAIN PROGRAM
! ==========================================

program student_grade_evaluator
    use grade_evaluator_module
    implicit none

    integer :: grades(NUM_SUBJECTS)
    integer :: i, highest, lowest, ios

    real(real64) :: average

    character(len=30) :: remarks
    character(len=10) :: status
    character(len=100) :: choice
    character(len=60) :: student_name

    do

        print *
        print '(A)', "================================================"
        print '(A)', "           STUDENT GRADE EVALUATOR"
        print '(A)', "================================================"

        ! ======================================
        ! STUDENT NAME INPUT
        ! ======================================

        write(*, '(A)', advance='no') "Enter student name: "

        read(*, '(A)', iostat=ios) student_name

        if (ios /= 0) exit

        student_name = adjustl(student_name)

        if (len_trim(student_name) == 0) then
            student_name = "Student"
        end if

        ! ======================================
        ! COLLECT SUBJECT GRADES
        ! ======================================

        do i = 1, NUM_SUBJECTS
            grades(i) = input_grade(SUBJECTS(i))
        end do

        ! Calculate grade results
        call calculate_grades(grades, average, highest, &
                              lowest, status, remarks)

        ! Display results
        call display_results(student_name, grades, average, &
                             highest, lowest, status, remarks)

        ! ======================================
        ! EVALUATE ANOTHER STUDENT
        ! ======================================

        print *
        write(*, '(A)', advance='no') &
            "Evaluate another student? (Y/N): "

        read(*, '(A)', iostat=ios) choice

        if (ios /= 0) exit

        if (trim(adjustl(choice)) /= "y" .and. &
            trim(adjustl(choice)) /= "Y") then
            exit
        end if

    end do

    print *
    print '(A)', "Thank you for using Student Grade Evaluator!"

end program student_grade_evaluator
