import Foundation

/// The SHACL Rules Language test suites a ruleset is checked against.
enum SrlPreflightSuite {
    case syntax
    case wellformed
    case stratification
}

struct SrlRuleClause {
    let head: String
    let body: String
}

/// A preflight check of a SHACL Rules Language document (`.srl`) against the
/// syntax, well-formedness and stratification test suites.
struct SrlRulesetPreflight {
    private let source: String
    private var index: String.Index
    private(set) var declaredPrefixes: Set<String> = []
    private(set) var dataBlocks: [String] = []
    private(set) var rules: [SrlRuleClause] = []

    init(source: String) {
        self.source = source
        self.index = source.startIndex
    }

    mutating func validate(suite: SrlPreflightSuite) -> Bool {
        guard parseTopLevel() else {
            return false
        }

        if !allPrefixedNamesAreDeclared() {
            return false
        }
        if dataBlocks.contains(where: containsVariable) {
            return false
        }
        if rules.contains(where: hasInvalidBlankNodePredicate) {
            return false
        }
        if rules.contains(where: hasUnexpectedBraceInsideBody) {
            return false
        }

        switch suite {
        case .syntax:
            return true
        case .wellformed:
            return validateWellFormedness()
        case .stratification:
            return validateStratification()
        }
    }

    private mutating func parseTopLevel() -> Bool {
        while true {
            skipWhitespaceAndComments()
            if isAtEnd { return true }
            guard let keyword = readKeyword() else { return false }
            switch keyword.uppercased() {
            case "PREFIX":
                guard parsePrefixDirective() else { return false }
            case "BASE":
                guard parseBaseDirective() else { return false }
            case "DATA":
                guard let block = parseBracedBlock() else { return false }
                dataBlocks.append(block)
            case "RULE":
                guard let head = parseBracedBlock() else { return false }
                skipWhitespaceAndComments()
                guard readKeyword()?.uppercased() == "WHERE" else { return false }
                guard let body = parseBracedBlock() else { return false }
                rules.append(SrlRuleClause(head: head, body: body))
            default:
                return false
            }
        }
    }

    private mutating func parsePrefixDirective() -> Bool {
        let line = readLineRemainder()
        guard let match = line.firstMatch(
            of: #/^\s*([A-Za-z_][A-Za-z0-9_\-]*|)\s*:\s*<[^>]+>\s*$/#
        ) else {
            return false
        }
        declaredPrefixes.insert(String(match.1))
        return true
    }

