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
            else if aLine.starts(with: "  ") {
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

    private func parseFilter(from string: String) -> RowFilter? {
        // FIXME: parseFilter(from:) not implemented!
        return nil
    }
}
