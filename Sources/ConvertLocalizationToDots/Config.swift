//
//  Config.swift
//  ConvertLocalizationToDots
//
//  Created by Pavel Kazantsev on 12/07/2018.
//  Copyright © 2018 Pavel Kazantsev. All rights reserved.
//

import Foundation

/// return true if the element should be kept
typealias RowFilter = (Row) -> Bool

private enum ConfigGoup: String {
    case unknown
    case keysToSplit = "keys_to_split"
    case keysToNotSplit = "keys_to_not_split"
    case filters
}

class Config {

    private(set) var keysToSplit: [String] = []
    private(set) var keysToNotSplit: [String] = []
    private(set) var rowFilters: [RowFilter] = []

    private let configFileURL: URL

    init(at configFile: URL) {
        self.configFileURL = configFile.absoluteURL
    }

    func read() {
        guard FileManager.default.fileExists(atPath: configFileURL.path) else { return }
        guard let text = try? String(contentsOf: configFileURL) else { return }

        var currentGroup: ConfigGoup = .unknown
        for aLine in text.split(separator: "\n") {
            if aLine.starts(with: "//") {
                // Comment, ignore
            }
            else if aLine.starts(with: "  ") || aLine.starts(with: "\t") {
                switch currentGroup {
                case .unknown:
                    break
                default:
                    let value = aLine.trimmingCharacters(in: .whitespacesAndNewlines)
                    parseConfigRow(value, group: currentGroup)
                }
            } else {
                let groupName = aLine.trimmingCharacters(in: .init(charactersIn: " :"))
                currentGroup = ConfigGoup(rawValue: groupName) ?? .unknown
            }
        }
    }

    private func parseConfigRow(_ string: String, group: ConfigGoup) {
        switch group {
        case .keysToSplit:
            keysToSplit.append(string.trimmingCharacters(in: .init(charactersIn: "\"")))
        case .keysToNotSplit:
            keysToNotSplit.append(string.trimmingCharacters(in: .init(charactersIn: "\"")))
        case .filters:
            if let filter = parseFilter(from: string) {
                rowFilters.append(filter)
            }
        case .unknown:
            break
        }
    }

    // MARK: - Filters

    fileprivate enum FilterOperation: String {
        case notEmpty = "!empty"
        case notEqual = "!eq"
        case notPrefix = "!prefix"
        case notSuffix = "!suffix"
        case notContains = "!contains"
    }

    fileprivate enum FilterKey: String {
        case key
        case comment
    }

    private func parseFilter(from string: String) -> RowFilter? {
        // 1. find the value
        let valueStartIndex = string.firstIndex(of: "\"") ?? string.endIndex

        // 2. take the rest and find the column and the operator
        let ops = string[..<valueStartIndex].split(separator: " ")
        guard ops.count == 2 else { return nil }

        guard let key = FilterKey(rawValue: String(ops[0])) else { return nil }
        guard let op = FilterOperation(rawValue: String(ops[1])) else { return nil }

        // 3. get the value
        let value = string[valueStartIndex...].trimmingCharacters(in: .init(charactersIn: "\""))

        // 4. create a function
        switch op {
        case .notEmpty: return isNotEmpty(key: key)
        case .notEqual: return isNotEqual(key: key, value: value)
        case .notPrefix: return dontHavePrefix(key: key, value: value)
        case .notSuffix: return dontHaveSuffix(key: key, value: value)
        case .notContains: return doesNotContain(key: key, value: value)
        }
    }

}

private func value(for key: Config.FilterKey, from row: Row) -> String? {
    switch key {
    case .key: return row.key
    case .comment: return row.comment
    }
}

private func isNotEmpty(key: Config.FilterKey) -> RowFilter {
    return { row in
        guard let testStr = value(for: key, from: row) else { return false }
        return !testStr.isEmpty
    }
}
private func isNotEqual(key: Config.FilterKey, value str: String) -> RowFilter {
    return { row in
        guard let testStr = value(for: key, from: row) else { return true }
        return testStr != str
    }
}
private func dontHavePrefix(key: Config.FilterKey, value str: String) -> RowFilter {
    return { row in
        guard let testStr = value(for: key, from: row) else { return true }
        return !testStr.hasPrefix(str)
    }
}
private func dontHaveSuffix(key: Config.FilterKey, value str: String) -> RowFilter {
    return { row in
        guard let testStr = value(for: key, from: row) else { return true }
        return !testStr.hasSuffix(str)
    }
}
private func doesNotContain(key: Config.FilterKey, value str: String) -> RowFilter {
    return { row in
        guard let testStr = value(for: key, from: row) else { return true }
        return !testStr.contains(str)
    }
}
