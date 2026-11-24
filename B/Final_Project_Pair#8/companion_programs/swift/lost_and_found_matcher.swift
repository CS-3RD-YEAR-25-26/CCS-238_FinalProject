struct FoundItem {
    let name, category, location: String
}
func matches(in items: [FoundItem], category: String, location: String) -> [FoundItem] {
    items.filter { $0.category == category && $0.location == location }
}
func register(in items: inout [FoundItem], name: String, category: String, location: String) -> Bool {
    guard [name, category, location].allSatisfy({ !$0.allSatisfy(\.isWhitespace) }) else { return false }
    items.append(FoundItem(name: name, category: category, location: location)) // inout updates the caller's array.
    return true
}
func readField(_ prompt: String) -> String? { print(prompt); return readLine() }
var items = [
    FoundItem(name: "Blue umbrella", category: "umbrella", location: "library"),
    FoundItem(name: "Black umbrella", category: "umbrella", location: "library"),
    FoundItem(name: "Red umbrella", category: "umbrella", location: "canteen"),
    FoundItem(name: "Steel bottle", category: "bottle", location: "library"),
    FoundItem(name: "Notebook", category: "stationery", location: "lobby")
]
if CommandLine.arguments.contains("--test") {
    precondition(matches(in: items, category: "umbrella", location: "library").map(\.name) == ["Blue umbrella", "Black umbrella"])
    var added: [FoundItem] = []
    precondition(register(in: &added, name: " Ring ", category: "jewelry", location: "gym"))
    precondition(register(in: &added, name: " Ring ", category: "jewelry", location: "gym"))
    precondition(!register(in: &added, name: " ", category: "jewelry", location: "gym"))
    precondition(added.count == 2)
    print("lost_and_found_matcher tests passed")
} else {
    session: while true {
        print("1 Register | 2 Search | 3 Inventory | 4 Exit")
        guard let choice = readLine(), choice != "4" else { print("Goodbye."); break }
        switch choice {
        case "1":
            guard let name = readField("Item name:"), let category = readField("Category:"),
                  let location = readField("Location:") else { print("Input ended."); break session }
            print(register(in: &items, name: name, category: category, location: location)
                ? "Item registered." : "Fields must not be blank.")
        case "2":
            guard let category = readField("Category:"), let location = readField("Location:")
            else { print("Input ended."); break session }
            let found = matches(in: items, category: category, location: location)
            if found.isEmpty { print("No matches.") } else { found.forEach { print($0.name) } }
        case "3":
            items.isEmpty ? print("Inventory is empty.") :
                items.forEach { print("\($0.name) | \($0.category) | \($0.location)") }
        default: print("Choose 1, 2, 3, or 4.")
        }
    }
}
