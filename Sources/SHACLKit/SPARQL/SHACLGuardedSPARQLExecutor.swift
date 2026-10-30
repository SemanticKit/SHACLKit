import Foundation
import RDFCore

/// An executor that refuses queries outside a policy before handing them to
/// the executor it wraps: queries with a disallowed keyword, queries that
/// rebind a pre-bound variable, `SELECT` queries that do not use `$this`,
/// and queries over a length limit.

public struct SHACLGuardedSPARQLExecutor: SHACLSPARQLExecutor {
    public let wrappedExecutor: any SHACLSPARQLExecutor
    public let disallowedKeywords: [String]
    public let maxQueryLength: Int?

    public init(
        wrapping wrappedExecutor: any SHACLSPARQLExecutor,
        disallowedKeywords: [String] = ["SERVICE", "MINUS", "VALUES", "LOAD", "CLEAR", "DROP", "CREATE", "ADD", "MOVE", "COPY", "INSERT", "DELETE", "WITH"],
        maxQueryLength: Int? = nil
    ) {
        self.wrappedExecutor = wrappedExecutor
        self.disallowedKeywords = disallowedKeywords
        self.maxQueryLength = maxQueryLength
    }

    public func select(
        query: String,
        focusNode: ObjectTerm?,
        dataGraph: Graph,
        shapesGraph: SHACLShapesGraph
    ) throws -> [ObjectTerm] {
        try enforcePolicy(query: query, requirePreboundThisReference: true)
        return try wrappedExecutor.select(query: query, focusNode: focusNode, dataGraph: dataGraph, shapesGraph: shapesGraph)
    }

    public func ask(
        query: String,
        focusNode: ObjectTerm?,
        dataGraph: Graph,
        shapesGraph: SHACLShapesGraph
    ) throws -> Bool {
        try enforcePolicy(query: query, requirePreboundThisReference: false)
        return try wrappedExecutor.ask(query: query, focusNode: focusNode, dataGraph: dataGraph, shapesGraph: shapesGraph)
    }

    private func enforcePolicy(query: String, requirePreboundThisReference: Bool) throws {
        if let maxQueryLength, query.count > maxQueryLength {
            throw SHACLError.sparqlNotExecuted("SPARQL query blocked by guard policy: query length exceeds \(maxQueryLength) characters.")
        }

        let policyQuery = queryWithoutLineComments(queryWithoutStringLiterals(query))

        for keyword in disallowedKeywords where !keyword.isEmpty {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let range = NSRange(policyQuery.startIndex..<policyQuery.endIndex, in: policyQuery)
            if regex.firstMatch(in: policyQuery, options: [], range: range) != nil {
                throw SHACLError.sparqlNotExecuted("SPARQL query blocked by guard policy: contains disallowed keyword \(keyword).")
            }
        }

        let preboundVariables = ["this", "path", "value"]
        let preboundRange = NSRange(policyQuery.startIndex..<policyQuery.endIndex, in: policyQuery)
        for variable in preboundVariables {
            let pattern = #"(?i)\bAS\s+[\?\$]\#(variable)\b"#
            let regex = try NSRegularExpression(pattern: pattern)
            if regex.firstMatch(in: policyQuery, options: [], range: preboundRange) != nil {
                throw SHACLError.sparqlNotExecuted("SPARQL query blocked by guard policy: query attempts to rebind pre-bound ?\(variable).")
            }
        }

        if requirePreboundThisReference {
            let thisReferencePattern = #"(?i)[\?\$]this\b"#
            let thisReferenceRegex = try NSRegularExpression(pattern: thisReferencePattern)
            if thisReferenceRegex.firstMatch(in: policyQuery, options: [], range: preboundRange) == nil {
                throw SHACLError.sparqlNotExecuted("SPARQL query blocked by guard policy: SELECT query does not reference pre-bound ?this.")
            }
        }
    }

    private func queryWithoutStringLiterals(_ query: String) -> String {
        var output = ""
        output.reserveCapacity(query.count)
        var index = query.startIndex

        while index < query.endIndex {
            let ch = query[index]
            if ch == "\"" || ch == "'" {
                let delimiter = ch
                let next = query.index(after: index)
                let next2 = next < query.endIndex ? query.index(after: next) : query.endIndex
                let isTriple = next2 < query.endIndex
                    && query[next] == delimiter
                    && query[next2] == delimiter

                output.append(" ")
                index = isTriple ? query.index(index, offsetBy: 3) : next

                while index < query.endIndex {
                    let current = query[index]
                    if current == "\\" {
                        let escaped = query.index(after: index)
                        index = escaped < query.endIndex ? query.index(after: escaped) : escaped
                        continue
                    }
                    if current == delimiter {
                        if isTriple {
                            let after = query.index(after: index)
                            let after2 = after < query.endIndex ? query.index(after: after) : query.endIndex
                            if after2 < query.endIndex
                                && query[after] == delimiter
                                && query[after2] == delimiter {
                                index = query.index(index, offsetBy: 3)
                                break
                            }
                            index = query.index(after: index)
                            continue
                        }
                        index = query.index(after: index)
                        break
                    }
                    index = query.index(after: index)
                }
                continue
            }

            output.append(ch)
            index = query.index(after: index)
        }

        return output
    }

    private func queryWithoutLineComments(_ query: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: #"(?m)(^|\s)#.*$"#) else {
            return query
        }
        let range = NSRange(query.startIndex..<query.endIndex, in: query)
        return regex.stringByReplacingMatches(in: query, options: [], range: range, withTemplate: "$1")
    }
}
