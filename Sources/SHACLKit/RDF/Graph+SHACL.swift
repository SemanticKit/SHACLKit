import IRIKit
import RDFCore
import RDFFormats
import RDF
import struct RDFCore.Literal

/// Reading a graph the way SHACL reads data and shapes graphs.
extension Graph {
    /// The objects of the triples whose subject is `node` and whose
    /// predicate is `predicate`, in graph order.
    func objects(of node: ObjectTerm, _ predicate: IRI) -> [ObjectTerm] {
        guard let subject = node.subject else { return [] }
        return compactMap { $0.subject == subject && $0.predicate == predicate ? $0.object : nil }
    }

    /// The first object of `node` for `predicate`.
    func object(of node: ObjectTerm, _ predicate: IRI) -> ObjectTerm? {
        guard let subject = node.subject else { return nil }
        return first { $0.subject == subject && $0.predicate == predicate }?.object
    }

    /// The subjects of the triples whose predicate is `predicate` and whose
    /// object is `object`, in graph order.
    func subjects(_ predicate: IRI, _ object: ObjectTerm) -> [ObjectTerm] {
        compactMap { $0.predicate == predicate && $0.object == object ? $0.subject.object : nil }
    }

    /// The triples whose subject is `node`.
    func triples(of node: ObjectTerm) -> [Element] {
        guard let subject = node.subject else { return [] }
        return filter { $0.subject == subject }
    }

    /// The nodes of the graph: "the set of subjects and objects of the
    /// asserted triples of the graph" (RDF 1.2 Concepts §3.1), in their
    /// first order.
    var nodes: [ObjectTerm] {
        flatMap { [$0.subject.object, $0.object] }.uniqued()
    }

    /// Whether `node` is `rdf:nil` or the subject of an `rdf:first` triple:
    /// the head of an RDF collection (RDF 1.2 Schema §5.2).
    func isList(_ node: ObjectTerm) -> Bool {
        node == .iri(IRIKit.IRI(of: RDF.nil)!) || object(of: node, IRIKit.IRI(of: RDF.first.self)!) != nil
    }

    /// The members of the SHACL list whose head is `node` (SHACL 1.2 Core
    /// §1.4 SHACL Lists: "a SHACL list ... is an IRI or a blank node that is
    /// either `rdf:nil` ... or has exactly one value for the property
    /// `rdf:first` and exactly one value for the property `rdf:rest` that is
    /// also a SHACL list"), or `nil` when `node` is not one.
    func list(_ node: ObjectTerm) -> [ObjectTerm]? {
        let nilList = ObjectTerm.iri(IRIKit.IRI(of: RDF.nil)!)
        var members: [ObjectTerm] = []
        var current = node
        var visited: Set<ObjectTerm> = []
        while current != nilList {
            guard visited.insert(current).inserted else { return nil }
            let first = objects(of: current, IRIKit.IRI(of: RDF.first.self)!)
            let rest = objects(of: current, IRIKit.IRI(of: RDF.rest.self)!)
            guard first.count == 1, rest.count == 1 else { return nil }
            members.append(first[0])
            current = rest[0]
        }
        return members
    }

    /// The members of the list at `node`, or `node` itself when it is not
    /// a list: how SHACL reads a parameter whose value may be either.
    func listOrValue(_ node: ObjectTerm) -> [ObjectTerm] {
        isList(node) ? list(node) ?? [] : [node]
    }

    /// `cls` and the classes that are `rdfs:subClassOf` it, directly or not.
    func subclasses(of cls: ObjectTerm) -> Set<ObjectTerm> {
        let subClassOf = IRIKit.IRI(of: RDF.subClassOf.self)!
        var closure: Set<ObjectTerm> = [cls]
        var pending = [cls]
        while let next = pending.popLast() {
            for subclass in subjects(subClassOf, next) where closure.insert(subclass).inserted {
                pending.append(subclass)
            }
        }
        return closure
    }

    /// Whether `node` is a SHACL instance of `cls`: SHACL 1.2 Core §1.4, "A
    /// node n in an RDF graph G is a SHACL instance of a SHACL class C in G
    /// if one of the SHACL types of n in G is C", where the SHACL types are
    /// the `rdf:type` values and their `rdfs:subClassOf` superclasses.
    func isInstance(_ node: ObjectTerm, of cls: ObjectTerm) -> Bool {
        let classes = subclasses(of: cls)
        return objects(of: node, IRIKit.IRI(of: RDF.type.self)!).contains(where: classes.contains)
    }

    /// The SHACL instances of `cls`, in graph order.
    func instances(of cls: ObjectTerm) -> [ObjectTerm] {
        let classes = subclasses(of: cls)
        let type = IRIKit.IRI(of: RDF.type.self)!
        return compactMap { $0.predicate == type && classes.contains($0.object) ? $0.subject.object : nil }.uniqued()
    }

    /// The reifiers of the triple `subject predicate object`: the nodes `r`
    /// with `r rdf:reifies <<( subject predicate object )>>` (RDF 1.2
    /// Concepts §3.7 Reification).
    func reifiers(of subject: ObjectTerm, _ predicate: IRI, _ object: ObjectTerm) -> [ObjectTerm] {
        guard let subject = subject.subject else { return [] }
        let triple = ObjectTerm.tripleTerm(Element(subject: subject, predicate: predicate, object: object))
        return subjects(IRIKit.IRI(of: RDF.reifies.self)!, triple)
    }
}
