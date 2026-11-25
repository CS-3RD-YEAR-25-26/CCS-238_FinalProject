
module budget_module
    implicit none

    ! Maximum number of expense records
    integer, parameter :: MAX_EXPENSES = 100
    integer, parameter :: DEFAULT_CATEGORY_COUNT = 7
    integer, parameter :: MAX_SAVINGS_HISTORY = 100

    ! Stores an individual expense
    type :: Expense
        character(len=40) :: category = ""
        integer :: amount = 0
    end type Expense

    ! Stores a savings transaction
    type :: SavingsTransaction
        character(len=7) :: action = ''
        integer :: amount = 0
        character(len=19) :: timestamp = ''
    end type SavingsTransaction

    ! Stores the student's budget information
    type :: BudgetState
        integer :: weekly_allowance = 0
        type(Expense) :: expenses(MAX_EXPENSES)
        integer :: expense_count = 0
        integer :: savings_goal = 0
        integer :: saved_amount = 0
        type(SavingsTransaction) :: savings_history(MAX_SAVINGS_HISTORY)
        integer :: savings_count = 0
    end type BudgetState

contains
    ! ==========================================
    ! OPTION 1: Sets the weekly allowance
    ! ==========================================
    logical function set_allowance(budget, amount) result(valid)
        type(BudgetState), intent(inout) :: budget
        integer, intent(in) :: amount

        valid = .false.

        if (amount <= 0) return

        if (amount < total_expenses(budget) + budget%saved_amount) return

        budget%weekly_allowance = amount
        valid = .true.
    end function set_allowance


    ! ==========================================
    ! OPTION 2: RECORD EXPENSE
    ! ==========================================

    ! Returns default and previously used categories
    subroutine get_expense_categories(budget, categories, count)
        type(BudgetState), intent(in) :: budget
        character(len=40), intent(out) :: &
            categories(MAX_EXPENSES + DEFAULT_CATEGORY_COUNT)
        integer, intent(out) :: count

        integer :: i, j
        logical :: exists

        categories = ''

        categories(1) = 'Food'
        categories(2) = 'Transportation'
        categories(3) = 'School'
        categories(4) = 'Entertainment'
        categories(5) = 'Personal & Health'
        categories(6) = 'Housing'
        categories(7) = 'Utilities'

        count = DEFAULT_CATEGORY_COUNT

        do i = 1, budget%expense_count
            exists = .false.

            do j = 1, count
                if (lowercase(trim(categories(j))) == &
                    lowercase(trim(budget%expenses(i)%category))) then
                    exists = .true.
                    exit
                end if
            end do

            if (.not. exists) then
                count = count + 1
                categories(count) = budget%expenses(i)%category
            end if
        end do
    end subroutine get_expense_categories


    ! Records an expense if the amount is valid
    logical function record_expense(budget, category, amount) result(valid)
        type(BudgetState), intent(inout) :: budget
        character(len=*), intent(in) :: category
        integer, intent(in) :: amount

        valid = .false.

        if (amount <= 0 .or. len_trim(category) == 0) return
        if (len_trim(adjustl(category)) > 40) return
        if (budget%expense_count >= MAX_EXPENSES) return
        if (amount > remaining_balance(budget)) return

        budget%expense_count = budget%expense_count + 1

        budget%expenses(budget%expense_count)%category = &
            trim(adjustl(category))

        budget%expenses(budget%expense_count)%amount = amount

        valid = .true.
    end function record_expense


    ! Converts uppercase letters to lowercase
    pure function lowercase(text) result(lower)
        character(len=*), intent(in) :: text
        character(len=len(text)) :: lower
        integer :: i, code

        lower = text

        do i = 1, len(text)
            code = iachar(text(i:i))

            if (code >= 65 .and. code <= 90) then
                lower(i:i) = achar(code + 32)
            end if
        end do
    end function lowercase


    ! ==========================================
    ! OPTION 3: VIEW EXPENSE HISTORY
    ! ==========================================

    ! Returns a copy of recorded expenses
    subroutine get_expenses(budget, history, count)
        type(BudgetState), intent(in) :: budget
        type(Expense), intent(out) :: history(MAX_EXPENSES)
        integer, intent(out) :: count

        history = budget%expenses
        count = budget%expense_count
    end subroutine get_expenses

    
    ! ==========================================
    ! OPTION 4: VIEW BUDGET SUMMARY
    ! ==========================================

    ! Calculates total expenses
    integer function total_expenses(budget) result(total)
        type(BudgetState), intent(in) :: budget
        integer :: i

        total = 0

        do i = 1, budget%expense_count
            total = total + budget%expenses(i)%amount
        end do
    end function total_expenses


    ! Calculates the remaining balance
    integer function remaining_balance(budget) result(balance)
        type(BudgetState), intent(in) :: budget

        balance = budget%weekly_allowance - &
                  total_expenses(budget) - budget%saved_amount
    end function remaining_balance

    ! ==========================================
    ! OPTION 5: SET SAVINGS GOAL
    ! ==========================================

    ! Sets a valid savings goal
    logical function set_savings_goal(budget, amount) result(valid)
        type(BudgetState), intent(inout) :: budget
        integer, intent(in) :: amount

        valid = .false.

        if (amount <= 0) return
        if (amount < budget%saved_amount) return

        budget%savings_goal = amount
        valid = .true.
    end function set_savings_goal


    ! ==========================================
    ! OPTION 6: VIEW SAVINGS PROGRESS
    ! ==========================================

    ! Calculates savings progress percentage
    real function savings_progress(budget) result(progress)
        type(BudgetState), intent(in) :: budget

        progress = 0.0

        if (budget%savings_goal <= 0) return

        progress = real(budget%saved_amount) / &
                   real(budget%savings_goal) * 100.0
    end function savings_progress


    ! Calculates the amount needed to reach the goal
    integer function remaining_savings(budget) result(remaining)
        type(BudgetState), intent(in) :: budget

        remaining = max(0, budget%savings_goal - budget%saved_amount)
    end function remaining_savings


    ! ==========================================
    ! OPTION 7: MANAGE SAVINGS
    ! ==========================================

    ! Adds money to savings
    logical function add_savings(budget, amount) result(valid)
        type(BudgetState), intent(inout) :: budget
        integer, intent(in) :: amount

        valid = .false.

        if (budget%savings_goal <= 0) return
        if (amount <= 0) return
        if (amount > remaining_balance(budget)) return
        if (amount > remaining_savings(budget)) return
        if (budget%savings_count >= MAX_SAVINGS_HISTORY) return

        budget%saved_amount = budget%saved_amount + amount
        call record_savings_action(budget, 'Added', amount)
        valid = .true.
    end function add_savings


    ! Removes money from savings
    logical function remove_savings(budget, amount) result(valid)
        type(BudgetState), intent(inout) :: budget
        integer, intent(in) :: amount

        valid = .false.

        if (amount <= 0) return
        if (amount > budget%saved_amount) return
        if (budget%savings_count >= MAX_SAVINGS_HISTORY) return

        budget%saved_amount = budget%saved_amount - amount
        call record_savings_action(budget, 'Removed', amount)
        valid = .true.
    end function remove_savings

    ! Records a savings transaction
    subroutine record_savings_action(budget, action, amount)
        type(BudgetState), intent(inout) :: budget
        character(len=*), intent(in) :: action
        integer, intent(in) :: amount
        integer :: n, dt(8)

        budget%savings_count = budget%savings_count + 1
        n = budget%savings_count

        budget%savings_history(n)%action = action
        budget%savings_history(n)%amount = amount

        call date_and_time(values=dt)

        write(budget%savings_history(n)%timestamp, &
            '(I4.4,"-",I2.2,"-",I2.2,1X,I2.2,":",I2.2,":",I2.2)') &
            dt(1), dt(2), dt(3), dt(5), dt(6), dt(7)
    end subroutine record_savings_action


end module budget_module
