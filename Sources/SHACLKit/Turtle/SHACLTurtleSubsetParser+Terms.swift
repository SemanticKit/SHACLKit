import Foundation

extension SHACLTurtleSubsetParser {
    func resolveTerm(_ token: String, prefixes: [String: String]) throws -> String {
        if token == "a" {
            return SHACLIRIs.rdfType
        }

        if token.hasPrefix("<") && token.hasSuffix(">") {
            return String(token.dropFirst().dropLast())
        }

        if isNumericToken(token) {
            return token
        }

        if token == "true" || token == "false" {
            return "\"\(token)\"^^\(SHACLIRIs.xsdBoolean)"
        }

        if token.hasPrefix("_:") {
            return token
        }

        if token.hasPrefix("\"") {
            if let typedRange = token.range(of: "^^") {
                let literal = String(token[..<typedRange.lowerBound])
                let datatypeToken = String(token[typedRange.upperBound...])
                let datatypeIRI = try resolveIRIReference(datatypeToken, prefixes: prefixes)
                return literal + "^^" + datatypeIRI
            }
            return token
        }

        return try resolveIRIReference(token, prefixes: prefixes)
    }

    private func resolveIRIReference(_ token: String, prefixes: [String: String]) throws -> String {
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

    private func isNumericToken(_ token: String) -> Bool {
        token.range(of: #"^-?\d+(\.\d+)?$"#, options: .regularExpression) != nil
    }
}
