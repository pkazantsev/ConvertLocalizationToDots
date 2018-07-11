//
//  main.swift
//  ConvertLocalizationToDots
//
//  Created by Pavel Kazantsev on 24/10/2017.
//  Copyright © 2017 Pavel Kazantsev. All rights reserved.
//

import Foundation
import Commander

/// return true if the element should be kept
typealias RowFilter = (Row) -> Bool

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

command(
    Argument<String>("source", description: "Path to a source .string file"),
    Argument<String>("destination", description: "Path to a destination .string file")
) { srcPath, dstPath in
    let sourceUrl = URL(fileURLWithPath: srcPath)
    print(sourceUrl)
    let targetUrl = URL(fileURLWithPath: dstPath)
    print(targetUrl)
    do {
        let trie = try parse(sourceUrl, filters: rowFilters)

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

}.run()
