# Arostique and Sagala: Term paper for Comparative Study of Lisp and Elixir

Companion programs for Lisp and Elixir. Each language implements the same three exercises using the same sample inputs. Run a pair of scripts to compare how they reach the same result.

## Setup

| Language | Runtime used in the project | Installation |
| --- | --- | --- |
| Common Lisp | Steel Bank Common Lisp (SBCL) 2.6.10 | [SBCL downloads](https://www.sbcl.org/platform-table.html) |
| Elixir | Elixir 1.20.5 with Erlang/OTP 29 (ERTS 17.1.1) | [Elixir and Erlang installation guide](https://elixir-lang.org/install/) |

Open a terminal or Windows PowerShell in the folder containing this README. The commands below assume the three `.lisp` files are in `lisp/` and the three `.exs` files are in `elixir/`. To check the installed runtimes, run `sbcl --version` and `elixir --version`.

## Run the programs

Choose any command below. Each script uses a built-in sample and prints its result immediately. Keep the quotation marks around the filenames because they contain spaces.

**Lisp**

```sh
sbcl --script "lisp/Factorial Calculator.lisp"
sbcl --script "lisp/Student Grade Analyzer.lisp"
sbcl --script "lisp/Shopping Cart Calculator.lisp"
```

**Elixir**

```sh
elixir "elixir/Factorial Calculator.exs"
elixir "elixir/Student Grade Analyzer.exs"
elixir "elixir/Shopping Cart Calculator.exs"
```

## Read the code and check the results

### Factorial Calculator

Both programs start with `n = 5` and print `Factorial of 5: 120`. To trace the stopping case, change the sample value near the bottom of either file to `1`. The function calls itself with `0`, gets back `1`, and returns `1 × 1`.

- **Lisp:** `factorial` checks that its argument is a nonnegative integer. It then uses `if` to choose between the stopping case and the recursive call.
- **Elixir:** `Factorial.calculate/1` has one clause for zero and a guarded clause for positive integers.

Try `-1` to check input handling. Lisp reports `Factorial requires a nonnegative integer. Received -1.` Elixir raises `FunctionClauseError`. Both stop before recursion.

### Student Grade Analyzer

The sample uses four scores and a passing threshold of 70. Lisp checks `(null grades)` before calculating the statistics, then counts passing and failing scores in a loop. Elixir checks `grades == []` and uses `Enum.reduce` to carry both counts through the list.

```text
Grades: (85 92 70 58)
Average: 76.25
Highest: 92
Lowest: 58
Passing grades: 3
Failing grades: 1
Passing threshold: 70
```

The score of 70 counts as passing. To try the empty-list case, change the sample assigned to `*grades*` in Lisp to `'()` or the sample assigned to `grades` in Elixir to `[]`. Rerun the script. It should print `No grades available.`

### Shopping Cart Calculator

Each product row contains a name, a quantity, and a unit price in whole currency units. Three pencils at 10 each contribute 30. Two notebooks at 50 each contribute 100. A subtotal of at least 100 qualifies for a 10% discount, rounded down to a whole unit. The sample receipt ends with these lines.

```text
Subtotal: 130.00
Discount (10%): 13.00
Final total: 117.00
```

Lisp reads the first three positions of each product and updates the subtotal with `(incf subtotal item-total)`. Elixir matches each row against `[name, quantity, unit_price]` and returns the updated subtotal from its reduction.

To reproduce the paper’s reliability comparison, change only the pencil row in each file, keeping the notebook row as supplied.

| Change | Lisp pencil row | Elixir pencil row | Expected behavior |
| --- | --- | --- | --- |
| Add a fourth field | `("Pencil" 3 10 "extra")` | `["Pencil", 3, 10, "extra"]` | Lisp ignores the fourth field and prints the same receipt. Elixir raises `FunctionClauseError` when it reaches that row. |
| Swap quantity and price | `("Pencil" 10 3)` | `["Pencil", 10, 3]` | Both display quantity 10 and price 3. The pencil line still totals 30, so checking the total alone misses the swap. |

Run each change separately. Restore the original pencil row to reproduce the paper’s sample output.
