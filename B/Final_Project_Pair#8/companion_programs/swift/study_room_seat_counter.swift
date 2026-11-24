final class StudyRoom {
let capacity: Int
private(set) var occupied = 0 // Callers can read this; only StudyRoom can set it.
var available: Int { capacity - occupied }
init?(capacity: Int) {
    guard capacity >= 0 else { return nil }
    self.capacity = capacity
}
func reserve() -> Bool {
    guard available > 0 else { return false }
    occupied += 1
    return true
}
func cancel() -> Bool {
    guard occupied > 0 else { return false }
    occupied -= 1
    return true
}
}
let room = StudyRoom(capacity: 2)!
if CommandLine.arguments.contains("--test") {
    precondition(StudyRoom(capacity: -1) == nil)
    precondition(StudyRoom(capacity: 0)?.reserve() == false)
    precondition(!room.cancel() && room.reserve() && room.reserve() && !room.reserve())
    precondition(room.occupied == 2 && room.available == 0)
    precondition(room.cancel() && room.cancel() && !room.cancel())
    precondition(room.occupied == 0 && room.available == 2)
    print("study_room_seat_counter tests passed")
} else {
while true {
    print("1 Reserve | 2 Cancel | 3 Status | 4 Exit")
    guard let choice = readLine(), choice != "4" else { print("Goodbye."); break }
    if choice == "3" {
        print("Status: occupied=\(room.occupied); available=\(room.available)")
    } else if choice == "1" || choice == "2" {
        let name = choice == "1" ? "Reserve" : "Cancel"
        let accepted = choice == "1" ? room.reserve() : room.cancel()
        print("\(name): \(accepted ? "accepted" : "rejected"); occupied=\(room.occupied); available=\(room.available)")
    } else { print("Choose 1, 2, 3, or 4.") }
}
}
