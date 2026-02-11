import Foundation

public enum SHACLSeverity: String, Sendable, Codable {
    case violation
    case warning
    case info
}

public enum SHACLShapeKind: String, Sendable, Codable {
    case nodeShape
    case propertyShape
}

public enum SHACLTargetSelector: Sendable, Hashable {
    case targetClass(String)
    case targetNode(String)
    case targetSubjectsOf(String)
    case targetObjectsOf(String)
}

public struct SHACLShapeDefinition: Sendable, Hashable {
    public let shapeIRI: String
    public let kind: SHACLShapeKind
    public let targets: [SHACLTargetSelector]

    public init(shapeIRI: String, kind: SHACLShapeKind, targets: [SHACLTargetSelector]) {
        self.shapeIRI = shapeIRI
        self.kind = kind
        self.targets = targets
    }
}

public struct SHACLShapesGraph: Sendable, Equatable {
    public let shapes: [SHACLShapeDefinition]

    public init(shapes: [SHACLShapeDefinition]) {
        self.shapes = shapes
    }
}

public struct SHACLValidationResult: Sendable, Equatable {
    public let conforms: Bool
    public let message: String

    public init(conforms: Bool, message: String) {
        self.conforms = conforms
        self.message = message
    }
}

public protocol SHACLShapesGraphLoading: Sendable {
    func load(from data: Data) throws -> SHACLShapesGraph
}

public protocol SHACLValidator: Sendable {
    func validate(dataGraph: Data, shapesGraph: Data) throws -> SHACLValidationResult
}

public enum SHACLError: Error, LocalizedError {
    case invalidUTF8
    case invalidPrefixDeclaration(String)
    case unknownPrefix(String)
    case invalidStatement(String)
    case unsupportedTerm(String)
    case notImplemented(String)

    public var errorDescription: String? {
        switch self {
        case .invalidUTF8:
            return "Invalid UTF-8 input."
        case .invalidPrefixDeclaration(let line):
            return "Invalid @prefix declaration: \(line)"
        case .unknownPrefix(let prefix):
            return "Unknown prefix: \(prefix)"
        case .invalidStatement(let statement):
            return "Invalid statement: \(statement)"
        case .unsupportedTerm(let term):
            return "Unsupported RDF term in SHACLKit Turtle subset parser: \(term)"
        case .notImplemented(let detail):
            return "SHACL feature not implemented: \(detail)"
        }
    }
}

public struct SHACLShapesGraphLoader: SHACLShapesGraphLoading {
    public init() {}

    public func load(from data: Data) throws -> SHACLShapesGraph {
        guard let source = String(data: data, encoding: .utf8) else {
            throw SHACLError.invalidUTF8
        }

        let parser = SHACLTurtleSubsetParser(source: source)
        let triples = try parser.parseTriples()

        struct PartialShape {
            var kind: SHACLShapeKind?
            var targets: Set<SHACLTargetSelector> = []
        }

        var shapes: [String: PartialShape] = [:]

        for triple in triples {
            let subject = triple.subject
            let predicate = triple.predicate
            let object = triple.object

            var current = shapes[subject] ?? PartialShape()

            if predicate == SHACLIRIs.rdfType {
                if object == SHACLIRIs.nodeShape {
                    current.kind = .nodeShape
                } else if object == SHACLIRIs.propertyShape {
                    current.kind = .propertyShape
                }
            } else if predicate == SHACLIRIs.targetClass {
                current.targets.insert(.targetClass(object))
            } else if predicate == SHACLIRIs.targetNode {
                current.targets.insert(.targetNode(object))
            } else if predicate == SHACLIRIs.targetSubjectsOf {
                current.targets.insert(.targetSubjectsOf(object))
            } else if predicate == SHACLIRIs.targetObjectsOf {
                current.targets.insert(.targetObjectsOf(object))
            }

            shapes[subject] = current
        }

        let definitions = shapes.compactMap { shapeIRI, partial -> SHACLShapeDefinition? in
            guard let kind = partial.kind else {
                return nil
            }
            return SHACLShapeDefinition(
                shapeIRI: shapeIRI,
                kind: kind,
                targets: partial.targets.sorted(by: { lhs, rhs in
                    String(describing: lhs) < String(describing: rhs)
                })
            )
        }
        .sorted(by: { $0.shapeIRI < $1.shapeIRI })

        return SHACLShapesGraph(shapes: definitions)
    }
}

public struct SHACLCoreValidator: SHACLValidator {
    private let shapesLoader: any SHACLShapesGraphLoading

    public init(shapesLoader: any SHACLShapesGraphLoading = SHACLShapesGraphLoader()) {
        self.shapesLoader = shapesLoader
    }

    public func validate(dataGraph: Data, shapesGraph: Data) throws -> SHACLValidationResult {
        let parsed = try shapesLoader.load(from: shapesGraph)
        throw SHACLError.notImplemented("Core SHACL validation engine. Parsed \(parsed.shapes.count) shape definitions.")
    }
}

private enum SHACLIRIs {
    static let rdfType = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
    static let nodeShape = "http://www.w3.org/ns/shacl#NodeShape"
    static let propertyShape = "http://www.w3.org/ns/shacl#PropertyShape"
    static let targetClass = "http://www.w3.org/ns/shacl#targetClass"
    static let targetNode = "http://www.w3.org/ns/shacl#targetNode"
    static let targetSubjectsOf = "http://www.w3.org/ns/shacl#targetSubjectsOf"
    static let targetObjectsOf = "http://www.w3.org/ns/shacl#targetObjectsOf"
}

private struct SHACLTriple {
    let subject: String
    let predicate: String
    let object: String
}

private struct SHACLTurtleSubsetParser {
    let source: String

