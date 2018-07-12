//
//  main.swift
//  ConvertLocalizationToDots
//
//  Created by Pavel Kazantsev on 24/10/2017.
//  Copyright © 2017 Pavel Kazantsev. All rights reserved.
//

import Foundation
import Commander

command(
    Argument<String>("source", description: "Path to a source .string file"),
    Argument<String>("destination", description: "Path to a destination .string file"),
    Option("config", default: "./dots.config", description: "Path to a configuration file")
) { srcPath, dstPath, configPath in
    let sourceUrl = URL(fileURLWithPath: NSString(string: srcPath).expandingTildeInPath)
    print("from: \(sourceUrl)")
    let targetUrl = URL(fileURLWithPath: NSString(string: dstPath).expandingTildeInPath)
    print("to: \(targetUrl)")
    let configUrl = URL(fileURLWithPath: NSString(string: configPath).expandingTildeInPath)
    print("config: \(configUrl)")

    let config = Config(at: configUrl)
    config.read()
    do {
        let trie = try parse(sourceUrl, filters: config.rowFilters)

        try trie.keyValuePairs(toSplit: config.keysToSplit, toNotSplit: config.keysToNotSplit)
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
