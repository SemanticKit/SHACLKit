import Foundation

extension SHACLCoreValidator {
    func evaluateDeferredListExtensionsOnValueNode(
        hostShape: SHACLShapeDefinition,
        rootFocusNode: String,
        pathIRI: String?,
        candidateValueNode: String,
        severity: SHACLSeverity,
        dataGraph: SHACLDataGraph,
        shapesByIRI: [String: SHACLShapeDefinition],
        expressionGraph: SHACLShapesGraph,
        nodeExpressionsByIRI: [String: SHACLNodeExpressionDefinition],
        visited: inout Set<String>
    ) -> [SHACLViolation] {
        let hasMemberShape = hostShape.memberShapeIRI != nil
        let hasUniqueMembers = hostShape.uniqueMembers
        let hasMinListLength = hostShape.minListLength != nil
        let hasMaxListLength = hostShape.maxListLength != nil
        if !hasMemberShape && !hasUniqueMembers && !hasMinListLength && !hasMaxListLength {
            return []
        }

        let triplesBySubject = Dictionary(grouping: dataGraph.triples, by: \.subject)
        guard let members = rdfListMembersStrictInDataGraph(candidateValueNode, triplesBySubject: triplesBySubject) else {
            var violations: [SHACLViolation] = []
            if hasMemberShape {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: hostShape.shapeIRI,
                        focusNode: rootFocusNode,
                        pathIRI: pathIRI,
                        valueNode: candidateValueNode,
                        sourceConstraintIRI: SHACLIRIs.memberShape,
                        message: "memberShape violation: value \(candidateValueNode) is not a well-formed RDF list"
                    )
                )
            }
            if hasUniqueMembers {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: hostShape.shapeIRI,
                        focusNode: rootFocusNode,
                        pathIRI: pathIRI,
                        valueNode: candidateValueNode,
                        sourceConstraintIRI: SHACLIRIs.uniqueMembers,
                        message: "uniqueMembers violation: value \(candidateValueNode) is not a well-formed RDF list"
                    )
                )
            }
            if hasMinListLength {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: hostShape.shapeIRI,
                        focusNode: rootFocusNode,
                        pathIRI: pathIRI,
                        valueNode: candidateValueNode,
                        sourceConstraintIRI: SHACLIRIs.minListLength,
                        message: "minListLength violation: value \(candidateValueNode) is not a well-formed RDF list"
                    )
                )
            }
            if hasMaxListLength {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: hostShape.shapeIRI,
                        focusNode: rootFocusNode,
                        pathIRI: pathIRI,
                        valueNode: candidateValueNode,
                        sourceConstraintIRI: SHACLIRIs.maxListLength,
                        message: "maxListLength violation: value \(candidateValueNode) is not a well-formed RDF list"
                    )
                )
            }
            return violations
        }

        var violations: [SHACLViolation] = []
        if let minListLength = hostShape.minListLength, members.count < minListLength {
            violations.append(
                SHACLViolation(
                    severity: severity,
                    shapeIRI: hostShape.shapeIRI,
                    focusNode: rootFocusNode,
                    pathIRI: pathIRI,
                    valueNode: candidateValueNode,
                    sourceConstraintIRI: SHACLIRIs.minListLength,
                    message: "minListLength violation: expected >= \(minListLength), got \(members.count)"
                )
            )
        }
        if let maxListLength = hostShape.maxListLength, members.count > maxListLength {
            violations.append(
                SHACLViolation(
                    severity: severity,
                    shapeIRI: hostShape.shapeIRI,
                    focusNode: rootFocusNode,
                    pathIRI: pathIRI,
                    valueNode: candidateValueNode,
                    sourceConstraintIRI: SHACLIRIs.maxListLength,
                    message: "maxListLength violation: expected <= \(maxListLength), got \(members.count)"
                )
            )
        }

        if hasUniqueMembers {
            var seen: Set<String> = []
            var hasDuplicate = false
            for member in members {
                let inserted = seen.insert(member).inserted
                if !inserted {
                    hasDuplicate = true
                    break
                }
            }
            if hasDuplicate {
                violations.append(
                    SHACLViolation(
                        severity: severity,
                        shapeIRI: hostShape.shapeIRI,
                        focusNode: rootFocusNode,
                        pathIRI: pathIRI,
                        valueNode: candidateValueNode,
                        sourceConstraintIRI: SHACLIRIs.uniqueMembers,
                        message: "uniqueMembers violation: list contains duplicate members"
                    )
                )
            }
        }

        if let memberShapeIRI = hostShape.memberShapeIRI {
            for member in members {
                var memberVisited: Set<String> = []
                if !conforms(
                    valueNode: member,
                    toNodeShapeIRI: memberShapeIRI,
                    dataGraph: dataGraph,
                    shapesByIRI: shapesByIRI,
                    expressionGraph: expressionGraph,
                    nodeExpressionsByIRI: nodeExpressionsByIRI,
                    depth: 0,
                    visited: &memberVisited
                ) {
                    violations.append(
                        SHACLViolation(
                            severity: severity,
                            shapeIRI: hostShape.shapeIRI,
                            focusNode: rootFocusNode,
                            pathIRI: pathIRI,
                            valueNode: candidateValueNode,
                            sourceConstraintIRI: SHACLIRIs.memberShape,
                            message: "memberShape violation: RDF list member \(member) does not conform to \(memberShapeIRI)"
                        )
                    )
                }
            }
        }

        return violations
    }

    private func rdfListMembersStrictInDataGraph(
        _ term: String,
        triplesBySubject: [String: [SHACLDataTriple]]
    ) -> [String]? {
        if term == SHACLIRIs.rdfNil {
            return []
        }
        guard hasRDFListStructureInDataGraph(term, triplesBySubject: triplesBySubject) else {
            return nil
        }

        var members: [String] = []
        var current = term
        var visited: Set<String> = []
        while current != SHACLIRIs.rdfNil && !visited.contains(current) {
            visited.insert(current)
            guard let triples = triplesBySubject[current],
                  let first = triples.first(where: { $0.predicate == SHACLIRIs.rdfFirst })?.object,
                  let rest = triples.first(where: { $0.predicate == SHACLIRIs.rdfRest })?.object else {
                return nil
            }
            members.append(first)
            current = rest
        }
        return current == SHACLIRIs.rdfNil ? members : nil
    }
}
