import Foundation

extension SHACLShapesGraphLoader {
    func resolveInValues(
        _ valueObjects: Set<String>,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> Set<String> {
        var resolved: Set<String> = []
        for object in valueObjects {
            resolved.formUnion(resolveRDFListOrDirectValue(object, triplesBySubject: triplesBySubject))
        }
        return resolved
    }

    func resolveShapeReferenceIRIs(
        _ valueObjects: Set<String>,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> Set<String> {
        var resolved: Set<String> = []
        for object in valueObjects {
            resolved.formUnion(resolveRDFListOrDirectValue(object, triplesBySubject: triplesBySubject))
        }
        return resolved
    }

    func resolveStaticRDFListMembers(
        _ headOrValue: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> [String]? {
        guard rdfListLength(headOrValue, triplesBySubject: triplesBySubject) != nil else {
            return nil
        }
        return resolveRDFListOrDirectValueOrdered(headOrValue, triplesBySubject: triplesBySubject)
    }

    private func resolveRDFListOrDirectValue(
        _ headOrValue: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> Set<String> {
        if headOrValue == SHACLIRIs.rdfNil {
            return []
        }

        guard let firstRestTriples = triplesBySubject[headOrValue],
              firstRestTriples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst }) else {
            return [headOrValue]
        }

        var values: Set<String> = []
        var current = headOrValue
        var visited: Set<String> = []

        while current != SHACLIRIs.rdfNil && !visited.contains(current) {
            visited.insert(current)
            guard let triples = triplesBySubject[current] else {
                break
            }
            guard let first = triples.first(where: { $0.predicate == SHACLIRIs.rdfFirst }),
                  let rest = triples.first(where: { $0.predicate == SHACLIRIs.rdfRest }) else {
                break
            }
            values.insert(first.object)
            current = rest.object
        }

        return values
    }

    func resolveRDFListOrDirectValueOrdered(
        _ headOrValue: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> [String] {
        if headOrValue == SHACLIRIs.rdfNil {
            return []
        }

        guard let firstRestTriples = triplesBySubject[headOrValue],
              firstRestTriples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst }) else {
            return [headOrValue]
        }

        var values: [String] = []
        var current = headOrValue
        var visited: Set<String> = []

        while current != SHACLIRIs.rdfNil && !visited.contains(current) {
            visited.insert(current)
            guard let triples = triplesBySubject[current] else {
                break
            }
            guard let first = triples.first(where: { $0.predicate == SHACLIRIs.rdfFirst }),
                  let rest = triples.first(where: { $0.predicate == SHACLIRIs.rdfRest }) else {
                break
            }
            values.append(first.object)
            current = rest.object
        }

        return values
    }

    func rdfListLength(
        _ headOrValue: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> Int? {
        if headOrValue == SHACLIRIs.rdfNil {
            return 0
        }

        guard let firstRestTriples = triplesBySubject[headOrValue],
              firstRestTriples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst }) else {
            return nil
        }

        var current = headOrValue
        var visited: Set<String> = []
        var count = 0

        while current != SHACLIRIs.rdfNil && !visited.contains(current) {
            visited.insert(current)
            guard let triples = triplesBySubject[current],
                  triples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst }),
                  let rest = triples.first(where: { $0.predicate == SHACLIRIs.rdfRest }) else {
                break
            }
            count += 1
            current = rest.object
        }

        return count
    }

    func hasRDFListStructure(
        _ term: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> Bool {
        guard let triples = triplesBySubject[term] else {
            return false
        }
        return triples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst })
    }

    func resolveRDFListTermsOrdered(
        _ headOrValue: String,
        triplesBySubject: [String: [SHACLTriple]]
    ) -> [String] {
        if headOrValue == SHACLIRIs.rdfNil {
            return []
        }

        guard hasRDFListStructure(headOrValue, triplesBySubject: triplesBySubject) else {
            return [headOrValue]
        }

        var values: [String] = []
        var current = headOrValue
        var visited: Set<String> = []

        while current != SHACLIRIs.rdfNil && !visited.contains(current) {
            visited.insert(current)
            guard let triples = triplesBySubject[current],
                  let first = triples.first(where: { $0.predicate == SHACLIRIs.rdfFirst }),
                  let rest = triples.first(where: { $0.predicate == SHACLIRIs.rdfRest }) else {
                break
            }
            values.append(first.object)
            current = rest.object
        }

        return values
    }
}
