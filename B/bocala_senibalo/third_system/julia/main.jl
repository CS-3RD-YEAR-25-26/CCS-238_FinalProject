# ==========================================
# SYSTEM 3: STUDENTWISE BUDGET MANAGEMENT
# Language: Julia (Terminal Only)
# Matches the FORTRAN main program
# ==========================================

include(joinpath(@__DIR__, "budget.jl"))
using Printf

# Read an operation input. Entering 0 cancels it.
function prompt_or_cancel(message::String)
    print(message)
    input = String(strip(readline()))
    if input == "0"
        println("Operation canceled.")
        return nothing
    end
    return input
end

# Confirm changes to an existing allowance or goal.
function confirm_change(item::String, old_value::Int, new_value::Int)
    if old_value <= 0 || old_value == new_value
        return true
    end

    println("Are you sure you want to change your ", item, "?")
    println("Current amount: PHP ", old_value)
    println("New amount: PHP ", new_value)
    print("Confirm [Y] Yes / [N] No / [0] Cancel: ")
    answer = String(strip(readline()))

    return answer in ("Y", "y", "YES", "yes", "Yes")
end

# Display the same menu as the FORTRAN program.
function show_menu()
    println()
    println("==================================")
    println("        STUDENTWISE SYSTEM")
    println("==================================")
    println("[1] Set Weekly Allowance")
    println("[2] Record Expense")
    println("[3] View Expense History")
    println("[4] View Budget Summary")
    println("[5] Set Savings Goal")
    println("[6] View Savings Progress")
    println("[7] Manage Savings (Add/Remove)")
    println("[8] Exit")
    println("==================================")
end

