// Check 3a: errors as values with Result, and ? passing errors up (mirrors HOL88 Tests 2.6 and 3.5).
// Expected output: Ok(5), Err("division by zero"), Ok(5), Err("division by zero").

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
}
