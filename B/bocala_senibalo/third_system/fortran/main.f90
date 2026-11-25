
program StudentWise
    use budget_module
    implicit none

    type(BudgetState) :: budget
    integer :: choice, amount, ios
    integer :: category_choice, category_count, i
    character(len=100) :: input_line
    character(len=40) :: categories(MAX_EXPENSES + DEFAULT_CATEGORY_COUNT)
    character(len=40) :: selected_category
    type(Expense) :: expense_history(MAX_EXPENSES)
    integer :: history_count, j
    integer :: savings_choice


    ! Keeps the main menu running
    do
        call show_menu()

        write(*, '(A)', advance='no') 'Enter your choice: '
        read(*, '(A)', iostat=ios) input_line
        if (ios /= 0) exit

        read(input_line, *, iostat=ios) choice

        if (ios /= 0) then
            print '(A)', 'Invalid choice. Please try again.'
            cycle
        end if

        select case (choice)

        case (1)
            ! Sets the weekly allowance
            print '(A)', 'Enter 0 at any prompt to cancel.'
            print *
            write(*, '(A)', advance='no') 'Enter weekly allowance: PHP '
            read(*, '(A)', iostat=ios) input_line
            if (ios /= 0) exit

            if (trim(adjustl(input_line)) == '0') then
                print '(A)', 'Operation canceled.'
                cycle
            end if

            read(input_line, *, iostat=ios) amount

            
            if (ios /= 0) then
                print '(A)', 'Invalid input. Enter a whole number.'

            else if (amount <= 0 .or. &
                     amount < total_expenses(budget) + budget%saved_amount) then
                print '(A)', 'Invalid allowance. Check amount and existing balance.'

            else if (.not. confirm_change('weekly allowance', &
                         budget%weekly_allowance, amount)) then
                print '(A)', 'Allowance unchanged.'

            else if (set_allowance(budget, amount)) then
                print '(A)', 'Allowance saved successfully!'
            end if


            

        
        case (2)
            ! Records expenses using default or custom categories
            
            if (budget%weekly_allowance == 0) then
                print '(A)', 'Please set your weekly allowance first.'
                cycle
            end if

            print '(A)', ''
            print '(A)', '------ RECORD EXPENSE ------'
            print '(A)', 'Choose Expense Category:'
            print '(A)', ''

            call get_expense_categories(budget, categories, category_count)

            ! Displays available categories
            do i = 1, category_count
                print '(A,I0,A,A)', '[', i, '] ', trim(categories(i))
            end do

            print '(A,I0,A)', '[', category_count + 1, &
                '] Add Custom Category'
            print *
            print '(A)', 'Enter 0 at any prompt to cancel.'

            write(*, '(A)', advance='no') 'Enter your choice: '
            read(*, '(A)', iostat=ios) input_line
            if (ios /= 0) exit

            if (trim(adjustl(input_line)) == '0') then
                print '(A)', 'Operation canceled.'
                cycle
            end if

            read(input_line, *, iostat=ios) category_choice

            if (ios /= 0) then
                print '(A)', 'Invalid category choice.'
                cycle
            end if

            if (category_choice < 1 .or. &
                category_choice > category_count + 1) then
                print '(A)', 'Invalid category choice.'
                cycle
            end if

            if (category_choice == category_count + 1) then
                write(*, '(A)', advance='no') 'Enter new category name: '
                read(*, '(A)', iostat=ios) input_line
                if (ios /= 0) exit
                
                if (trim(adjustl(input_line)) == '0') then
                    print '(A)', 'Operation canceled.'
                        cycle
                    end if

                if (len_trim(input_line) == 0 .or. &
                    len_trim(adjustl(input_line)) > 40) then
                    print '(A)', 'Category must contain 1-40 characters.'
                    cycle
                end if

                selected_category = trim(adjustl(input_line))
            else
                selected_category = categories(category_choice)
            end if

            write(*, '(A)', advance='no') 'Enter expense amount: PHP '
            read(*, '(A)', iostat=ios) input_line
            if (ios /= 0) exit

            if (trim(adjustl(input_line)) == '0') then
                print '(A)', 'Operation canceled.'
                cycle
            end if

            read(input_line, *, iostat=ios) amount

            if (ios /= 0) then
                print '(A)', 'Invalid amount. Enter a whole number.'

            else if (record_expense(budget, selected_category, amount)) then
                print '(A)', 'Expense recorded successfully!'
                print '(A,A)', 'Category: ', trim(selected_category)
                print '(A,I0)', 'Remaining Balance: PHP ', &
                    remaining_balance(budget)

            else
                print '(A)', 'Invalid expense or insufficient balance.'
            end if
        
        case (3)
            ! Displays all recorded expenses
            print '(A)', ''
            print '(A)', '------ EXPENSE HISTORY ------'

            call get_expenses(budget, expense_history, history_count)

            if (history_count == 0) then
                print '(A)', 'No expenses recorded yet.'
            else
                do j = 1, history_count
                    print '(I0,A,A,A,I0)', j, '. ', &
                        trim(expense_history(j)%category), &
                        ' - PHP ', expense_history(j)%amount
                end do

                print '(A)', '-----------------------------'
                print '(A,I0)', 'Total Expenses: PHP ', &
                    total_expenses(budget)
            end if

            print '(A)', '-----------------------------'

        case (4)
            ! Displays the budget summary
            print '(A)', '------ BUDGET SUMMARY ------'
            print '(A,I0)', 'Weekly Allowance: PHP ', budget%weekly_allowance
            print '(A,I0)', 'Remaining Balance: PHP ', remaining_balance(budget)
            print '(A)', '----------------------------'

        
        case (5)
            ! Sets the student's savings goal
            print '(A)', ''
            print '(A)', '------ SET SAVINGS GOAL ------'
            print *
            print '(A)', 'Enter 0 at any prompt to cancel.'

            write(*, '(A)', advance='no') 'Enter savings goal: PHP '
            read(*, '(A)', iostat=ios) input_line
            if (ios /= 0) exit

            if (trim(adjustl(input_line)) == '0') then
                print '(A)', 'Operation canceled.'
                cycle
            end if

            read(input_line, *, iostat=ios) amount

            if (ios /= 0) then
                print '(A)', 'Invalid input. Enter a whole number.'

            else if (amount <= 0 .or. amount < budget%saved_amount) then
                print '(A)', 'Invalid savings goal. Check the amount.'

            else if (.not. confirm_change('savings goal', &
                         budget%savings_goal, amount)) then
                print '(A)', 'Savings goal unchanged.'

            else if (set_savings_goal(budget, amount)) then
                print '(A)', 'Savings goal set successfully!'
                print '(A,I0)', 'Savings Goal: PHP ', budget%savings_goal
            end if

        case (6)
            ! Displays the student's savings progress
            print '(A)', ''
            print '(A)', '------ SAVINGS PROGRESS ------'

            if (budget%savings_goal == 0) then
                print '(A)', 'Please set your savings goal first.'
            else
                print '(A,I0)', 'Savings Goal: PHP ', budget%savings_goal
                print '(A,I0)', 'Saved Amount: PHP ', budget%saved_amount
                print '(A,I0)', 'Remaining to Goal: PHP ', &
                    remaining_savings(budget)
                print '(A,F6.2,A)', 'Progress: ', &
                    savings_progress(budget), '%'
            end if

            print '(A)', '------------------------------'
        

        case (7)
            ! Adds or removes money from savings
            print '(A)', ''
            print '(A)', '------ MANAGE SAVINGS ------'
            print *
            print '(A)', 'Enter 0 at any prompt to cancel.'

            if (budget%savings_goal == 0) then
                print '(A)', 'Please set your savings goal first.'
                cycle
            end if

            print '(A)', '[1] Add Savings'
            print '(A)', '[2] Remove Savings'
            print '(A)', '[3] View Savings History'
            print '(A)', '[0] Back to Main Menu'

            write(*, '(A)', advance='no') 'Enter your choice: '
            read(*, '(A)', iostat=ios) input_line
            if (ios /= 0) exit

            if (trim(adjustl(input_line)) == '0') then
                print '(A)', 'Operation canceled.'
                cycle
            end if

            read(input_line, *, iostat=ios) savings_choice

            if (ios /= 0) then
                print '(A)', 'Invalid choice.'
                cycle
            end if

            if (savings_choice < 1 .or. savings_choice > 3) then
                print '(A)', 'Invalid choice.'
                cycle
            end if

            if (savings_choice == 3) then
                print '(A)', ''
                print '(A)', '------ SAVINGS HISTORY ------'

                if (budget%savings_count == 0) then
                    print '(A)', 'No savings transactions yet.'
                else
                    do j = 1, budget%savings_count
                        print '(I0,A,A,A,A,A,I0)', j, '. ', &
                            budget%savings_history(j)%timestamp, ' | ', &
                            trim(budget%savings_history(j)%action), &
                            ' PHP ', budget%savings_history(j)%amount
                    end do
                end if

                print '(A)', '-----------------------------'
                print '(A,I0)', 'Current Savings: PHP ', &
                    budget%saved_amount
                cycle
            end if

            write(*, '(A)', advance='no') 'Enter amount: PHP '
            read(*, '(A)', iostat=ios) input_line
            if (ios /= 0) exit

            if (trim(adjustl(input_line)) == '0') then
                print '(A)', 'Operation canceled.'
                cycle
            end if

            read(input_line, *, iostat=ios) amount

            if (ios /= 0) then
                print '(A)', 'Invalid input. Enter a whole number.'
                cycle
            end if

            if (savings_choice == 1) then
                if (add_savings(budget, amount)) then
                    print '(A)', 'Savings added successfully!'
                else
                    print '(A)', 'Invalid amount or insufficient balance.'
                    cycle
                end if
            else
                if (remove_savings(budget, amount)) then
                    print '(A)', 'Savings removed successfully!'
                else
                    print '(A)', 'Invalid amount or insufficient savings.'
                    cycle
                end if
            end if

            print '(A,I0)', 'Saved Amount: PHP ', budget%saved_amount
            print '(A,I0)', 'Remaining Balance: PHP ', &
                remaining_balance(budget)

        case (8)
            print '(A)', 'Thank you for using StudentWise!'
            exit


        case default
            print '(A)', 'Invalid choice. Please try again.'

        end select
    end do

