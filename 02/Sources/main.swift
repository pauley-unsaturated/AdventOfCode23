// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

enum Color: String {
    case red
    case green
    case blue
}

let maxCubes: [Color: Int] = [.red: 12, .green: 13, .blue: 14]

let file = CommandLine.arguments[1]
let input = try! String(contentsOfFile: file, encoding: .utf8).split(separator: "\n")

let part_1 = input.map{ line in
    { match in
        (Int(match.1)!,
        match.2.split(separator:"; ").map{
            $0.split(separator:", ").map {
                { (components:[Substring]) in
                    (Int(components[0])!,Color(rawValue:String(components[1]))!)
                }($0.split(separator:" ")) }
              .reduce(true) { $0 && maxCubes[$1.1]! >= $1.0 }
        }.reduce(true){ $0 && $1 })
    }((try! /Game (\d+): (.*)/.wholeMatch(in:line))!)
}.reduce(0){ $0 + ($1.1 ? $1.0 : 0)}

print("Part 1: \(part_1)")
