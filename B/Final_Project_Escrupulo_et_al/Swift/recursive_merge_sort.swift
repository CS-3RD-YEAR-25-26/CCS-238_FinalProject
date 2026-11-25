import Foundation

// Recursive Merge Sort Implementation

// Swift uses var for mutable variables.
// [Int] represents an array containing integers.
var inputArr: [Int] = [12, 31, 4, 3, 9, 5, 8, 24]
var outputArr: [Int] = []

// The inout keyword allows the function to modify
// the original array passed by the caller.
func mergeSort(_ arr: inout [Int]) {
    if arr.count > 1 {

        // let declares a constant in Swift.
        // Integer division gives the midpoint index.
        let midIndex = arr.count / 2

        // Swift's ..< range excludes the upper bound,
        // while ... includes the remaining elements.
        // Array() converts each slice into a new array.
        var leftHalf = Array(arr[..<midIndex])
        var rightHalf = Array(arr[midIndex...])

        // The & symbol is required when passing
        // an argument to an inout parameter.
        mergeSort(&leftHalf)
        mergeSort(&rightHalf)

        var i = 0
        var j = 0
        var k = 0

        // Swift uses && for logical AND.
        while i < leftHalf.count && j < rightHalf.count {

            // String interpolation uses \(expression).
            print("Comparing \(leftHalf[i]) and \(rightHalf[j])")

            if leftHalf[i] < rightHalf[j] {
                arr[k] = leftHalf[i]
                i += 1
            } else {
                arr[k] = rightHalf[j]
                j += 1
            }
            k += 1
        }

        // Copy remaining elements from the left half.
        while i < leftHalf.count {
            print("Adding remaining element from left half: \(leftHalf[i])")
            arr[k] = leftHalf[i]
            i += 1
            k += 1
        }

        // Copy remaining elements from the right half.
        while j < rightHalf.count {
            print("Adding remaining element from right half: \(rightHalf[j])")
            arr[k] = rightHalf[j]
            j += 1
            k += 1
        }

        // removeAll() clears a Swift array.
        // append(contentsOf:) adds elements from another array.
        outputArr.removeAll()
        outputArr.append(contentsOf: arr)
    }
}

// The & symbol passes inputArr for in-place modification.
print("Array before sorting:", inputArr)
mergeSort(&inputArr)
print("Sorted array is:", outputArr)
