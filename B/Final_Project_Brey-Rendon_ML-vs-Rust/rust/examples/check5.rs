// Check 5: turning text into a number (mirrors HOL88 Test 6).
// Expected output: Ok(42), Ok(-7), Err(InvalidDigit), Err(Empty), Err(InvalidDigit), 3.

fn main() {
    println!("{:?}", "42".parse::<i32>());
    println!("{:?}", "-7".parse::<i32>());
    println!("{:?}", "x".parse::<i32>());
    println!("{:?}", "".parse::<i32>());
    println!("{:?}", "12a".parse::<i32>());
    println!("{}", 10 / 3);
}
