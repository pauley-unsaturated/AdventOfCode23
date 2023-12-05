// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

// Plan: use regex and scan each line for numbers and symbols
// - insert the symbols into a list
// - for each number, search for a symbol of euclidean distance < 2
// filter list of numbers based on that

let file = CommandLine.arguments[1]
let input = try! String(contentsOfFile: file, encoding: .utf8).split(separator: "\n")

typealias Coord = (Int,Int)

// Hash all of the symbol coords
let symbolCoords : Set<Int> = input.enumerated().flatMap { (idx, line) in
    Matches(of: /[^\d.]/, inString: line).map{ match in
        (idx, match.range.lowerBound.utf16Offset(in:line)) |> coordHash
    }
}.reduce(into:.init()){$0.insert($1)}

let part_1 = input.enumerated().flatMap { (idx, line) in
    Matches(of: /\d+/, inString: line).compactMap { match in
        let begin = match.range.lowerBound.utf16Offset(in:line)
        let coord = (idx, begin)
        let len = line[match.range].count
        return coordFind(coord, len, db: symbolCoords) ? Int(match.0)! : nil
    }
}.reduce(0,+)

print("Part 1: \(part_1)")


////// HELPERS //////

// Coord helpers
func coordHash(_ coord: Coord) -> Int { coord.0 << 16 | coord.1 }

func coordFind(_ coord: Coord, _ len: Int, db: Set<Int>) -> Bool {
    return ((coord.0-1)...(coord.0+1)).first{ row in
        ((coord.1-1)...(coord.1+len)).first{ symbolCoords.contains(coordHash((row,$0))) } != nil
    } != nil
}


// Functional helpers
precedencegroup ForwardApplication {
    associativity: left
}

infix operator |>: ForwardApplication
infix operator >>>: ForwardApplication

public func |> <A, B>(x: A, f: (A) throws -> B) rethrows -> B { try f(x) }
public func >>> <A,B,C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
    return { x in g(f(x)) }
}


// Helper to find all matches for a regex in a given String
struct Matches<S: StringProtocol, O> : Sequence, IteratorProtocol {
    let regex: Regex<O>
    var s: S
    var idx: S.Index
    let overlapping: Bool

    init(of regex:Regex<O>, inString str: S, overlapping: Bool = false) {
        self.regex = regex
        s = str
        idx = str.startIndex
        self.overlapping = overlapping
    }

    mutating func next() -> Regex<O>.Match? {
        guard idx < s.endIndex else { return nil }
        guard let match = try! regex
                .firstMatch(in:Substring(s[idx...])) else {
            idx = s.endIndex
            return nil
        }
        if overlapping {
            idx = s.index(after:match.range.lowerBound)
        }
        else {
            idx = match.range.upperBound
        }
        return match
    }
}
