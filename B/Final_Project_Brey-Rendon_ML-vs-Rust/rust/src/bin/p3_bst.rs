// ======================================================================
// P3: Generic binary search tree, in Rust
//
// Problem: store values of any type in a binary search tree, then
// insert, look up, and list them in order.
//
// Test data (the same as the 1973 ML version):
//   numbers 5, 3, 8, 1, 4   ->  in order [1, 3, 4, 5, 8]; 4 is present, 7 is not
//   words pear, apple, fig  ->  in order ["apple", "fig", "pear"]
//
// Run: in the rust folder, type   cargo run --bin p3_bst
// ======================================================================

use std::cmp::Ordering;

// 1. THE TREE TYPE
// An enum declares the two kinds of tree directly, by name. This is the
// algebraic data type that 1973 ML lacked: there, a tree had to be encoded
// as a disjoint sum (void + ...) hidden inside absrectype.
// <T> makes the tree generic: a tree of any element type T.
// Box<...> stores each subtree in its own heap allocation. Rust must know
// the size of every type at compile time, and a Tree that directly held two
// Trees would have infinite size (see examples/check2a.rs). ML needed no Box
// because its garbage-collected memory handles this automatically.
enum Tree<T> {
    Empty,
    Node(Box<Tree<T>>, T, Box<Tree<T>>),
}

// 2. INSERT
// T: Ord is a trait bound: T may be any type with a total ordering
// (integers, strings, ...). It gives T a cmp method, so no comparison
// function has to be passed in (contrast the ML version's lt argument).
// The signature must be written in full; Rust does not infer the types of
// function parameters or results, unlike ML.
// insert takes ownership of the tree (t: Tree<T>, with no &) and returns the
// updated tree. The old tree is moved into the call and cannot be used again.
fn insert<T: Ord>(t: Tree<T>, x: T) -> Tree<T> {
    // match must handle every variant of Tree; leaving one out is a compile
    // error (see examples/check1a.rs). ML's is_empty/parts tests had no such check.
    match t {
        Tree::Empty => Tree::Node(Box::new(Tree::Empty), x, Box::new(Tree::Empty)),
        // The pattern takes the node apart and names its three fields.
        // cmp returns an Ordering, which is itself an enum with three
        // variants, so this inner match is also checked for completeness.
        Tree::Node(l, y, r) => match x.cmp(&y) {
            // *l moves the subtree out of its Box so it can be passed by value.
            Ordering::Less => Tree::Node(Box::new(insert(*l, x)), y, r),
            Ordering::Greater => Tree::Node(l, y, Box::new(insert(*r, x))),
            Ordering::Equal => Tree::Node(l, y, r), // already present: unchanged
        },
    }
}

// 3. MEMBER: is x stored in the tree?
// &Tree<T> and &T are borrows: member only reads its arguments, so it does
// not take ownership and the caller can keep using the tree afterwards.
fn member<T: Ord>(t: &Tree<T>, x: &T) -> bool {
    match t {
        Tree::Empty => false,
        Tree::Node(l, y, r) => match x.cmp(y) {
            Ordering::Less => member(l, x),
            Ordering::Greater => member(r, x),
            Ordering::Equal => true,
        },
    }
}

// 4. IN-ORDER LISTING: left subtree, then the value, then right subtree.
// Returns references to the elements (Vec<&T>) instead of copies of them.
// The compiler ties the lifetime of those references to the borrowed tree
// (lifetime elision), so the list can never outlive the tree it points into.
fn inorder<T>(t: &Tree<T>) -> Vec<&T> {
    match t {
        Tree::Empty => Vec::new(),
        Tree::Node(l, y, r) => {
            let mut v = inorder(l); // mut: v is changed by the next two lines
            v.push(y);
            v.extend(inorder(r));
            v
        }
    }
}

// 5. BUILD A TREE FROM A LIST, inserting the elements left to right.
// Vec<T> is a growable array; the for loop moves each element into the tree.
fn build<T: Ord>(xs: Vec<T>) -> Tree<T> {
    let mut t = Tree::Empty; // type Tree<T> is inferred from the return type
    for x in xs {
        t = insert(t, x);
    }
    t
}

// 6. TESTS (the same data as the 1973 ML version)
fn main() {
    // Inside a function body Rust infers types (numbers is a Tree<i32>),
    // but every function signature above had to be written out in full.
    let numbers = build(vec![5, 3, 8, 1, 4]);
    println!("In order: {:?}", inorder(&numbers));
    println!("member 4: {}", member(&numbers, &4));
    println!("member 7: {}", member(&numbers, &7));

    let words = build(vec!["pear", "apple", "fig"]);
    println!("In order: {:?}", inorder(&words));
    println!("member fig: {}", member(&words, &"fig"));

    // Type safety check: remove the // on the next line, then run again, to
    // see the compiler reject a word inserted into a tree of numbers (E0308).
    // let numbers = insert(numbers, "kiwi");
}
