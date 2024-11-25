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

// PART 1
let symbolCoords : Set<Int> = .init(input.enumerated().flatMap { (idx, line) in
    Matches(of: /[^\d.]/, inString: line).map{ match in
        (idx, match.range.lowerBound.utf16Offset(in:line)) |> coordHash
    }
})

let part_1 = input.enumerated().flatMap { (idx, line) in
    Matches(of: /\d+/, inString: line).compactMap { match in
        let begin = match.range.lowerBound.utf16Offset(in:line)
        let coord = (idx, begin)
        let len = line[match.range].count
        return coordFilter(coord, len, db: symbolCoords) ? Int(match.0)! : nil
    }
}.reduce(0,+)

print("Part 1: \(part_1)")

// PART 2

struct Gear {
    var coord: Coord
    var numbers: [Int] = []
}

var gearCoords : [Int: Gear] = input.enumerated().flatMap { (idx, line) in
    Matches(of: /\*/, inString: line).map{ match in
        (idx, match.range.lowerBound.utf16Offset(in:line))
    }
}.reduce(into: [:]) { $0[coordHash($1)] = Gear(coord:$1)}

let gearCoordsHashes = Set(gearCoords.keys)

let part_2 = input.enumerated().flatMap { (idx, line) in
    Matches(of: /\d+/, inString: line).flatMap { match in
        let begin = match.range.lowerBound.utf16Offset(in:line)
        let coord = (idx, begin)
        let len = line[match.range].count
        return coordFind(coord, len, db: gearCoordsHashes).map {
            ($0, Int(match.0)!)
        }
    }
}
.reduce(into: gearCoords) { $0[coordHash($1.0)]?.numbers.append($1.1) }.values
.filter{$0.numbers.count == 2}
.map{$0.numbers.reduce(1,*)}.reduce(0,+)

print("Part 2: \(part_2)")



////// HELPERS //////

// Coord helpers
func coordHash(_ coord: Coord) -> Int { coord.0 << 16 | coord.1 }

func coordFilter(_ coord: Coord, _ len: Int, db: Set<Int>) -> Bool {
    return ((coord.0-1)...(coord.0+1)).first{ row in
        ((coord.1-1)...(coord.1+len)).first{ symbolCoords.contains(coordHash((row,$0))) } != nil
    } != nil
}

func coordFind(_ coord: Coord, _ len: Int, db: Set<Int>) -> [Coord]{
    return ((coord.0-1)...(coord.0+1)).flatMap { row in
        ((coord.1-1)...(coord.1+len)).compactMap {
            symbolCoords.contains(coordHash((row,$0))) ? (row,$0) : nil
        }
    }
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
