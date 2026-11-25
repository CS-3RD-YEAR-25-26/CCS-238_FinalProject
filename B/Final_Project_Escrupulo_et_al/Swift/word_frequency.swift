import Foundation

// Word Frequency Analyzer

// Swift uses let for constants and var for mutable values.
let inputText = "Hello, world! hello."

// A Swift dictionary stores word-count pairs.
var output: [String: Int] = [:]
var totalWordCount = 0
var mostCommonWords: [(String, Int)] = []

// A tuple return type allows a function to return
// the word counts, total count, and ranked words.
func analyzeText(_ text: String) -> ([String: Int], Int, [(String, Int)]) {

    // lowercased() converts the text to lowercase.
    // NSRegularExpression supports Unicode properties.
    // [\p{L}\p{N}]+ matches Unicode letters and numbers,
    // while punctuation and underscores separate words.
    let lowercaseText = text.lowercased()
    let pattern = "[\\p{L}\\p{N}]+"

    let regex = try! NSRegularExpression(pattern: pattern)

    // NSString provides UTF-16 indexing compatible
    // with NSRegularExpression's NSRange results.
    let nsText = lowercaseText as NSString
    let matches = regex.matches(
        in: lowercaseText,
        range: NSRange(location: 0, length: nsText.length)
    )

    // map transforms each regex match into a word.
    let words = matches.map {
        nsText.substring(with: $0.range)
    }

    // Swift dictionaries allow updating counts by key.
    // The nil-coalescing operator ?? supplies zero
    // when a word does not yet exist.
    var wordCounts: [String: Int] = [:]

    for word in words {
        wordCounts[word, default: 0] += 1
    }

    // sorted() orders dictionary keys alphabetically.
    let alphabeticalKeys = wordCounts.keys.sorted()

    var alphabeticalCounts: [String: Int] = [:]

    for word in alphabeticalKeys {
        alphabeticalCounts[word] = wordCounts[word]
    }

    // sorted(by:) uses a closure to define ordering.
    // Higher frequency comes first; ties are alphabetical.
    let rankedWords = wordCounts.map { ($0.key, $0.value) }
        .sorted {
            if $0.1 == $1.1 {
                return $0.0 < $1.0
            }
            return $0.1 > $1.1
        }

    return (alphabeticalCounts, words.count, rankedWords)
}

print("Paragraph:", inputText)

// Tuple decomposition assigns the returned values.
(output, totalWordCount, mostCommonWords) = analyzeText(inputText)

// prefix(3) returns up to three elements.
mostCommonWords = Array(mostCommonWords.prefix(3))

print("\nWord frequencies (alphabetical):")

// Dictionary iteration is not guaranteed to be ordered,
// so we explicitly iterate over sorted keys.
for word in output.keys.sorted() {
    if let count = output[word] {
        print("\(word): \(count)")
    }
}

print("\nText summary:")
print("Total words:", totalWordCount)
print("Unique words:", output.count)

// Format tuples similarly to the Python baseline.
let formattedWords = mostCommonWords.map {
    "('\($0.0)', \($0.1))"
}.joined(separator: ", ")

print("Most frequent words: [\(formattedWords)]")
