// ======================================================================
// P2: Parse and average, in Rust
//
// Problem: given a list of texts, turn each one into a whole number,
// report the texts that are not valid numbers (and why), and give the
// average of the valid ones.
//
// Rules (the same in both languages):
//   - a valid number is non-empty and made only of the digits 0 to 9,
//     so "-7" and "12a" are rejected
//   - the average uses whole-number division (10 / 3 = 3)
//   - if no text is valid, report an error instead of an average
//
// Test data (the same as the 1973 ML version) and expected results:
//   "10" "20" "x" "30"  ->  bad: "x" (not a digit)          average: 20
//   "12a" "7"           ->  bad: "12a" (not a digit)        average: 7
//   "" "-7" "5"         ->  bad: "" (empty) "-7" (not a digit)   average: 5
//   "a" "b"             ->  no valid numbers, so the average is an error
//   (empty list)        ->  no valid numbers, so the average is an error
//   "2147483648" "5"    ->  the one intended difference: i32 holds at most
//                           2147483647, so Rust rejects this number as too
//                           large, while ML (no size limit) accepts it
//
// Run: in the rust folder, type   cargo run --bin p2_parse
// ======================================================================

// 1. ONE DIGIT
// to_digit(10) returns an Option<u32>: Some(value) for '0' to '9', None otherwise.
// ok_or turns that Option into a Result, attaching an error message.
// Result<u32, String> means "either Ok(a number) or Err(a message)", so the
// signature itself says this function can fail (ML's digit_value: string -> int
// did not).
fn digit_value(c: char) -> Result<u32, String> {
    c.to_digit(10).ok_or(String::from("not a digit"))
}

// 2. ONE NUMBER
// i32 is a fixed-size 32-bit integer (largest value 2147483647), the size the
// hardware handles directly. checked_mul and checked_add return None instead of
// overflowing, so a number that is too large becomes an error, not a crash.
// The ? operator passes an Err straight up to the caller. Unlike ML, where a
// failure propagates invisibly, every point where an error can propagate is
// marked in the code. (Note: ML's ? CATCHES a failure; Rust's ? PASSES it on.)
fn parse_number(s: &str) -> Result<i32, String> {
    if s.is_empty() {
        return Err(String::from("empty"));
    }
    let mut value: i32 = 0; // mut: value changes on every loop iteration
    for c in s.chars() {
        let d = digit_value(c)? as i32;
        value = value
            .checked_mul(10)
            .and_then(|v| v.checked_add(d)) // |v| ... is a closure (a lambda)
            .ok_or(String::from("too large"))?;
    }
    Ok(value)
}

// 3. SORT THE INPUTS INTO GOOD NUMBERS AND BAD TEXTS
// Returns a pair: (numbers, bad texts), each bad text paired with its message.
// &[&'a str] is a borrowed slice of borrowed texts: the function reads the
// inputs without taking ownership of them.
// 'a is a LIFETIME parameter. The bad texts in the result are borrowed from the
// input, and 'a tells the compiler that the result cannot outlive the input.
// Rust cannot work this out by itself here, because the parameter contains two
// borrows (the slice and the texts), so it must be written.
// match on a Result must handle both Ok and Err; forgetting one is a compile
// error. It handles only the errors parse_number returns, nothing else.
fn split_inputs<'a>(xs: &[&'a str]) -> (Vec<i32>, Vec<(&'a str, String)>) {
    let mut good = Vec::new();
    let mut bad = Vec::new();
    for &s in xs {
        match parse_number(s) {
            Ok(n) => good.push(n),
            Err(msg) => bad.push((s, msg)),
        }
    }
    (good, bad)
}

// 4. AVERAGE
// Returns Err instead of dividing by zero when there are no numbers.
// The sum is computed in i64 (64-bit) so that adding many large i32 values
// cannot overflow; the average itself always fits back into an i32.
// / on integers is whole-number division, like ML's.
fn average(xs: &[i32]) -> Result<i32, String> {
    if xs.is_empty() {
        Err(String::from("no valid numbers"))
    } else {
        let sum: i64 = xs.iter().map(|&x| x as i64).sum();
        Ok((sum / xs.len() as i64) as i32)
    }
}

// 5. REPORT
// format! builds a String the same way println! prints one.
// The match handles both outcomes of average, so the report can say which
// error happened instead of stopping the program.
fn report(xs: &[&str]) -> String {
    let (good, bad) = split_inputs(xs);
    let bad_text = if bad.is_empty() {
        String::from("(none) ")
    } else {
        bad.iter()
            .map(|(s, msg)| format!("\"{}\" ({}) ", s, msg))
            .collect::<String>()
    };
    let avg_text = match average(&good) {
        Ok(a) => a.to_string(),
        Err(msg) => format!("error: {}", msg),
    };
    format!("bad: {}| average: {}", bad_text, avg_text)
}

// 6. TESTS (the same data as the 1973 ML version)
fn main() {
    println!("{}", report(&["10", "20", "x", "30"]));
    println!("{}", report(&["12a", "7"]));
    println!("{}", report(&["", "-7", "5"]));
    println!("{}", report(&["a", "b"]));
    println!("{}", report(&[]));
    println!("{}", report(&["2147483648", "5"]));
}
