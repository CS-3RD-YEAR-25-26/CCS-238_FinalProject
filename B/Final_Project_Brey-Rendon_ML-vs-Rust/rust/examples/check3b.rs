// Check 3b: using a Result as if it were a plain number.
// Expected: compile error E0308, expected i32, found Result<i32, String>.

fn safe_div(x: i32, y: i32) -> Result<i32, String> {
    if y == 0 {
        Err(String::from("division by zero"))
    } else {
        Ok(x / y)
    }
}

fn half_of_quotient(x: i32, y: i32) -> Result<i32, String> {
    let q = safe_div(x, y)?;
    Ok(q / 2)
}

fn main() {
    println!("{:?}", safe_div(10, 2));
    println!("{:?}", safe_div(10, 0));
    println!("{:?}", half_of_quotient(20, 2));
    println!("{:?}", half_of_quotient(20, 0));
    let n: i32 = safe_div(10, 2);
}
