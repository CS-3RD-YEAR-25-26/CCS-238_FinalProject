// Check 4b: a let pattern with the wrong number of elements (mirrors HOL88 Test 5.4).
// Expected: compile error E0527, pattern requires 2 elements but array has 3.

fn main() {
    let [c, d] = [1, 2, 3];
    println!("{} {}", c, d);
}
