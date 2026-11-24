protocol FarePaying { // Conforming types supply their own fare method.
    func fare(baseCentavos: Int) -> Int?
}
struct RegularPassenger: FarePaying {
    func fare(baseCentavos: Int) -> Int? {
    baseCentavos >= 0 ? baseCentavos : nil
    }
}
struct StudentPassenger: FarePaying {
    func fare(baseCentavos: Int) -> Int? {
    guard baseCentavos >= 0 else { return nil }
    let (quotient, remainder) = baseCentavos.quotientAndRemainder(dividingBy: 5)
    return quotient * 4 + (remainder * 4 + 2) / 5
    }
}
func calculateFare(for passenger: any FarePaying, baseCentavos: Int) -> Int? {
    passenger.fare(baseCentavos: baseCentavos)
}
if CommandLine.arguments.contains("--test") {
    precondition(calculateFare(for: RegularPassenger(), baseCentavos: 2000) == 2000)
    let student = StudentPassenger()
    precondition((1...6).map { student.fare(baseCentavos: $0) } == [1, 2, 2, 3, 4, 5])
    precondition(student.fare(baseCentavos: Int.max) == 7378697629483820646)
    precondition(student.fare(baseCentavos: -1) == nil)
    print("campus_fare_pass tests passed")
} else {
print("Base fare in centavos (2000 = PHP 20):")
if let input = readLine() {
    if !input.isEmpty, input.utf8.allSatisfy({ $0 >= 48 && $0 <= 57 }), let base = Int(input) {
        let passengers: [(String, any FarePaying)] = [
            ("Regular", RegularPassenger()), ("Student", StudentPassenger())
        ]
        for (name, passenger) in passengers {
            if let fare = calculateFare(for: passenger, baseCentavos: base) {
                print("\(name) fare: \(fare) centavos")
            }
        }
    } else { print("Enter a whole number from 0 to 9223372036854775807.") }
} else { print("Input ended.") }
}
