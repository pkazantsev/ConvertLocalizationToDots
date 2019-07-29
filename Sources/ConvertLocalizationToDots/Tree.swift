//
//  Tree.swift
//  ConvertLocalizationToDots
//
//  Created by Pavel Kazantsev on 24/10/2017.
//  Copyright © 2017 Pavel Kazantsev. All rights reserved.
//

import Foundation

/// A node in the trie
class TrieNode<T: Hashable, V> {
    var key: T
    var value: V?

    weak var parentNode: TrieNode?
    var children: [T: TrieNode] = [:]
    var isTerminating = false
    var isLeaf: Bool {
        return children.count == 0
    }

    /// Initializes a node.
    ///
    /// - Parameters:
    ///   - key: The key that goes into the node
    ///   - value: The value that goes with the node
    ///   - parentNode: A reference to this node's parent
    init(key: T, value: V? = nil, parentNode: TrieNode? = nil) {
        self.key = key
        self.value = value
        self.parentNode = parentNode
    }

    /// Adds a child node to self.  If the child is already present,
    /// do nothing.
    ///
    /// - Parameter key: The item to be added to this node.
    /// - Parameter value: The payload.
    @discardableResult
    func add(key: T, value: V?) -> TrieNode {
        if let existingNode = children[key] {
            return existingNode
        }
        let node = TrieNode(key: key, value: value, parentNode: self)
        children[key] = node
        return node
    }
}
extension TrieNode: CustomDebugStringConvertible {
    var debugDescription: String {
        let description = String(describing: key)
        if let parent = parentNode?.debugDescription, !parent.isEmpty {
            return parent + "_" + description
        }
        return description
    }
}

class Trie {
    typealias Node = TrieNode<String, Row>

    public func keyValuePairs(toSplit: [String], toNotSplit: [String]) -> [(String, Row)] {
        return keysInSubtrie(rootNode: root, partialKey: "", toSplit: Box(value: toSplit), toNotSplit: Box(value: toNotSplit)).compactMap {
            if let value = $0.1 {
                return ($0.0, value)
            } else {
                return nil
            }
        }
    }
    private let root: Node

    /// Creates an empty trie.
    init() {
        root = Node(key: "")
    }
}

extension Trie {

    /// Inserts words list into the trie.  If the words are already present,
    /// there is no change.
    ///
    /// - Parameter words: the words to be inserted.
    /// - Parameter value: the value that goes with the words list.
    func insert(words: [String], value: Row) {
        guard !words.isEmpty else {
            return
        }
        var currentNode = root
        for aWord in words {
            currentNode.isTerminating = false
            currentNode = currentNode.add(key: aWord, value: nil)
        }
        currentNode.value = value
        print("Added: \(currentNode)")
        if currentNode.children.isEmpty {
            currentNode.isTerminating = true
        }
    }
    /// Returns an array of words in a subtrie of the trie
    ///
    /// - Parameters:
    ///   - rootNode: the root node of the subtrie
    ///   - partialWord: the letters collected by traversing to this node
    /// - Returns: the words in the subtrie with they respective values
    fileprivate func keysInSubtrie(rootNode: Node, partialKey: String, toSplit: Box<[String]>, toNotSplit: Box<[String]>) -> [(String, Row?)] {
        var subtrieWords = [(String, Row?)]()
        var previousKeyPieces = partialKey
        previousKeyPieces.append(rootNode.key)
        if rootNode.value != nil {
            subtrieWords.append((previousKeyPieces, rootNode.value))
        }
        if !rootNode.key.isEmpty && !rootNode.isTerminating {
            if rootNode.children.count > 1 {
                if toNotSplit.value.first(where: { $0 == previousKeyPieces }) == nil {
                    previousKeyPieces.append(".")
                } else {
                    previousKeyPieces.append("_")
                }
            } else {
                if toSplit.value.first(where: { $0 == previousKeyPieces }) != nil {
                    previousKeyPieces.append(".")
                } else {
                    previousKeyPieces.append("_")
                }
            }
        }
        for childNode in rootNode.children.values {
            let childWords = keysInSubtrie(rootNode: childNode, partialKey: previousKeyPieces, toSplit: toSplit, toNotSplit: toNotSplit)
            subtrieWords += childWords
        }
        return subtrieWords
    }
}

private class Box<T> {
    var value: T
    init(value: T) {
        self.value = value
    }
}
