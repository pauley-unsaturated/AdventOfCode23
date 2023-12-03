// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

let file = CommandLine.arguments[1]
let input = try! String(contentsOfFile: file, encoding: .utf8).split(separator: "\n")

// PART 1
let part_1 = input.map{$0.filter{$0.isNumber}}
  .compactMap{guard let first = $0.first, let last = $0.last else {return nil}
              return Int("\(first)\(last)")
  }
  .reduce(0, +)
print("Part 1: \(part_1)")


// PART 2
let DigitsRegex = /(\d)|(one)|(two)|(three)|(four)|(five)|(six)|(seven)|(eight)|(nine)/
let part_2 = input
  .map{Array(Digits($0))}
  .compactMap{guard let first = $0.first, let last = $0.last else {return nil}
              return Int("\(first)\(last)")
  }
  .reduce(0, +)
print("Part 2: \(part_2)")


// Digit Regex helper
struct Digits<S: StringProtocol> : Sequence, IteratorProtocol {
    var s: S
    var idx: S.Index

    init(_ str: S) {
        s = str
        idx = str.startIndex
    }

    mutating func next() -> Int? {
        guard idx < s.endIndex else { return nil }
        guard let match = try! DigitsRegex
                .firstMatch(in:Substring(s[idx...])) else {
            idx = s.endIndex
            return nil
        }
        idx = s.index(after:match.range.lowerBound)
        if let digit = match.1 { return Int(digit)! }
        if match.2 != nil { return 1 }
        if match.3 != nil { return 2 }
        if match.4 != nil { return 3 }
        if match.5 != nil { return 4 }
        if match.6 != nil { return 5 }
        if match.7 != nil { return 6 }
        if match.8 != nil { return 7 }
        if match.9 != nil { return 8 }
        if match.10 != nil { return 9 }
        fatalError("Something should have matched!")
    }
}
