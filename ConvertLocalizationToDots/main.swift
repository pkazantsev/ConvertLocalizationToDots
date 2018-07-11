//
//  main.swift
//  ConvertLocalizationToDots
//
//  Created by Pavel Kazantsev on 24/10/2017.
//  Copyright © 2017 Pavel Kazantsev. All rights reserved.
//

import Foundation

/// return true if the element should be kept
typealias RowFilter = (Row) -> Bool

let sourceUrl = URL(fileURLWithPath: "/Users/p.kazantsev/Downloads/Localizable.strings")
print(sourceUrl)
let targetUrl = URL(fileURLWithPath: "/Users/p.kazantsev/Downloads/Localizable_dots.strings")
print(targetUrl)

let trie = Trie()

let keysToSplit: [String] = [
    "confirm",
    "send_feedback",
    "set_pin",
    "shortcut"
]
let keysToNotSplit: [String] = [
    "application",
    "cards.card",
    "cards.title",
    "registration.phone",
    "send",
    "settings.use",
]
let rowFilters: [(RowFilter)] = [
    { !$0.key.isEmpty },
    { $0.comment != "для WP" },
    { !$0.key.hasPrefix("windows") },
    { !$0.key.hasSuffix("wp") },
    { !$0.key.contains("android") },
    { !$0.key.contains("nfc") }
]

// MARK: -
do {
    try String(contentsOf: sourceUrl, encoding: .utf8)
        .split(separator: "\n")
        .forEach { line in
            if line.isEmpty {
            }
            else if line.starts(with: "//") {
                // Section comment
            }
            else if let row = parseRow(line) {
                if !rowFilters.reduce(true, { $0 && $1(row) }) {
                    return
                }

                let keySplit = row.key.split(separator: "_")
                trie.insert(words: keySplit.map { String($0) }, value: row)
            }
        }
    try trie.keyValuePairs(toSplit: keysToSplit, toNotSplit: keysToNotSplit)
        .map { (key, row) -> String in
            var updatedRow = row
            updatedRow.key = key
            return updatedRow.export()
        }
        .joined(separator: "\n")
        .write(to: targetUrl, atomically: true, encoding: .utf8)

} catch {
    print(error)
}

