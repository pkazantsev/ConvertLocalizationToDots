//
//  Converter.swift
//  ConvertLocalizationToDots
//
//  Created by Pavel Kazantsev on 11/07/2018.
//  Copyright © 2018 Pavel Kazantsev. All rights reserved.
//

import Foundation

func parse(_ sourceUrl: URL, filters: [RowFilter]) throws -> Trie {
    let trie = Trie()

    try String(contentsOf: sourceUrl, encoding: .utf8)
        .split(separator: "\n")
        .forEach { line in
            if line.isEmpty {}
            // Section comment
            else if line.starts(with: "//") {}
            else if let row = parseRow(line) {
                if !filters.reduce(true, { $0 && $1(row) }) {
                    return
                }

                let keySplit = row.key.split(separator: "_")
                trie.insert(words: keySplit.map { String($0) }, value: row)
            }
    }

    return trie
}
