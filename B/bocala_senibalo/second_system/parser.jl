
using Printf

# ==========================================
# SYSTEM 2: DESCRIPTIVE STATISTICS CALCULATOR
# Language: Julia
# ==========================================

function main()

    # Declare filename
    filename = "dataset.csv"

    println("Reading file from: ", filename)

    # ==========================================
    # PASS 1: COUNT VALID NUMERIC ROWS
    # ==========================================

    if !isfile(filename)
        println("Error: Could not open file.")
        return
    end

    line_count = 0

    for line in eachline(filename)

        buffer = strip(line)

        if isempty(buffer)
            continue
        end

        val = tryparse(Float64, buffer)

        if val !== nothing
            line_count += 1
        else
            println(
                "Notice: Skipping non_numeric row -> ' ",
                buffer,
                " '"
            )
        end
    end

    if line_count == 0
        println("Error: No valid numerical data found.")
        return
    end

    # Allocate array based on valid data count
    data = Vector{Float64}(undef, line_count)

    # ==========================================
    # PASS 2: READ VALID NUMBERS
    # ==========================================

    i = 1

    for line in eachline(filename)

        buffer = strip(line)

        if isempty(buffer)
            continue
        end

        val = tryparse(Float64, buffer)

        if val !== nothing
            data[i] = val
            i += 1
        end
    end

    # ==========================================
    # STATISTICAL CALCULATIONS
    # ==========================================

    # Calculate mean
    total_sum = sum(data)
    mean_val = total_sum / line_count

    # Calculate sample standard deviation
    if line_count > 1
        variance = sum((data .- mean_val) .^ 2) /
                   (line_count - 1)
        std_dev = sqrt(variance)
    else
        std_dev = 0.0
    end

    # ==========================================
    # SORT NUMBERS
    # ==========================================

    sorted_data = copy(data)

    for j in 1:(line_count - 1)
        for k in (j + 1):line_count

            if sorted_data[k] < sorted_data[j]
                temp = sorted_data[j]
                sorted_data[j] = sorted_data[k]
                sorted_data[k] = temp
            end

        end
    end

    # ==========================================
    # CALCULATE MEDIAN
    # ==========================================

    if isodd(line_count)
        median_val = sorted_data[div(line_count, 2) + 1]
    else
        median_val = (
            sorted_data[div(line_count, 2)] +
            sorted_data[div(line_count, 2) + 1]
        ) / 2.0
    end

    # ==========================================
    # CALCULATE MODE
    # ==========================================

    max_count = 1
    current_count = 1
    mode_val = sorted_data[1]

    for idx in 2:line_count

        if sorted_data[idx] == sorted_data[idx - 1]
            current_count += 1
        else
            if current_count > max_count
                max_count = current_count
                mode_val = sorted_data[idx - 1]
            end

            current_count = 1
        end
    end

    if current_count > max_count
        mode_val = sorted_data[line_count]
    end

    # ==========================================
    # DISPLAY RESULTS IN TERMINAL
    # ==========================================

    println()
    println("==============================================")
    println("       DESCRIPTIVE STATISTICS SUMMARY")
    println("==============================================")

    # Display total number of valid data points
    @printf("Total Data Points Processed : %14d\n",
        line_count)

    # Display statistics with two decimal places
    @printf("Mean (Average)              : %14.2f\n",
        mean_val)

    @printf("Median                      : %14.2f\n",
        median_val)

    @printf("Mode                        : %14.2f\n",
        mode_val)

    @printf("Standard Deviation          : %14.2f\n",
        std_dev)

    println("==============================================")

end

# ==========================================
# START PROGRAM
# ==========================================

main()
