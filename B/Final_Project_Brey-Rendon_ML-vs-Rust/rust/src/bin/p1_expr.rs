// ======================================================================
// P1: Expression evaluator, in Rust
//
// Problem: represent arithmetic expressions as a tree (a syntax tree),
// then compute each expression's value and print it with brackets that
// show how the tree is grouped.
// An expression is one of four kinds:
//   a number, an addition, a multiplication, or a negation.
//
// Test data (the same as the 1973 ML version) and expected results:
//   (2 + 3) * 4          ->  ((2 + 3) * 4) = 20
//   2 + 3 * 4            ->  (2 + (3 * 4)) = 14
//   -(2 + 3)             ->  -(2 + 3) = -5
//   (1 + 2) * (3 + 4)    ->  ((1 + 2) * (3 + 4)) = 21
//
// Run: in the rust folder, type   cargo run --bin p1_expr
// ======================================================================

// 1. THE EXPRESSION TYPE
// An enum declares the four kinds of expression directly, each with a name
// and the data it carries. This one declaration replaces the 1973 ML
// version's nested sum encoding plus its twelve num/is_/dest_ functions:
// Rust generates the constructors (Expr::Add(...)), and match does the
// testing and taking apart.
// Box<Expr> is needed because an Expr contains other Exprs: Rust must know
// every type's size at compile time, so sub-expressions are stored on the
// heap behind a pointer of fixed size (see examples/check2a.rs).
enum Expr {
    Num(i32),
    Add(Box<Expr>, Box<Expr>),
    Mul(Box<Expr>, Box<Expr>),
    Neg(Box<Expr>),
}

// Short helper functions so the tests read like the ML version's
// num/add/mul/neg. They only wrap the sub-expressions in Box::new.
fn num(n: i32) -> Expr {
    Expr::Num(n)
}
fn add(a: Expr, b: Expr) -> Expr {
    Expr::Add(Box::new(a), Box::new(b))
}
fn mul(a: Expr, b: Expr) -> Expr {
    Expr::Mul(Box::new(a), Box::new(b))
}
fn neg(a: Expr) -> Expr {
    Expr::Neg(Box::new(a))
}

// 2. EVALUATE
// One match tests the kind and takes the expression apart in a single step.
// The compiler checks that every variant of Expr is handled. If a fifth kind
// (for example Sub) were added to the enum but not here, the program would
// not compile at all (error E0004, see examples/check1a.rs). The ML version
// would load and fail only when such an expression is evaluated.
// e is a borrow (&Expr), so the patterns bind borrows too: n is an &i32,
// and *n reads the number it points to.
fn eval(e: &Expr) -> i32 {
    match e {
        Expr::Num(n) => *n,
        Expr::Add(a, b) => eval(a) + eval(b),
        Expr::Mul(a, b) => eval(a) * eval(b),
        Expr::Neg(a) => -eval(a),
    }
}

// 3. SHOW: turn an expression back into text, with full brackets.
// format! builds a String the same way println! prints one.
fn show(e: &Expr) -> String {
    match e {
        Expr::Num(n) => n.to_string(),
        Expr::Add(a, b) => format!("({} + {})", show(a), show(b)),
        Expr::Mul(a, b) => format!("({} * {})", show(a), show(b)),
        Expr::Neg(a) => format!("-{}", show(a)),
    }
}

fn report(e: &Expr) -> String {
    format!("{} = {}", show(e), eval(e))
}

// 4. TESTS (the same data as the 1973 ML version)
// The tree, not the text, decides the grouping: the first two tests use the
// same numbers and operators but build different trees.
fn main() {
    println!("{}", report(&mul(add(num(2), num(3)), num(4))));
    println!("{}", report(&add(num(2), mul(num(3), num(4)))));
    println!("{}", report(&neg(add(num(2), num(3)))));
    println!("{}", report(&mul(add(num(1), num(2)), add(num(3), num(4)))));
}
