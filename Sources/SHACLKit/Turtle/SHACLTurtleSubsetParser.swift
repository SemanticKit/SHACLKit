import Foundation

struct SHACLTurtleSubsetParser {
    let source: String

    func parseTriples() throws -> [SHACLTriple] {
        let parsed = try extractPrefixesAndBody(from: source)
        let statements = splitStatements(from: parsed.body)

        var triples: [SHACLTriple] = []
        var listCounter = 0
        var blankNodeCounter = 0

        for statement in statements {
            if statement.isEmpty {
                continue
            }
            triples.append(
                contentsOf: try parseStatement(
                    statement,
                    prefixes: parsed.prefixes,
                    listCounter: &listCounter,
                    blankNodeCounter: &blankNodeCounter
                )
            )
        }

        return triples
    }

    private func extractPrefixesAndBody(from source: String) throws -> (prefixes: [String: String], body: String) {
        var prefixes: [String: String] = [:]
        var bodyLines: [String] = []

        for rawLine in source.split(separator: "\n", omittingEmptySubsequences: false) {
            let withoutComments = stripComments(from: String(rawLine))
            let line = withoutComments.trimmingCharacters(in: .whitespacesAndNewlines)

            if line.isEmpty || line.hasPrefix("#") {
                continue
            }

            if line.hasPrefix("@prefix") || line.hasPrefix("PREFIX ") || line.hasPrefix("prefix ") {
                let parsed = try parsePrefixDeclaration(line)
                prefixes[parsed.prefix] = parsed.iri
            } else {
                bodyLines.append(String(rawLine))
            }
        }

        return (prefixes, bodyLines.joined(separator: "\n"))
    }

    private func parsePrefixDeclaration(_ line: String) throws -> (prefix: String, iri: String) {
        let remainder: String
        let requireTrailingDot: Bool

        if line.hasPrefix("@prefix") {
            remainder = String(line.dropFirst("@prefix".count)).trimmingCharacters(in: .whitespacesAndNewlines)
            requireTrailingDot = true
        } else if line.hasPrefix("PREFIX ") {
            remainder = String(line.dropFirst("PREFIX".count)).trimmingCharacters(in: .whitespacesAndNewlines)
            requireTrailingDot = false
        } else if line.hasPrefix("prefix ") {
            remainder = String(line.dropFirst("prefix".count)).trimmingCharacters(in: .whitespacesAndNewlines)
            requireTrailingDot = false
        } else {
            throw SHACLError.invalidPrefixDeclaration(line)
        }

        guard let spaceIndex = remainder.firstIndex(where: { $0.isWhitespace }) else {
            throw SHACLError.invalidPrefixDeclaration(line)
        }

        let rawPrefixToken = String(remainder[..<spaceIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
        var trailing = String(remainder[spaceIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)

        if requireTrailingDot {
            guard trailing.hasSuffix(".") else {
                throw SHACLError.invalidPrefixDeclaration(line)
            }
            trailing = String(trailing.dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard rawPrefixToken.hasSuffix(":") else {
            throw SHACLError.invalidPrefixDeclaration(line)
        }
        let prefixValue = String(rawPrefixToken.dropLast())
        if !prefixValue.isEmpty {
            let validPrefix = prefixValue.range(of: #"^[A-Za-z][A-Za-z0-9_-]*$"#, options: .regularExpression) != nil
            guard validPrefix else {
                throw SHACLError.invalidPrefixDeclaration(line)
            }
        }

        guard trailing.hasPrefix("<"), trailing.hasSuffix(">") else {
            throw SHACLError.invalidPrefixDeclaration(line)
        }
        let iri = String(trailing.dropFirst().dropLast())
        guard !iri.isEmpty else {
            throw SHACLError.invalidPrefixDeclaration(line)
        }

        return (prefixValue, iri)
    }

    private func stripComments(from line: String) -> String {
        var result = ""
        var inIRI = false
        var inString = false
        var escaped = false

        for ch in line {
            if ch == "\"" && !inIRI && !escaped {
                inString.toggle()
            } else if ch == "<" && !inString {
                inIRI = true
            } else if ch == ">" && inIRI {
                inIRI = false
            }

            if ch == "#" && !inIRI && !inString {
                break
            }

            result.append(ch)

            if inString && ch == "\\" && !escaped {
                escaped = true
            } else {
                escaped = false
            }
        }

        return result
    }

    private func splitStatements(from body: String) -> [String] {
        var statements: [String] = []
        var current = ""
        var inIRI = false
        var inString = false
        var inLongString = false
        var escaped = false
        let characters = Array(body)
        var position = 0

        while position < characters.count {
            let ch = characters[position]
            let startsLongQuote =
                position + 2 < characters.count
                && characters[position] == "\""
                && characters[position + 1] == "\""
                && characters[position + 2] == "\""

            if startsLongQuote && !inIRI {
                inLongString.toggle()
                current.append("\"\"\"")
                position += 3
                escaped = false
                continue
            }

            if ch == "#" && !inIRI && !inString && !inLongString {
                while position < characters.count, characters[position] != "\n" {
                    position += 1
                }
                continue
            }

            if ch == "<" && !inString && !inLongString {
                inIRI = true
            } else if ch == ">" && inIRI {
                inIRI = false
            } else if ch == "\"" && !escaped && !inLongString {
                inString.toggle()
            }

            if ch == "." && !inIRI && !inString && !inLongString {
                let previousIsDigit = position > 0 && characters[position - 1].isNumber
                let nextIsDigit = position + 1 < characters.count && characters[position + 1].isNumber
                if previousIsDigit && nextIsDigit {
                    current.append(ch)
                    position += 1
                    continue
                }
                let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    statements.append(trimmed)
                }
                current = ""
            } else {
                current.append(ch)
            }

            if inString && ch == "\\" && !escaped {
                escaped = true
            } else {
                escaped = false
            }
            position += 1
        }

        let tail = current.trimmingCharacters(in: .whitespacesAndNewlines)
        if !tail.isEmpty {
            statements.append(tail)
        }

        return statements
    }
}
