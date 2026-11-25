// Check 1a: a match that misses a case (mirrors HOL88 Tests 3.6 and 4.1).
// Expected: compile error E0004, Shape::Rect(_, _) not covered.

enum Shape {
    Circle(i32),
    Square(i32),
    Rect(i32, i32),
}

fn area(s: Shape) -> i32 {
    match s {
        Shape::Circle(r) => 3 * r * r,
        Shape::Square(x) => x * x,
    }
}

fn main() {
    println!("{}", area(Shape::Rect(2, 5)));
}