    private mutating func parseBaseDirective() -> Bool {
        let line = readLineRemainder()
        return line.firstMatch(of: #/^\s*<[^>]+>\s*$/#) != nil
    }

    private mutating func parseBracedBlock() -> String? {
        skipWhitespaceAndComments()
        guard peek() == "{" else { return nil }
        let open = index
        _ = advance()
        var depth = 1
        var inString = false
        var stringDelimiter: Character?

        while !isAtEnd {
            guard let ch = advance() else { break }
            if inString {
                if ch == "\\" {
                    _ = advance()
                    continue
                }
                if ch == stringDelimiter {
                    inString = false
                    stringDelimiter = nil
                }
                continue
            }
            if ch == "\"" || ch == "'" {
                inString = true
                stringDelimiter = ch
                continue
            }
            if ch == "{" {
                depth += 1
            } else if ch == "}" {
                depth -= 1
                if depth == 0 {
                    let contentStart = source.index(after: open)
                    let contentEnd = source.index(before: index)
                    return String(source[contentStart..<contentEnd])
                }
            }
        }
        return nil
    }

    private func allPrefixedNamesAreDeclared() -> Bool {
        let prefixesInSource = extractPrefixedNamePrefixes(from: source)
        return prefixesInSource.allSatisfy { declaredPrefixes.contains($0) }
    }

    private func containsVariable(_ text: String) -> Bool {
        text.firstMatch(of: #/\?[A-Za-z_][A-Za-z0-9_]*/#) != nil
    }

    private func hasInvalidBlankNodePredicate(_ rule: SrlRuleClause) -> Bool {
        hasBlankNodePredicate(in: rule.head) || hasBlankNodePredicate(in: rule.body)
    }

    private func hasBlankNodePredicate(in text: String) -> Bool {
        text.firstMatch(of: #/(^|[\s\{\.])([^\s\{\}]+)\s+\[\]\s+([^\s\{\}]+)/#) != nil
    }

    private func hasUnexpectedBraceInsideBody(_ rule: SrlRuleClause) -> Bool {
        let body = rule.body
        for (offset, ch) in body.enumerated() where ch == "{" {
            let current = body.index(body.startIndex, offsetBy: offset)
            let next = body.index(after: current)
            if next < body.endIndex, body[next] == "|" {
                continue
            }
            let prefix = String(body[..<current])
            if prefix.uppercased().trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("NOT") {
                continue
            }
            return true
        }
        return false
    }

    private func validateWellFormedness() -> Bool {
        for rule in rules {
            let bodyWithoutNot = removingNotBlocks(from: rule.body)
            let trimmedBody = bodyWithoutNot.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedBody.uppercased().hasPrefix("FILTER") {
                return false
            }

            let bindMatches = bodyWithoutNot.matches(of: #/BIND\s*\([^)]*AS\s*(\?[A-Za-z_][A-Za-z0-9_]*)\s*\)/#)
            var bindTargets: Set<String> = []
            for match in bindMatches {
                let matchRange = match.range
                let prefix = String(bodyWithoutNot[..<matchRange.lowerBound])
                let target = String(match.1)
                if prefix.contains(target) {
                    return false
                }
                bindTargets.insert(target)
            }

            let headVars = Set(rule.head.matches(of: #/\?[A-Za-z_][A-Za-z0-9_]*/#).map { String($0.0) })
            let strippedBody = bodyWithoutNot
                .replacing(#/FILTER\s*\([^)]*\)/#, with: "")
                .replacing(#/BIND\s*\([^)]*\)/#, with: "")
            let bodyVars = Set(strippedBody.matches(of: #/\?[A-Za-z_][A-Za-z0-9_]*/#).map { String($0.0) })
            if !headVars.isSubset(of: bodyVars.union(bindTargets)) {
                return false
            }
        }
        return true
    }

    private func validateStratification() -> Bool {
        guard !rules.isEmpty else {
            return true
        }

        let headPredicates = rules.map { Set(extractPredicateTokens(from: $0.head).filter(isConstantPredicate)) }
        let positivePredicates = rules.map {
            Set(extractPredicateTokens(from: removingNotBlocks(from: $0.body)).filter(isConstantPredicate))
        }
        let negativePredicates = rules.map {
            Set(extractNotBlocks(from: $0.body).flatMap { extractPredicateTokens(from: $0) }.filter(isConstantPredicate))
        }

        var constraints: [(rule: Int, dependsOn: Int, delta: Int)] = []
        for ruleIndex in rules.indices {
            for dependencyIndex in rules.indices where dependencyIndex != ruleIndex {
                if !headPredicates[dependencyIndex].isDisjoint(with: positivePredicates[ruleIndex]) {
                    constraints.append((ruleIndex, dependencyIndex, 0))
                }
                if !headPredicates[dependencyIndex].isDisjoint(with: negativePredicates[ruleIndex]) {
                    constraints.append((ruleIndex, dependencyIndex, 1))
                }
            }
        }

        var strata = Array(repeating: 0, count: rules.count)
        for iteration in 0..<rules.count {
            var updated = false
            for constraint in constraints {
                let required = strata[constraint.dependsOn] + constraint.delta
                if strata[constraint.rule] < required {
                    strata[constraint.rule] = required
                    updated = true
                }
            }
            if !updated {
                return true
            }
            if iteration == rules.count - 1 {
                return false
            }
        }
        return true
    }

    private func extractPredicateTokens(from block: String) -> [String] {
        block.matches(of: #/([^\s\{\}\(\),;]+)\s+([^\s\{\}\(\),;]+)\s+([^\s\{\}\(\),;]+)/#)
            .map { String($0.2) }
    }

    private func isConstantPredicate(_ token: String) -> Bool {
        !token.hasPrefix("?")
    }

    private func extractNotBlocks(from text: String) -> [String] {
        var blocks: [String] = []
        var cursor = text.startIndex
        while cursor < text.endIndex,
              let range = text[cursor...].range(of: "NOT", options: [.caseInsensitive]) {
            var local = range.upperBound
            while local < text.endIndex, text[local].isWhitespace {
                local = text.index(after: local)
            }
            guard local < text.endIndex, text[local] == "{" else {
                cursor = range.upperBound
                continue
            }
            var depth = 0
            var walker = local
            let contentStart = text.index(after: local)
            while walker < text.endIndex {
                let ch = text[walker]
                if ch == "{" {
                    depth += 1
                } else if ch == "}" {
                    depth -= 1
                    if depth == 0 {
                        blocks.append(String(text[contentStart..<walker]))
                        cursor = text.index(after: walker)
                        break
                    }
                }
                walker = text.index(after: walker)
            }
            if walker >= text.endIndex {
                break
            }
        }
        return blocks
    }

    private func removingNotBlocks(from text: String) -> String {
        var output = text
        for block in extractNotBlocks(from: text) {
            output = output.replacingOccurrences(of: "NOT {\(block)}", with: "")
        }
        return output
    }

    private func extractPrefixedNamePrefixes(from text: String) -> Set<String> {
        Set(
            text.matches(of: #/(^|[\s\{\}\(\)\[\];,\.])([A-Za-z_][A-Za-z0-9_\-]*|):[A-Za-z0-9_\-]+/#)
                .map { String($0.2) }
                .filter { $0 != "_" }
        )
    }

    private mutating func skipWhitespaceAndComments() {
        while !isAtEnd {
            guard let ch = peek() else { return }
            if ch.isWhitespace {
                _ = advance()
                continue
            }
            if ch == "#" {
                _ = readLineRemainder()
                continue
            }
            return
        }
    }

    private mutating func readKeyword() -> String? {
        skipWhitespaceAndComments()
        guard let ch = peek(), ch.isLetter else { return nil }
        let start = index
        while let next = peek(), next.isLetter {
            _ = advance()
        }
        return String(source[start..<index])
    }

    private mutating func readLineRemainder() -> String {
        let start = index
        while let ch = peek(), ch != "\n" {
            _ = advance()
        }
        return String(source[start..<index])
    }

    private var isAtEnd: Bool {
        index >= source.endIndex
    }

    private func peek() -> Character? {
        guard index < source.endIndex else { return nil }
        return source[index]
    }

    @discardableResult
    private mutating func advance() -> Character? {
        guard index < source.endIndex else { return nil }
        let ch = source[index]
        index = source.index(after: index)
        return ch
    }
}
