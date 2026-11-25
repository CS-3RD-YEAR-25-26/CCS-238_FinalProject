PROGRAM CSVParser
    IMPLICIT NONE

    ! Declare variables
    CHARACTER(LEN=256) :: filename = "dataset.csv"
    INTEGER :: ios, unit_num = 10
    INTEGER :: line_count, i
    REAL(8), ALLOCATABLE :: data(:)
    REAL(8) :: val
    CHARACTER(LEN=256) :: buffer

    ! Statistical variables
    REAL(8) :: total_sum, mean_val, median_val, mode_val, variance, std_dev ! MODIFICATION: Added mode_val
    REAL(8), ALLOCATABLE :: sorted_data(:)

    PRINT *, "Reading file from: ", TRIM(filename)

    ! =========================================================================
    ! PASS 1: Count how many valid numeric rows exist in the file
    ! (This tells FORTRAN exactly how big to make our array before storing data)
    ! =========================================================================

    OPEN(UNIT=unit_num, FILE=TRIM(filename), STATUS='OLD', ACTION='READ', IOSTAT=ios)
    IF (ios /= 0) THEN
        PRINT *, "Error: Could not open file. "
        STOP
    END IF 

    line_count = 0
    DO
        READ(unit_num, '(A)', IOSTAT=ios) buffer
        IF (ios < 0) EXIT ! End of file reached
        IF (ios > 0) CYCLE ! Read error, skip

        buffer = ADJUSTL(TRIM(buffer))
        IF (LEN_TRIM(buffer) == 0) CYCLE

        ! Try reading the buffer as a real number to check if it's numeric
        READ(buffer, *, IOSTAT=ios) val
        IF (ios == 0) THEN
            line_count = line_count + 1
        ELSE
            PRINT *, "Notice: Skipping non_numeric row -> ' ", TRIM(buffer), " ' "
        END IF
    END DO
    CLOSE(unit_num)

    IF (line_count == 0) THEN
        PRINT *, "Error: No valid numerical data found."
        STOP
    END IF   

    ! Allocate our dynamic array based on the exact count of valid numbers
    ALLOCATE(data(line_count))

    ! =========================================================================
    ! PASS 2: Read the valid numbers into our allocated `data` array
    ! =========================================================================
    OPEN(UNIT=unit_num, FILE=TRIM(filename), STATUS='OLD', ACTION='READ', IOSTAT=ios)

    i = 1
    DO
        READ(unit_num, '(A)', IOSTAT=ios) buffer
        IF (ios < 0) EXIT
        IF (ios > 0) CYCLE

        buffer = ADJUSTL(TRIM(buffer))
        IF (LEN_TRIM(buffer) == 0) CYCLE

        READ(buffer, *, IOSTAT=ios) val
        IF (ios == 0) THEN
            data(i) = val
            i = i + 1
        END IF
    END DO
    CLOSE(unit_num)

    ! =========================================================================
    ! STATISTICAL CALCULATIONS
    ! =========================================================================

    total_sum = SUM(data)
    mean_val = total_sum / REAL(line_count, 8)
    variance = SUM((data - mean_val)**2) / REAL(line_count - 1, 8)
    std_dev = SQRT(variance)

    ALLOCATE(sorted_data(line_count))
    sorted_data = data

    BLOCK
        INTEGER :: j, k
        REAL(8) :: temp
        DO j = 1, line_count - 1
            DO k = j + 1, line_count
                IF (sorted_data(k) < sorted_data(j)) THEN
                    temp = sorted_data(j)
                    sorted_data(j) = sorted_data(k)
                    sorted_data(k) = temp
                END IF
            END DO
        END DO
    END BLOCK

    IF (MOD(line_count, 2) == 1) THEN
        median_val = sorted_data((line_count / 2) + 1)
    ELSE
        median_val = (sorted_data(line_count / 2) + sorted_data((line_count / 2) + 1)) / 2.0_8
    END IF

    ! =========================================================================
    ! MODIFICATION: Mode calculation leveraging the already sorted array
    ! =========================================================================
    BLOCK
        INTEGER :: max_count, current_count, idx
        
        ! Track the highest frequency found so far (initialized to 1)
        max_count = 1
        
        ! Track the frequency of the current repeating value being scanned
        current_count = 1
        
        ! Assume the first element is the initial mode candidate
        mode_val = sorted_data(1)
        
        ! Sequential scan through the sorted array to count consecutive duplicates
        DO idx = 2, line_count
            IF (sorted_data(idx) == sorted_data(idx - 1)) THEN
                ! If the current value matches the previous one, increment its frequency count
                current_count = current_count + 1
            ELSE
                ! When the sequence changes, check if the previous sequence beat the record
                IF (current_count > max_count) THEN
                    max_count = current_count
                    mode_val = sorted_data(idx - 1)
                END IF
                ! Reset the counter for the new unique value
                current_count = 1
            END IF
        END DO
        
        ! Final check for the very last group of numbers in the array
        IF (current_count > max_count) THEN
            mode_val = sorted_data(line_count)
        END IF
    END BLOCK
    ! =========================================================================

    DEALLOCATE(sorted_data)

    ! =========================================================================
    ! OUTPUT RESULTS TO CONSOLE
    ! =========================================================================
    PRINT *, "========================================"
    PRINT *, "      DESCRIPTIVE STATISTICS SUMMARY     "
    PRINT *, "========================================"
    PRINT '(A, I14)', "Total Data Points Processed : ", line_count
    PRINT '(A, F14.2)', "Mean (Average)              : ", mean_val
    PRINT '(A, F14.2)', "Median                      : ", median_val
    PRINT '(A, F14.2)', "Mode                        : ", mode_val
    PRINT '(A, F14.2)', "Standard Deviation          : ", std_dev
    PRINT *, "========================================"

END PROGRAM CSVParser