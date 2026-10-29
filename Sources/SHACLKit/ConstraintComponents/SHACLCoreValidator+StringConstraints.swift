import Foundation

extension SHACLCoreValidator {
    func extractLiteralLexicalForm(_ value: String) -> String? {
        if value.hasPrefix("\"\"\"") {
            let start = value.index(value.startIndex, offsetBy: 3)
            guard let closing = value.range(of: "\"\"\"", range: start..<value.endIndex)?.lowerBound else {
                return nil
            }
            return String(value[start..<closing])
        }
        guard value.hasPrefix("\"") else {
            return nil
        }
        guard let closing = value.dropFirst().firstIndex(of: "\"") else {
            return nil
        }
        let start = value.index(after: value.startIndex)
        return String(value[start..<closing])
    }

    func extractLiteralLanguageTag(_ value: String) -> String? {
        guard value.hasPrefix("\"") else {
            return nil
        }
        guard let closing = value.dropFirst().firstIndex(of: "\"") else {
            return nil
        }
        let next = value.index(after: closing)
        guard next < value.endIndex, value[next] == "@" else {
            return nil
        }
        let start = value.index(after: next)
        let languageTag = String(value[start...]).lowercased()
        return languageTag.isEmpty ? nil : languageTag
    }

    func containsSingleLineDisallowedBreak(_ lexical: String) -> Bool {
        if lexical.contains("\n")
            || lexical.contains("\r")
            || lexical.contains("\u{000B}")
            || lexical.contains("\u{000C}") {
            return true
        }

        let escapedControlSequences = [
            "\\n", "\\r", "\\f",
            "\\u000A", "\\u000a",
            "\\u000B", "\\u000b",
            "\\u000C", "\\u000c",
            "\\u000D", "\\u000d"
        ]
        return escapedControlSequences.contains { sequence in lexical.contains(sequence) }
    }

    func matchesLanguageIn(languageTag: String?, ranges: [String]) -> Bool {
        guard let languageTag else {
            return false
        }
        for range in ranges {
            if languageTag == range || languageTag.hasPrefix(range + "-") {
                return true
            }
        }
        return false
    }
}
