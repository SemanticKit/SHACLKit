import Foundation
import IRIKit
import RDFCore
import SHACL
import struct RDFCore.Literal
import struct RDFCore.Graph

extension SHACLConstraint {
    /// The results of the constraint for `focusNode` and its value nodes
    /// (SHACL 1.2 Core §4), as a constraint of `shape`.
    func results(
        of shape: SHACLShape,
        focusNode: ObjectTerm,
        valueNodes: [ObjectTerm],
        depth: Int,
        in validation: Validation
    ) throws -> [SHACLValidationResult] {
        let dataGraph = validation.dataGraph
        func result(
            _ value: ObjectTerm?,
            _ message: @autoclosure () -> String,
            component: (any SHACL.ConstraintComponent)? = nil,
            path: SHACLPropertyPath? = shape.path,
            sourceConstraint: ObjectTerm? = nil,
            details: [SHACLValidationResult] = []
        ) -> SHACLValidationResult {
            SHACLValidationResult(
                severity: shape.severity,
                sourceShape: shape,
                focusNode: focusNode,
                resultPath: path,
                value: value,
                sourceConstraintComponent: component ?? self.component,
                sourceConstraint: sourceConstraint,
                message: shape.messages.first?.lexicalForm ?? message(),
                details: details
            )
        }
        func each(_ failing: (ObjectTerm) throws -> String?) rethrows -> [SHACLValidationResult] {
            try valueNodes.compactMap { value in try failing(value).map { result(value, $0) } }
        }
        func conforms(_ node: ObjectTerm, _ shape: SHACLShape) throws -> Bool {
            try validation.conforms(node, to: shape, depth: depth)
        }

        switch self {
        case .class(let cls):
            return each { dataGraph.isInstance($0, of: cls) ? nil : "Value \($0) is not an instance of \(cls)" }

        case .datatype(let datatypes):
            return each { value in
                datatypes.contains { value.literal?.isWellFormed(as: $0) == true }
                    ? nil : "Value \(value) is not a well-formed literal of datatype \(datatypes.map { "<\($0)>" }.joined(separator: " or "))"
            }

        case .nodeKind(let kinds):
            return each { value in
                kinds.contains { $0.admits(value) }
                    ? nil : "Value \(value) does not have node kind \(kinds.compactMap { $0.iri.map { "<\($0)>" } }.joined(separator: " or "))"
            }

        case .minCount(let minimum):
            return valueNodes.count < minimum ? [result(nil, "Fewer than \(minimum) values: \(valueNodes.count)")] : []

        case .maxCount(let maximum):
            return valueNodes.count > maximum ? [result(nil, "More than \(maximum) values: \(valueNodes.count)")] : []

        case .minExclusive(let bound):
            return each { Self.compare($0, bound) == .orderedDescending ? nil : "Value \($0) is not greater than \(bound)" }
        case .minInclusive(let bound):
            return each { [.orderedDescending, .orderedSame].contains(Self.compare($0, bound)) ? nil : "Value \($0) is less than \(bound) or not comparable with it" }
        case .maxExclusive(let bound):
            return each { Self.compare($0, bound) == .orderedAscending ? nil : "Value \($0) is not less than \(bound)" }
        case .maxInclusive(let bound):
            return each { [.orderedAscending, .orderedSame].contains(Self.compare($0, bound)) ? nil : "Value \($0) is greater than \(bound) or not comparable with it" }

        case .minLength(let minimum):
            return each { value in
                guard let string = value.stringValue else { return "Value \(value) has no string to measure" }
                return string.unicodeScalars.count < minimum ? "Value \(value) is shorter than \(minimum) characters" : nil
            }
        case .maxLength(let maximum):
            return each { value in
                guard let string = value.stringValue else { return "Value \(value) has no string to measure" }
                return string.unicodeScalars.count > maximum ? "Value \(value) is longer than \(maximum) characters" : nil
            }

        case .pattern(let expression):
            return each { value in
                guard let string = value.stringValue else { return "Value \(value) has no string to match" }
                let range = NSRange(string.startIndex..., in: string)
                return expression.firstMatch(in: string, range: range) == nil ? "Value \(value) does not match \(expression.pattern)" : nil
            }

        case .singleLine:
            let lineBreaks: Set<Unicode.Scalar> = ["\n", "\r", "\u{0B}", "\u{0C}", "\u{85}", "\u{2028}", "\u{2029}"]
            return each { value in
                guard let string = value.stringValue else { return "Value \(value) has no string" }
                return string.unicodeScalars.contains(where: lineBreaks.contains) ? "Value \(value) has a line break" : nil
            }

        case .languageIn(let ranges):
            return each { value in
                guard let tag = value.literal?.languageTag, ranges.contains(where: { Self.languageTag(tag, matches: $0) }) else {
                    return "Value \(value) does not have a language tag in \(ranges)"
                }
                return nil
            }

        case .uniqueLang:
            let tags = valueNodes.compactMap { $0.literal?.languageTag }
            let repeated = Set(tags.filter { tag in tags.count { $0 == tag } > 1 })
            return repeated.sorted().map { result(nil, "Language tag \($0) is used by more than one value") }

        case .equals(let path):
            let values = Set(valueNodes)
            let others = path.values(from: focusNode, in: dataGraph)
            let missing = valueNodes.filter { !others.contains($0) }
            let extra = others.filter { !values.contains($0) }
            return (missing + extra).sorted().map { result($0, "Value \($0) is not a value of both the shape and \(path.sparql)") }

        case .disjoint(let path):
            let others = Set(path.values(from: focusNode, in: dataGraph))
            return each { others.contains($0) ? "Value \($0) is also a value of \(path.sparql)" : nil }

        case .lessThan(let path):
            let others = path.values(from: focusNode, in: dataGraph)
            return each { value in
                others.allSatisfy { Self.compare(value, $0) == .orderedAscending } ? nil : "Value \(value) is not less than every value of \(path.sparql)"
            }
        case .lessThanOrEquals(let path):
            let others = path.values(from: focusNode, in: dataGraph)
            return each { value in
                others.allSatisfy { [.orderedAscending, .orderedSame].contains(Self.compare(value, $0)) }
                    ? nil : "Value \(value) is not less than or equal to every value of \(path.sparql)"
            }

        case .not(let other):
            return try each { try conforms($0, other) ? "Value \($0) conforms to \(other)" : nil }
        case .and(let shapes):
            return try each { value in try shapes.allSatisfy { try conforms(value, $0) } ? nil : "Value \(value) does not conform to every shape of sh:and" }
        case .or(let shapes):
            return try each { value in try shapes.contains { try conforms(value, $0) } ? nil : "Value \(value) does not conform to any shape of sh:or" }
        case .xone(let shapes):
            return try each { value in
                try shapes.count(where: { try conforms(value, $0) }) == 1 ? nil : "Value \(value) does not conform to exactly one shape of sh:xone"
            }

        case .node(let other):
            return try valueNodes.compactMap { value in
                let details = try validation.results(of: other, focusNode: value, depth: depth + 1)
                return details.isEmpty ? nil : result(value, "Value \(value) does not conform to \(other)", details: details)
            }

        case .property(let property):
            return try valueNodes.flatMap { try validation.results(of: property, focusNode: $0, depth: depth + 1) }

        case .qualifiedValueShape(let qualified, let minimum, let maximum, let siblings):
            let count = try valueNodes.count { value in
                try conforms(value, qualified) && siblings.allSatisfy { try !conforms(value, $0) }
            }
            var results: [SHACLValidationResult] = []
            if let minimum, count < minimum {
                results.append(result(nil, "Fewer than \(minimum) values conform to \(qualified): \(count)", component: SHACL.QualifiedMinCountConstraintComponent))
            }
            if let maximum, count > maximum {
                results.append(result(nil, "More than \(maximum) values conform to \(qualified): \(count)", component: SHACL.QualifiedMaxCountConstraintComponent))
            }
            return results

        case .someValue(let other):
            return try valueNodes.contains(where: { try conforms($0, other) }) ? [] : [result(nil, "No value conforms to \(other)")]

        case .closed(let permitted):
            return valueNodes.flatMap { value in
                dataGraph.triples(of: value).filter { !permitted.contains($0.predicate) }.map { triple in
                    result(triple.object, "Predicate <\(triple.predicate)> is not permitted by the closed shape", path: .predicate(triple.predicate))
                }
            }

        case .hasValue(let required):
            return valueNodes.contains(required) ? [] : [result(nil, "Missing the value \(required)")]

        case .in(let allowed):
            return each { allowed.contains($0) ? nil : "Value \($0) is not in \(allowed)" }

        case .expression(let expression, let node):
            return try valueNodes.compactMap { value in
                SHACLNodeExpression.isTrue(try expression.evaluate(focusNode: value, in: validation))
                    ? nil : result(value, "The expression does not give true for \(value)", sourceConstraint: node)
            }

        case .nodeByExpression(let expression):
            let shapes = try expression.evaluate(focusNode: focusNode, in: validation)
            return try valueNodes.compactMap { value in
                for other in shapes where try !validation.conforms(value, toShapeNamed: other, depth: depth) {
                    return result(value, "Value \(value) does not conform to \(other)", sourceConstraint: other)
                }
                return nil
            }

        case .reifierShape(let reifierShape, let required):
            guard let predicate = shape.path?.predicate else { return [] }
            return try valueNodes.compactMap { value in
                let reifiers = dataGraph.reifiers(of: focusNode, predicate, value)
                if required, reifiers.isEmpty {
                    return result(value, "The triple with value \(value) has no reifier")
                }
                if let reifierShape {
                    for reifier in reifiers where try !conforms(reifier, reifierShape) {
                        return result(value, "Reifier \(reifier) does not conform to \(reifierShape)")
                    }
                }
                return nil
            }

        case .memberShape(let member):
            return try valueNodes.compactMap { value in
                guard let members = dataGraph.list(value) else { return result(value, "Value \(value) is not a SHACL list") }
                let details = try members.flatMap { try validation.results(of: member, focusNode: $0, depth: depth + 1) }
                return details.isEmpty ? nil : result(value, "A member of \(value) does not conform to \(member)", details: details)
            }
        case .minListLength(let minimum):
            return each { value in
                guard let members = dataGraph.list(value) else { return "Value \(value) is not a SHACL list" }
                return members.count < minimum ? "List \(value) has fewer than \(minimum) members" : nil
            }
        case .maxListLength(let maximum):
            return each { value in
                guard let members = dataGraph.list(value) else { return "Value \(value) is not a SHACL list" }
                return members.count > maximum ? "List \(value) has more than \(maximum) members" : nil
            }
        case .uniqueMembers:
            return each { value in
                guard let members = dataGraph.list(value) else { return "Value \(value) is not a SHACL list" }
                return Set(members).count < members.count ? "List \(value) has repeated members" : nil
            }

        case .sparql(let query):
            func sparqlResult(_ value: ObjectTerm?, path: SHACLPropertyPath?, _ message: String) -> SHACLValidationResult {
                result(value, query.message ?? message, path: path, sourceConstraint: query.node)
            }
            var results: [SHACLValidationResult] = []
            if query.ask != nil {
                for value in valueNodes where try !query.holds(focusNode: focusNode, value: value, path: shape.path, in: validation) {
                    results.append(sparqlResult(value, path: shape.path, "SPARQL ASK constraint does not hold for \(value)"))
                }
            }
            if query.select != nil {
                for solution in try query.select(focusNode: focusNode, path: shape.path, in: validation) {
                    let value = solution["value"] ?? (shape.isPropertyShape ? nil : focusNode)
                    let path = solution["path"]?.iri.map(SHACLPropertyPath.predicate) ?? shape.path
                    results.append(sparqlResult(value, path: path, "SPARQL SELECT constraint has a solution for \(value.map(\.description) ?? "\(focusNode)")"))
                }
            }
            return results
        }
    }

    /// How a value node compares with a bound (SHACL 1.2 Core §4.3, with
    /// SPARQL's `<` operator): `nil` when they are not comparable.
    private static func compare(_ value: ObjectTerm, _ bound: ObjectTerm) -> ComparisonResult? {
        guard let value = value.literal, let bound = bound.literal else { return nil }
        return value.compare(to: bound)
    }

    private static func compare(_ value: ObjectTerm, _ bound: Literal) -> ComparisonResult? {
        compare(value, .literal(bound))
    }

    /// SPARQL's `langMatches` basic filtering (RFC 4647 §3.3.1), as
    /// `sh:languageIn` matches a tag against a range (§4.4.4).
    private static func languageTag(_ tag: String, matches range: String) -> Bool {
        let tag = tag.lowercased()
        if range == "*" { return !tag.isEmpty }
        return tag == range || tag.hasPrefix(range + "-")
    }
}
