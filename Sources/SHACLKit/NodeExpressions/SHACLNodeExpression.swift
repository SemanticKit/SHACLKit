import IRIKit
import RDFCore
import RDFFormats
import RDF
import struct RDFCore.Literal
import SHACL
import struct RDFCore.Graph
import SHNEX

/// A SHACL 1.2 node expression: an expression in a shapes graph that a
/// validator evaluates, for a focus node, to a list of nodes.
///
/// Expressions are decoded from the shapes graph once, into a tree whose
/// operands are expressions themselves. A constant term is an expression
/// whose output is that term; a SHACL list is one whose output is the
/// outputs of its members, in order.
public indirect enum SHACLNodeExpression: Sendable, Hashable {
    /// No output: a blank node that names no expression.
    case empty
    /// A constant term.
    case constant(ObjectTerm)
    /// `sh:this`: the focus node.
    case focusNode
    /// A SHACL list of expressions.
    case list([SHACLNodeExpression])
    /// `shnex:nodes`: the output of the input expression.
    case nodes(SHACLNodeExpression)
    /// `sh:union`: the outputs of the expressions, without repeats.
    case union([SHACLNodeExpression])
    /// `sh:intersection`: the output of the first expression that every
    /// other expression also outputs.
    case intersection([SHACLNodeExpression])
    /// `shnex:exists`: true when the input has output.
    case exists(SHACLNodeExpression)
    /// `shnex:count`: the number of output nodes of the input.
    case count(SHACLNodeExpression)
    /// `shnex:var`: the nodes a variable is bound to.
    case variable(String)
    /// `shnex:distinct`: the input's output without repeats.
    case distinct(SHACLNodeExpression)
    /// `shnex:matchAll`: true when every input node conforms to the shape.
    case matchAll(SHACLNodeExpression, shape: SHACLShape)
    /// `shnex:filterShape`: the input nodes that conform to the shape.
    case filterShape(SHACLNodeExpression, shape: SHACLShape)
    /// `shnex:findFirst`: the first input node that conforms to the shape.
    case findFirst(SHACLNodeExpression, shape: SHACLShape)
    /// `shnex:instancesOf`: the SHACL instances of the class.
    case instancesOf(ObjectTerm)
    /// `shnex:nodesMatching`: the nodes of the data graph that conform to the shape.
    case nodesMatching(SHACLShape)
    /// `shnex:min`: the least numeric output node of the input.
    case min(SHACLNodeExpression)
    /// `shnex:max`: the greatest numeric output node of the input.
    case max(SHACLNodeExpression)
    /// `shnex:sum`: the sum of the numeric output nodes of the input.
    case sum(SHACLNodeExpression)
    /// `shnex:if`, `shnex:then`, `shnex:else`.
    case conditional(if: SHACLNodeExpression, then: SHACLNodeExpression, else: SHACLNodeExpression?)
    /// `shnex:pathValues`: the values of the path from the focus node, or
    /// from each output node of `shnex:focusNode`.
    case pathValues(SHACLPropertyPath, focusNode: SHACLNodeExpression?)
    /// `shnex:concat`: the outputs of the expressions, in order.
    case concat(SHACLNodeExpression)
    /// `shnex:remove`: the input nodes that the second expression does not output.
    case remove(SHACLNodeExpression, SHACLNodeExpression)
    /// `shnex:flatMap`: the outputs of the expression for each input node as focus node.
    case flatMap(SHACLNodeExpression, SHACLNodeExpression)
    /// `shnex:limit`: at most this many of the input nodes.
    case limit(SHACLNodeExpression, Int)
    /// `shnex:offset`: the input nodes after this many.
    case offset(SHACLNodeExpression, Int)
    /// `shnex:orderBy`: the input nodes ordered by the key expression's output.
    case orderBy(SHACLNodeExpression, key: SHACLNodeExpression, descending: Bool)

    /// Decodes the expression whose node is `node`, with the shapes its
    /// shape-expecting parameters name made by `nodes`.
    init(_ node: ObjectTerm, in nodes: SHACLShapesGraph.Nodes) {
        var visiting: Set<ObjectTerm> = []
        self = Self.decode(node, in: nodes, visiting: &visiting)
    }

    /// Whether `node` is more than a constant in `graph`: a SHACL list, or
    /// a node with node expression parameters.
    public static func isExpression(_ node: ObjectTerm, in graph: Graph) -> Bool {
        if node == .iri(IRIKit.IRI(of: SHACL.this)!) { return true }
        if graph.isList(node) { return true }
        let parameters = Self.parameters
        return graph.triples(of: node).contains { parameters.contains($0.predicate) }
    }

    /// The predicates that make a node a node expression.
    private static var parameters: Set<IRI> {
        [
            IRIKit.IRI(of: SHACL.union)!, IRIKit.IRI(of: SHACL.intersection)!,
            IRIKit.IRI(of: SHNEX.intersection)!, IRIKit.IRI(of: SHNEX.nodes)!,
            IRIKit.IRI(of: SHNEX.exists)!, IRIKit.IRI(of: SHNEX.count)!, IRIKit.IRI(of: SHNEX.var)!,
            IRIKit.IRI(of: SHNEX.distinct)!, IRIKit.IRI(of: SHNEX.matchAll)!, IRIKit.IRI(of: SHNEX.filterShape)!,
            IRIKit.IRI(of: SHNEX.instancesOf)!, IRIKit.IRI(of: SHNEX.nodesMatching)!, IRIKit.IRI(of: SHNEX.min)!,
            IRIKit.IRI(of: SHNEX.max)!, IRIKit.IRI(of: SHNEX.sum)!, IRIKit.IRI(of: SHNEX.if)!,
            IRIKit.IRI(of: SHNEX.pathValues)!, IRIKit.IRI(of: SHNEX.concat)!, IRIKit.IRI(of: SHNEX.remove)!,
            IRIKit.IRI(of: SHNEX.flatMap)!, IRIKit.IRI(of: SHNEX.limit)!, IRIKit.IRI(of: SHNEX.offset)!,
            IRIKit.IRI(of: SHNEX.findFirst)!, IRIKit.IRI(of: SHNEX.orderBy)!,
        ]
    }

    /// `shnex:focusNode`, which shnex.ttl declares only as the path of the
    /// `PathValuesExpression-focusNode` parameter.
    private static var focusNodeParameter: IRI {
        SHNEX.`PathValuesExpression-focusNode`.path.compactMap { value -> IRI? in
            if case .individual(let property) = value { return IRIKit.IRI(of: property) }
            return nil
        }[0]
    }

    private static func decode(_ node: ObjectTerm, in nodes: SHACLShapesGraph.Nodes, visiting: inout Set<ObjectTerm>) -> SHACLNodeExpression {
        let graph = nodes.graph
        if node == .iri(IRIKit.IRI(of: SHACL.this)!) { return .focusNode }
        if node.isLiteral { return .constant(node) }
        guard visiting.insert(node).inserted else { return .empty }
        defer { visiting.remove(node) }

        // An empty list is the constant rdf:nil, not an expression.
        if graph.isList(node), node != .iri(IRIKit.IRI(of: RDF.nil)!) {
            return .list((graph.list(node) ?? []).map { decode($0, in: nodes, visiting: &visiting) })
        }
        func operand(_ predicate: IRI) -> SHACLNodeExpression? {
            graph.object(of: node, predicate).map { decode($0, in: nodes, visiting: &visiting) }
        }
        func value(_ predicate: IRI) -> ObjectTerm? {
            graph.object(of: node, predicate)
        }
        func shape(_ predicate: IRI) -> SHACLShape? {
            value(predicate).map(nodes.shape)
        }
        func members(_ predicate: IRI) -> [SHACLNodeExpression]? {
            guard let list = value(predicate) else { return nil }
            return graph.listOrValue(list).map { decode($0, in: nodes, visiting: &visiting) }
        }
        func count(_ predicate: IRI) -> Int? {
            value(predicate)?.literal?.integerValue
        }

        if let members = members(IRIKit.IRI(of: SHACL.union)!) {
            return .union(members)
        }
        if let members = members(IRIKit.IRI(of: SHACL.intersection)!) ?? members(IRIKit.IRI(of: SHNEX.intersection)!) {
            return .intersection(members)
        }
        if let input = operand(IRIKit.IRI(of: SHNEX.nodes)!) {
            if let shape = shape(IRIKit.IRI(of: SHNEX.matchAll)!) { return .matchAll(input, shape: shape) }
            if let shape = shape(IRIKit.IRI(of: SHNEX.filterShape)!) { return .filterShape(input, shape: shape) }
            if let removed = operand(IRIKit.IRI(of: SHNEX.remove)!) { return .remove(input, removed) }
            if let map = operand(IRIKit.IRI(of: SHNEX.flatMap)!) { return .flatMap(input, map) }
            if let limit = count(IRIKit.IRI(of: SHNEX.limit)!) { return .limit(input, limit) }
            if let offset = count(IRIKit.IRI(of: SHNEX.offset)!) { return .offset(input, offset) }
            if let shape = shape(IRIKit.IRI(of: SHNEX.findFirst)!) { return .findFirst(input, shape: shape) }
            if let key = operand(IRIKit.IRI(of: SHNEX.orderBy)!) {
                let descending = value(IRIKit.IRI(of: SHNEX.desc)!)?.literal?.isTrue ?? false
                return .orderBy(input, key: key, descending: descending)
            }
            return .nodes(input)
        }
        if let input = operand(IRIKit.IRI(of: SHNEX.concat)!) { return .concat(input) }
        if let input = operand(IRIKit.IRI(of: SHNEX.exists)!) { return .exists(input) }
        if let input = operand(IRIKit.IRI(of: SHNEX.count)!) { return .count(input) }
        if let name = value(IRIKit.IRI(of: SHNEX.var)!) { return .variable(name.stringValue ?? name.description) }
        if let input = operand(IRIKit.IRI(of: SHNEX.distinct)!) { return .distinct(input) }
        if let cls = value(IRIKit.IRI(of: SHNEX.instancesOf)!) { return .instancesOf(cls) }
        if let shape = shape(IRIKit.IRI(of: SHNEX.nodesMatching)!) { return .nodesMatching(shape) }
        if let input = operand(IRIKit.IRI(of: SHNEX.min)!) { return .min(input) }
        if let input = operand(IRIKit.IRI(of: SHNEX.max)!) { return .max(input) }
        if let input = operand(IRIKit.IRI(of: SHNEX.sum)!) { return .sum(input) }
        if let condition = operand(IRIKit.IRI(of: SHNEX.if)!), let then = operand(IRIKit.IRI(of: SHNEX.then)!) {
            return .conditional(if: condition, then: then, else: operand(IRIKit.IRI(of: SHNEX.else)!))
        }
        if let pathNode = value(IRIKit.IRI(of: SHNEX.pathValues)!), let path = SHACLPropertyPath(pathNode, in: graph) {
            return .pathValues(path, focusNode: operand(Self.focusNodeParameter))
        }
        return node.isBlankNode ? .empty : .constant(node)
    }
}
