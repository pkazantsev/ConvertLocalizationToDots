//
//  Row.swift
//  ConvertLocalizationToDots
//
//  Created by Pavel Kazantsev on 24/10/2017.
//  Copyright © 2017 Pavel Kazantsev. All rights reserved.
//

import Foundation

struct Row {
    var key: String
    var value: String
    var comment: String?

    func export() -> String {
        var result = ""
        result.append("\"\(key)\" = \"\(value)\";")

        if let comment = comment {
            result.append(" // \(comment)")
        }

        return result
    }
}

func trim(_ line: String) -> String {
    let characters = CharacterSet(charactersIn: ";/ \"")
    return line.trimmingCharacters(in: characters)
}
func trim(_ line: Substring) -> String {
    return trim(String(line))
}

func parseRow(_ line: Substring) -> Row? {
    let parts = line.split(separator: "=")
    guard parts.count == 2 else { return nil }

    let key = trim(parts[0])
    let rest = parts[1]
    let value: String
    let comment: String?

    if let commentStartIndex = rest.range(of: "//")?.lowerBound {
        comment = trim(rest.suffix(from: commentStartIndex))
        value = trim(rest.prefix(upTo: commentStartIndex))
    } else {
        comment = nil
        value = trim(rest)
    }
    return Row(key: key, value: value, comment: comment)
}