function main()
    budget = create_budget()

    while true
        show_menu()
        print("Enter your choice: ")
        choice = tryparse(Int, strip(readline()))

        if choice === nothing
            println("Invalid choice. Please try again.")
            continue
        end

        # ======================================
        # OPTION 1: SET WEEKLY ALLOWANCE
        # ======================================
        if choice == 1
            println("Enter 0 at any prompt to cancel.")
            println()

            input = prompt_or_cancel("Enter weekly allowance: PHP ")
            input === nothing && continue
            amount = tryparse(Int, input)

            if amount === nothing
                println("Invalid input. Enter a whole number.")
            elseif amount <= 0 || amount < total_expenses(budget) + budget.saved_amount
                println("Invalid allowance. Check amount and existing balance.")
            elseif !confirm_change("weekly allowance", budget.weekly_allowance, amount)
                println("Allowance unchanged.")
            elseif set_allowance!(budget, amount)
                println("Allowance saved successfully!")
            end

        # ======================================
        # OPTION 2: RECORD EXPENSE
        # ======================================
        elseif choice == 2
            if budget.weekly_allowance == 0
                println("Please set your weekly allowance first.")
                continue
            end

            println()
            println("------ RECORD EXPENSE ------")
            println("Choose Expense Category:")
            println()

            categories = get_expense_categories(budget)
            for (i, category) in enumerate(categories)
                println("[", i, "] ", category)
            end

            custom_option = length(categories) + 1
            println("[", custom_option, "] Add Custom Category")
            println()
            println("Enter 0 at any prompt to cancel.")

            input = prompt_or_cancel("Enter your choice: ")
            input === nothing && continue
            category_choice = tryparse(Int, input)

            if category_choice === nothing || !(1 <= category_choice <= custom_option)
                println("Invalid category choice.")
                continue
            end

            if category_choice == custom_option
                input = prompt_or_cancel("Enter new category name: ")
                input === nothing && continue

                if isempty(input) || length(input) > 40
                    println("Category must contain 1-40 characters.")
                    continue
                end
                selected_category = input
            else
                selected_category = categories[category_choice]
            end

            input = prompt_or_cancel("Enter expense amount: PHP ")
            input === nothing && continue
            amount = tryparse(Int, input)

            if amount === nothing
                println("Invalid amount. Enter a whole number.")
            elseif record_expense!(budget, selected_category, amount)
                println("Expense recorded successfully!")
                println("Category: ", selected_category)
                println("Remaining Balance: PHP ", remaining_balance(budget))
            else
                println("Invalid expense or insufficient balance.")
            end

        # ======================================
        # OPTION 3: VIEW EXPENSE HISTORY
        # ======================================
        elseif choice == 3
            println()
            println("------ EXPENSE HISTORY ------")
            expenses = get_expenses(budget)

            if isempty(expenses)
                println("No expenses recorded yet.")
            else
                for (i, expense) in enumerate(expenses)
                    println(i, ". ", expense.category, " - PHP ", expense.amount)
                end
                println("-----------------------------")
                println("Total Expenses: PHP ", total_expenses(budget))
            end
            println("-----------------------------")

        # ======================================
        # OPTION 4: VIEW BUDGET SUMMARY
        # ======================================
        elseif choice == 4
            println("------ BUDGET SUMMARY ------")
            println("Weekly Allowance: PHP ", budget.weekly_allowance)
            println("Remaining Balance: PHP ", remaining_balance(budget))
            println("----------------------------")

        # ======================================
        # OPTION 5: SET SAVINGS GOAL
        # ======================================
        elseif choice == 5
            println()
            println("------ SET SAVINGS GOAL ------")
            println()
            println("Enter 0 at any prompt to cancel.")

            input = prompt_or_cancel("Enter savings goal: PHP ")
            input === nothing && continue
            amount = tryparse(Int, input)

            if amount === nothing
                println("Invalid input. Enter a whole number.")
            elseif amount <= 0 || amount < budget.saved_amount
                println("Invalid savings goal. Check the amount.")
            elseif !confirm_change("savings goal", budget.savings_goal, amount)
                println("Savings goal unchanged.")
            elseif set_savings_goal!(budget, amount)
                println("Savings goal set successfully!")
                println("Savings Goal: PHP ", budget.savings_goal)
            end

        # ======================================
        # OPTION 6: VIEW SAVINGS PROGRESS
        # ======================================
        elseif choice == 6
            println()
            println("------ SAVINGS PROGRESS ------")

            if budget.savings_goal == 0
                println("Please set your savings goal first.")
            else
                println("Savings Goal: PHP ", budget.savings_goal)
                println("Saved Amount: PHP ", budget.saved_amount)
                println("Remaining to Goal: PHP ", remaining_savings(budget))
                @printf("Progress: %6.2f%%\n", savings_progress(budget))
            end
            println("------------------------------")

        # ======================================
        # OPTION 7: MANAGE SAVINGS
        # ======================================
        elseif choice == 7
            println()
            println("------ MANAGE SAVINGS ------")
            println()
            println("Enter 0 at any prompt to cancel.")

            if budget.savings_goal == 0
                println("Please set your savings goal first.")
                continue
            end

            println("[1] Add Savings")
            println("[2] Remove Savings")
            println("[3] View Savings History")
            println("[0] Back to Main Menu")

            input = prompt_or_cancel("Enter your choice: ")
            input === nothing && continue
            savings_choice = tryparse(Int, input)

            if savings_choice === nothing || !(1 <= savings_choice <= 3)
                println("Invalid choice.")
                continue
            end

            if savings_choice == 3
                println()
                println("------ SAVINGS HISTORY ------")
                history = get_savings_history(budget)

                if isempty(history)
                    println("No savings transactions yet.")
                else
                    for (i, transaction) in enumerate(history)
                        timestamp = Dates.format(transaction.timestamp,
                            dateformat"yyyy-mm-dd HH:MM:SS")
                        println(i, ". ", timestamp, " | ", transaction.action,
                            " PHP ", transaction.amount)
                    end
                end

                println("-----------------------------")
                println("Current Savings: PHP ", budget.saved_amount)
                continue
            end

            input = prompt_or_cancel("Enter amount: PHP ")
            input === nothing && continue
            amount = tryparse(Int, input)

            if amount === nothing
                println("Invalid input. Enter a whole number.")
                continue
            end

            if savings_choice == 1
                if add_savings!(budget, amount)
                    println("Savings added successfully!")
                else
                    println("Invalid amount or insufficient balance.")
                    continue
                end
            else
                if remove_savings!(budget, amount)
                    println("Savings removed successfully!")
                else
                    println("Invalid amount or insufficient savings.")
                    continue
                end
            end

            println("Saved Amount: PHP ", budget.saved_amount)
            println("Remaining Balance: PHP ", remaining_balance(budget))

        # ======================================
        # OPTION 8: EXIT
        # ======================================
        elseif choice == 8
            println("Thank you for using StudentWise!")
            break
        else
            println("Invalid choice. Please try again.")
        end
    end
end

main()
