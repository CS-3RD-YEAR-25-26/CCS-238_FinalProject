// Check 2b: a generic tree using Box, with a recursive size function.
// Expected output: 3, then 1.

enum Tree<T> {
    Leaf,
    Node(Box<Tree<T>>, T, Box<Tree<T>>),
}

fn size<T>(t: &Tree<T>) -> i32 {
    match t {
        Tree::Leaf => 0,
        Tree::Node(l, _, r) => size(l) + 1 + size(r),
    }
}

fn main() {
    let small = Tree::Node(Box::new(Tree::Leaf), 1, Box::new(Tree::Leaf));
    let t = Tree::Node(
        Box::new(small),
        2,
        Box::new(Tree::Node(Box::new(Tree::Leaf), 3, Box::new(Tree::Leaf))),
    );
    println!("{}", size(&t));
    println!("{}", size(&Tree::Node(Box::new(Tree::Leaf), "a", Box::new(Tree::Leaf))));
}
