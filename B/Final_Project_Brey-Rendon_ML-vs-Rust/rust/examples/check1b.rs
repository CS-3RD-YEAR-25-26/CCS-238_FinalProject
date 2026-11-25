// Check 1b: the same match with every case handled.
// Expected output: 12, 9, 10 (same numbers as HOL88 Test 3.6).

enum Shape {
    Circle(i32),
    Square(i32),
    Rect(i32, i32),
}

fn area(s: Shape) -> i32 {
    match s {
        Shape::Circle(r) => 3 * r * r,
        Shape::Square(x) => x * x,
        Shape::Rect(w, h) => w * h,
    }
}

fn main() {
    println!("{}", area(Shape::Circle(2)));
    println!("{}", area(Shape::Square(3)));
    println!("{}", area(Shape::Rect(2, 5)));
}