contains

    ! Ask before replacing an existing amount
    logical function confirm_change(item, old_value, new_value) result(approved)
        character(len=*), intent(in) :: item
        integer, intent(in) :: old_value, new_value
        character(len=100) :: answer
        integer :: answer_ios

        approved = .true.

        ! No confirmation needed for the first value
        ! or when the amount stays the same
        if (old_value <= 0 .or. old_value == new_value) return

        print '(A,A,A)', 'Are you sure you want to change your ', &
            trim(item), '?'
        print '(A,I0)', 'Current amount: PHP ', old_value
        print '(A,I0)', 'New amount: PHP ', new_value

        write(*, '(A)', advance='no') &
            'Confirm [Y] Yes / [N] No / [0] Cancel: '

        read(*, '(A)', iostat=answer_ios) answer

        if (answer_ios /= 0) then
            approved = .false.
            return
        end if

        select case (trim(adjustl(answer)))
        case ('Y', 'y', 'YES', 'yes', 'Yes')
            approved = .true.
        case default
            approved = .false.
        end select
    end function confirm_change

    
! Displays the main menu
    subroutine show_menu()
        print '(A)', ''
        print '(A)', '=================================='
        print '(A)', '        STUDENTWISE SYSTEM'
        print '(A)', '=================================='
        print '(A)', '[1] Set Weekly Allowance'
        print '(A)', '[2] Record Expense'
        print '(A)', '[3] View Expense History'
        print '(A)', '[4] View Budget Summary'
        print '(A)', '[5] Set Savings Goal'
        print '(A)', '[6] View Savings Progress'
        print '(A)', '[7] Manage Savings (Add/Remove)'
        print '(A)', '[8] Exit'
        print '(A)', '=================================='
    end subroutine show_menu


end program StudentWise
