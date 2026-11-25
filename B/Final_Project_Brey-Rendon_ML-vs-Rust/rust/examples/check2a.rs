// Check 2a: a recursive enum without Box (mirrors HOL88 Tests 4.4-4.6).
// Expected: compile error E0072, recursive type Tree has infinite size.

enum Tree {
    Leaf,
    Node(Tree, i32, Tree),
}

fn main() {}
