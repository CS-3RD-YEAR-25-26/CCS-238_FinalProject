
# StudentWise - Budget Logic

using Dates

const MAX_EXPENSES = 100
const MAX_SAVINGS_HISTORY = 100

# ==========================================
# DATA STRUCTURES
# ==========================================

# Stores information about an individual expense
struct Expense
    category::String
    amount::Int
end

# Stores a successful savings transaction
struct SavingsTransaction
    action::String
    amount::Int
    timestamp::DateTime
end

# Stores the student's budget and savings information
mutable struct BudgetState
    weekly_allowance::Int
    expenses::Vector{Expense}
    savings_goal::Int
    saved_amount::Int
    savings_history::Vector{SavingsTransaction}
end

# Creates an empty student budget
function create_budget()
    return BudgetState(0, Expense[], 0, 0, SavingsTransaction[])
end


# ==========================================
# OPTION 1: SET WEEKLY ALLOWANCE
# ==========================================

# Updates the allowance if the amount is valid
function set_allowance!(budget::BudgetState, amount::Int)
    if amount <= 0
        return false
    end

    if amount < total_expenses(budget) + budget.saved_amount
        return false
    end

    budget.weekly_allowance = amount
    return true
end


# ==========================================
# OPTION 2: RECORD EXPENSE
# ==========================================

# Default expense categories
const DEFAULT_EXPENSE_CATEGORIES = [
    "Food",
    "Transportation",
    "School",
    "Entertainment",
    "Personal & Health",
    "Housing",
    "Utilities"
]

# Returns default and custom expense categories
function get_expense_categories(budget::BudgetState)
    categories = copy(DEFAULT_EXPENSE_CATEGORIES)

    for expense in budget.expenses
        if all(c -> lowercase(c) != lowercase(strip(expense.category)), categories)
            push!(categories, expense.category)
        end
    end

    return categories
end

# Records a new expense
function record_expense!(budget::BudgetState, category::AbstractString, amount::Int)
    clean_category = String(strip(category))

    if amount <= 0 || isempty(clean_category) || length(clean_category) > 40
        return false
    end

    if length(budget.expenses) >= MAX_EXPENSES
        return false
    end

    if amount > remaining_balance(budget)
        return false
    end

    push!(budget.expenses, Expense(clean_category, amount))
    return true
end


# ==========================================
# OPTION 3: VIEW EXPENSE HISTORY
# ==========================================

# Returns a copy of the recorded expenses
function get_expenses(budget::BudgetState)
    return copy(budget.expenses)
end


# ==========================================
# OPTION 4: VIEW BUDGET SUMMARY
# ==========================================

# Calculates the total amount spent
function total_expenses(budget::BudgetState)
    return sum(expense.amount for expense in budget.expenses; init=0)
end

# Calculates money available after expenses and savings
function remaining_balance(budget::BudgetState)
    return budget.weekly_allowance -
           total_expenses(budget) -
           budget.saved_amount
end


# ==========================================
# OPTION 5: SET SAVINGS GOAL
# ==========================================

# Sets the student's savings target
function set_savings_goal!(budget::BudgetState, goal::Int)
    if goal <= 0 || goal < budget.saved_amount
        return false
    end

    budget.savings_goal = goal
    return true
end


# ==========================================
# OPTION 6: CHECK SAVINGS PROGRESS
# ==========================================

# Calculates the percentage of the savings goal completed
function savings_progress(budget::BudgetState)
    if budget.savings_goal == 0
        return 0.0
    end

    return (budget.saved_amount / budget.savings_goal) * 100
end

# Calculates how much more money is needed
function remaining_savings(budget::BudgetState)
    return max(0, budget.savings_goal - budget.saved_amount)
end

# ==========================================
# OPTION 7: MANAGE SAVINGS
# ==========================================

# Adds money toward the student's savings goal
function add_savings!(budget::BudgetState, amount::Int)
    if budget.savings_goal <= 0 || amount <= 0
        return false
    end

    if amount > remaining_balance(budget)
        return false
    end

    if amount > budget.savings_goal - budget.saved_amount
        return false
    end

    if length(budget.savings_history) >= MAX_SAVINGS_HISTORY
        return false
    end

    budget.saved_amount += amount
    push!(budget.savings_history, SavingsTransaction("Added", amount, now()))
    return true
end

# Removes money from savings
function remove_savings!(budget::BudgetState, amount::Int)
    if amount <= 0 || amount > budget.saved_amount
        return false
    end

    if length(budget.savings_history) >= MAX_SAVINGS_HISTORY
        return false
    end

    budget.saved_amount -= amount
    push!(budget.savings_history, SavingsTransaction("Removed", amount, now()))
    return true
end

# Returns a copy of successful savings transactions
function get_savings_history(budget::BudgetState)
    return copy(budget.savings_history)
end
