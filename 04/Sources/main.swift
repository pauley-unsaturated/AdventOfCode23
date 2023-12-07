import Foundation

let file = CommandLine.arguments[1]
let input = try! String(contentsOfFile: file, encoding: .utf8).split(separator: "\n")

// PART 1
let lineRegex = /Card\s+(\d+): (.*) \| (.*)/
let winners = try input.compactMap { (line: Substring) -> (Substring,Substring)? in
    guard let match = try lineRegex.wholeMatch(in: line) else {return nil}
    return (match.2, match.3)
}
  .map{ (winningNumbers, ourNumbers) in
      let winners = Set<Int>(IntStream(winningNumbers))
      return IntStream(ourNumbers).filter{winners.contains($0)}.count
}

let part_1 = winners.filter{ $0 > Int(0) }.map{ 1 << Int($0-1) }.reduce(Int(0), +)

print("Part 1: \(part_1)")


func IntStream<S: StringProtocol>(_ str: S) -> [Int] {
    Matches(of: /\d+/, inString: str).map{Int($0.0)!}
}

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
