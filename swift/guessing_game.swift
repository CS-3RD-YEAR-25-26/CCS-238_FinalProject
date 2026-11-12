let secret = 42
print("Enter 0 to quit.")
while true {
    print("Enter your guess:")
    guard let text = readLine() else { break }
    guard let guess = Int(text) else {
        print("Please enter a whole number.")
        continue
    }
    if guess == 0 { break }
    if guess == secret {
        print("Correct!")
        break
    }
    print(guess < secret ? "Too low" : "Too high")
}