    func parseTriples() throws -> [SHACLTriple] {
        let parsed = try extractPrefixesAndBody(from: source)
        let statements = splitStatements(from: parsed.body)

        var triples: [SHACLTriple] = []

        for statement in statements {
            if statement.isEmpty {
                continue
            }
            triples.append(contentsOf: try parseStatement(statement, prefixes: parsed.prefixes))
        }

        return triples
    }

    private func extractPrefixesAndBody(from source: String) throws -> (prefixes: [String: String], body: String) {
        var prefixes: [String: String] = [:]
        var bodyLines: [String] = []

        for rawLine in source.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = String(rawLine).trimmingCharacters(in: .whitespacesAndNewlines)

            if line.hasPrefix("@prefix") {
                let pattern = #"^@prefix\s+([A-Za-z][A-Za-z0-9_-]*):\s*<([^>]+)>\s*\.\s*$"#
                guard let regex = try? NSRegularExpression(pattern: pattern) else {
                    throw SHACLError.invalidPrefixDeclaration(line)
                }
                let range = NSRange(line.startIndex..<line.endIndex, in: line)
                guard let match = regex.firstMatch(in: line, options: [], range: range),
                      let prefixRange = Range(match.range(at: 1), in: line),
                      let iriRange = Range(match.range(at: 2), in: line) else {
                    throw SHACLError.invalidPrefixDeclaration(line)
                }
                let prefix = String(line[prefixRange])
                let iri = String(line[iriRange])
                prefixes[prefix] = iri
            } else if !line.isEmpty {
                bodyLines.append(String(rawLine))
            }
        }

        return (prefixes, bodyLines.joined(separator: "\n"))
    }

    private func splitStatements(from body: String) -> [String] {
        var statements: [String] = []
        var current = ""
        var inIRI = false
        var inString = false

        for ch in body {
            if ch == "<" && !inString {
                inIRI = true
            } else if ch == ">" && inIRI {
                inIRI = false
            } else if ch == "\"" {
                inString.toggle()
            }

            if ch == "." && !inIRI && !inString {
                let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    statements.append(trimmed)
                }
                current = ""
            } else {
                current.append(ch)
            }
        }

        let tail = current.trimmingCharacters(in: .whitespacesAndNewlines)
        if !tail.isEmpty {
            statements.append(tail)
        }

        return statements
    }

    private func parseStatement(_ statement: String, prefixes: [String: String]) throws -> [SHACLTriple] {
        let tokens = try tokenize(statement)
        guard !tokens.isEmpty else {
            return []
        }

        var index = 0

        func takeToken() -> String? {
            guard index < tokens.count else {
                return nil
            }
            defer { index += 1 }
            return tokens[index]
        }

        guard let subjectToken = takeToken() else {
            throw SHACLError.invalidStatement(statement)
        }
        let subject = try resolveTerm(subjectToken, prefixes: prefixes)

        var triples: [SHACLTriple] = []

        while index < tokens.count {
            guard let predicateToken = takeToken() else {
                throw SHACLError.invalidStatement(statement)
            }

            if predicateToken == ";" {
                continue
            }

            let predicate = try resolveTerm(predicateToken, prefixes: prefixes)

            guard let firstObjectToken = takeToken() else {
                throw SHACLError.invalidStatement(statement)
            }

            if firstObjectToken == ";" || firstObjectToken == "," {
                throw SHACLError.invalidStatement(statement)
            }

            var objects: [String] = [try resolveTerm(firstObjectToken, prefixes: prefixes)]

            while index < tokens.count, tokens[index] == "," {
                _ = takeToken()
                guard let nextObject = takeToken(), nextObject != ";", nextObject != "," else {
                    throw SHACLError.invalidStatement(statement)
                }
                objects.append(try resolveTerm(nextObject, prefixes: prefixes))
            }

            for object in objects {
                triples.append(SHACLTriple(subject: subject, predicate: predicate, object: object))
            }

            if index < tokens.count {
                let separator = tokens[index]
                if separator == ";" {
                    _ = takeToken()
                } else {
                    throw SHACLError.invalidStatement(statement)
                }
            }
        }

        return triples
    }

    private func tokenize(_ statement: String) throws -> [String] {
        var tokens: [String] = []
        var index = statement.startIndex

        while index < statement.endIndex {
            let ch = statement[index]

            if ch.isWhitespace {
                index = statement.index(after: index)
                continue
            }

            if ch == ";" || ch == "," {
                tokens.append(String(ch))
                index = statement.index(after: index)
                continue
            }

            if ch == "<" {
                guard let close = statement[index...].firstIndex(of: ">") else {
                    throw SHACLError.invalidStatement(statement)
                }
                tokens.append(String(statement[index...close]))
                index = statement.index(after: close)
                continue
            }

            if ch == "\"" {
                throw SHACLError.unsupportedTerm(String(statement[index...]))
            }

            var end = index
            while end < statement.endIndex,
                  !statement[end].isWhitespace,
                  statement[end] != ";",
                  statement[end] != "," {
                end = statement.index(after: end)
            }

            tokens.append(String(statement[index..<end]))
            index = end
        }

        return tokens
    }

    private func resolveTerm(_ token: String, prefixes: [String: String]) throws -> String {
        if token == "a" {
            return SHACLIRIs.rdfType
        }

        if token.hasPrefix("<") && token.hasSuffix(">") {
            return String(token.dropFirst().dropLast())
        }

        if let colon = token.firstIndex(of: ":") {
            let prefix = String(token[..<colon])
            let local = String(token[token.index(after: colon)...])

            guard let namespace = prefixes[prefix] else {
                throw SHACLError.unknownPrefix(prefix)
            }
            return namespace + local
        }

        throw SHACLError.unsupportedTerm(token)
    }
}
