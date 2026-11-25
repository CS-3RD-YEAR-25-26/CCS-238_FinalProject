// Check 4a: a let pattern that might not match (mirrors HOL88 Test 5.4).
// Expected: compile error E0005, refutable pattern in local binding.

fn main() {
    let v: Option<i32> = Some(5);
    let Some(x) = v;
    println!("{}", x);
}
