import Foundation
import RDFCore
import RDFKit

extension SHACLNodeExpression {
    /// The output of the expression for `focusNode` over `dataGraph`, with
    /// `variables` in scope for `shnex:var`.
    ///
    /// Expressions that test shapes (`shnex:filterShape`, `shnex:matchAll`,
    /// `shnex:findFirst`, `shnex:nodesMatching`) validate against the shapes
    /// of `shapesGraph`.
    public func evaluate(
        focusNode: ObjectTerm?,
        dataGraph: Graph,
        shapesGraph: SHACLShapesGraph,
        variables: [String: [ObjectTerm]] = [:]
    ) -> [ObjectTerm] {
        let validation = Validation(dataGraph: dataGraph, shapesGraph: shapesGraph)
        return evaluate(focusNode: focusNode, variables: variables, in: validation)
    }

    /// Whether the output is exactly the `xsd:boolean` value true, which is
    /// how a constraint or condition expression holds.
    static func isTrue(_ output: [ObjectTerm]) -> Bool {
        output.count == 1 && output[0].literal?.isTrue == true
    }

    func evaluate(focusNode: ObjectTerm?, variables: [String: [ObjectTerm]] = [:], in validation: Validation) -> [ObjectTerm] {
        func run(_ expression: SHACLNodeExpression, focus: ObjectTerm? = focusNode) -> [ObjectTerm] {
            expression.evaluate(focusNode: focus, variables: variables, in: validation)
        }
        func conforming(_ nodes: [ObjectTerm], _ shape: ObjectTerm) -> [ObjectTerm] {
            nodes.filter { validation.conforms($0, to: shape) }
        }

        switch self {
        case .empty:
            return []
        case .constant(let term):
            return [term]
        case .focusNode:
            return focusNode.map { [$0] } ?? []
        case .list(let members):
            return members.flatMap { run($0) }
        case .nodes(let input), .concat(let input):
            return run(input)
        case .union(let members):
            return members.flatMap { run($0) }.uniqued()
        case .intersection(let members):
            guard let first = members.first else { return [] }
            let others = members.dropFirst().map { Set(run($0)) }
            return run(first).uniqued().filter { node in others.allSatisfy { $0.contains(node) } }
        case .exists(let input):
            return [.literal(Literal(!run(input).isEmpty))]
        case .count(let input):
            return [.literal(Literal(run(input).count))]
        case .variable(let name):
            if let bound = variables[name] { return bound }
            if name == "focusNode", let focusNode { return [focusNode] }
            return []
        case .distinct(let input):
            return run(input).uniqued()
        case .matchAll(let input, let shape):
            let nodes = run(input)
            return [.literal(Literal(conforming(nodes, shape).count == nodes.count))]
        case .filterShape(let input, let shape):
            return conforming(run(input).uniqued(), shape)
        case .findFirst(let input, let shape):
            return run(input).first { validation.conforms($0, to: shape) }.map { [$0] } ?? []
        case .instancesOf(let cls):
            return validation.dataGraph.instances(of: cls).sorted()
        case .nodesMatching(let shape):
            return conforming(validation.dataGraph.nodes, shape).sorted()
        case .min(let input):
            return Self.extreme(of: run(input), greatest: false).map { [$0] } ?? []
        case .max(let input):
            return Self.extreme(of: run(input), greatest: true).map { [$0] } ?? []
        case .sum(let input):
            return [.literal(Self.sum(of: run(input)))]
        case .conditional(let condition, let then, let otherwise):
            if Self.isTrue(run(condition)) { return run(then) }
            return otherwise.map { run($0) } ?? []
        case .pathValues(let path, let start):
            let starts = start.map { run($0) } ?? focusNode.map { [$0] } ?? []
            return starts.flatMap { path.values(from: $0, in: validation.dataGraph) }.uniqued().sorted()
        case .remove(let input, let removed):
            let removedNodes = Set(run(removed))
            return run(input).filter { !removedNodes.contains($0) }
        case .flatMap(let input, let map):
            return run(input).flatMap { run(map, focus: $0) }
        case .limit(let input, let count):
            return Array(run(input).prefix(Swift.max(0, count)))
        case .offset(let input, let count):
            return Array(run(input).dropFirst(Swift.max(0, count)))
        case .orderBy(let input, let key, let descending):
            let keyed = run(input).map { node in (node: node, key: run(key, focus: node).sorted().first) }
            return keyed.sorted { lhs, rhs in
                let order = Self.order(lhs.key, rhs.key) ?? Self.order(lhs.node, rhs.node) ?? .orderedSame
                return descending ? order == .orderedDescending : order == .orderedAscending
            }.map(\.node)
        }
    }

    /// The numeric node with the least or greatest value.
    private static func extreme(of nodes: [ObjectTerm], greatest: Bool) -> ObjectTerm? {
        var chosen: (node: ObjectTerm, value: Double)?
        for node in nodes {
            guard let value = node.literal?.numericValue else { continue }
            if let current = chosen, greatest ? value <= current.value : value >= current.value { continue }
            chosen = (node, value)
        }
        return chosen?.node
    }

    /// The sum of the numeric nodes: an `xsd:integer` when every addend is
    /// an integer, otherwise an `xsd:decimal`.
    private static func sum(of nodes: [ObjectTerm]) -> Literal {
        let addends = nodes.compactMap(\.literal).filter { $0.numericValue != nil }
        let total = addends.reduce(0) { $0 + ($1.numericValue ?? 0) }
        if addends.allSatisfy(\.isInteger), total.rounded() == total {
            return Literal(Int(total))
        }
        var lexical = total.rounded() == total ? "\(Int(total)).0" : String(total)
        if lexical.contains("."), !lexical.hasSuffix(".0") {
            while lexical.last == "0" { lexical.removeLast() }
        }
        return try! Literal(lexical, datatype: XSD.decimal.metadata.id)
    }

    /// Orders two keys: numbers by value, other terms by their string.
    private static func order(_ lhs: ObjectTerm?, _ rhs: ObjectTerm?) -> ComparisonResult? {
        guard let lhs, let rhs else {
            if lhs == nil, rhs == nil { return nil }
            return lhs == nil ? .orderedAscending : .orderedDescending
        }
        if let comparison = lhs.literal.flatMap({ left in rhs.literal.flatMap { left.compare(to: $0) } }),
           comparison != .orderedSame {
            return comparison
        }
        let left = lhs.stringValue ?? lhs.description
        let right = rhs.stringValue ?? rhs.description
        if left == right { return nil }
        return left < right ? .orderedAscending : .orderedDescending
    }
}
