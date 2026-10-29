import Foundation

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
            var isRDFSClass = false
            var isDeactivated = false
            var severity: SHACLSeverity?
            var targets: Set<SHACLTargetSelector> = []
            var propertyShapeIRIs: Set<String> = []
            var ruleIRIs: Set<String> = []
            var sparqlConstraintIRIs: Set<String> = []
            var sparqlTargetIRIs: Set<String> = []
            var pathIRI: String?
            var expressionIRI: String?
            var classIRI: String?
            var nodeKind: SHACLNodeKindConstraint?
            var nodeKindTerm: String?
            var datatypeIRI: String?
            var minLength: Int?
            var maxLength: Int?
            var singleLine = false
            var minListLength: Int?
            var maxListLength: Int?
            var minInclusive: String?
            var maxInclusive: String?
            var minExclusive: String?
            var maxExclusive: String?
            var pattern: String?
            var hasValue: String?
            var inValues: Set<String> = []
            var languageInValues: Set<String> = []
            var uniqueLang = false
            var uniqueMembers = false
            var equalsIRI: String?
            var disjointIRI: String?
            var lessThanIRI: String?
            var lessThanOrEqualsIRI: String?
            var isClosed = false
            var ignoredPropertyIRIs: Set<String> = []
            var nodeByExpressionIRI: String?
            var nodeShapeReferenceIRI: String?
            var andShapeIRIs: Set<String> = []
            var orShapeIRIs: Set<String> = []
            var xoneShapeIRIs: Set<String> = []
            var notShapeIRI: String?
            var reifierShapeIRI: String?
            var reificationRequired = false
            var memberShapeIRI: String?
            var qualifiedValueShapeIRI: String?
            var qualifiedValueShapesDisjoint = false
            var qualifiedMinCount: Int?
            var qualifiedMaxCount: Int?
            var minCount: Int?
            var maxCount: Int?
        }

        struct PartialNodeExpression {
            var unionMemberObjects: Set<String> = []
            var intersectionMemberObjects: Set<String> = []
            var nodesObjects: Set<String> = []
            var existsObjects: Set<String> = []
            var countObjects: Set<String> = []
            var variableNames: Set<String> = []
            var distinctObjects: Set<String> = []
            var matchAllObjects: Set<String> = []
            var filterShapeObjects: Set<String> = []
            var instancesOfObjects: Set<String> = []
            var nodesMatchingObjects: Set<String> = []
            var minObjects: Set<String> = []
            var maxObjects: Set<String> = []
            var sumObjects: Set<String> = []
            var ifObjects: Set<String> = []
            var thenObjects: Set<String> = []
            var elseObjects: Set<String> = []
            var pathValuesObject: String?
            var pathValuesFocusNodeObject: String?
            var concatObjects: Set<String> = []
            var removeObjects: Set<String> = []
            var flatMapObjects: Set<String> = []
            var limitObjects: Set<String> = []
            var offsetObjects: Set<String> = []
            var findFirstObjects: Set<String> = []
            var orderByObjects: Set<String> = []
            var orderByDescending = false
        }

        struct PartialRule {
            var isTripleRule = false
            var ruleOrder: Double?
            var conditionShapeIRIs: Set<String> = []
            var subjectTerm: String?
            var predicateTerm: String?
            var objectTerm: String?
        }

        struct PartialSPARQL {
            var selectQuery: String?
            var askQuery: String?
            var message: String?
            var prefixesIRIs: Set<String> = []
        }

        var shapes: [String: PartialShape] = [:]
        var nodeExpressions: [String: PartialNodeExpression] = [:]
        var rules: [String: PartialRule] = [:]
        var sparqlDefinitions: [String: PartialSPARQL] = [:]

        for triple in triples {
            let subject = triple.subject
            let predicate = triple.predicate
            let object = triple.object

            if SHACLIRIs.phaseGatedPredicates.contains(predicate) {
                throw SHACLError.notImplemented("Predicate \(predicate) is gated pending later SHACL phases.")
            }

            var current = shapes[subject] ?? PartialShape()

            if predicate == SHACLIRIs.rdfType {
                if object == SHACLIRIs.nodeShape {
                    current.kind = .nodeShape
                } else if object == SHACLIRIs.propertyShape {
                    current.kind = .propertyShape
                } else if object == SHACLIRIs.rdfsClass {
                    current.isRDFSClass = true
                } else if object == SHACLIRIs.shapeClass {
                    current.isRDFSClass = true
                }
                if object == SHACLIRIs.tripleRule {
                    var rule = rules[subject] ?? PartialRule()
                    rule.isTripleRule = true
                    rules[subject] = rule
                }
            } else if predicate == SHACLIRIs.targetClass {
                current.targets.insert(.targetClass(object))
            } else if predicate == SHACLIRIs.targetNode {
                current.targets.insert(.targetNode(object))
            } else if predicate == SHACLIRIs.targetSubjectsOf {
                current.targets.insert(.targetSubjectsOf(object))
            } else if predicate == SHACLIRIs.targetObjectsOf {
                current.targets.insert(.targetObjectsOf(object))
            } else if predicate == SHACLIRIs.targetWhere {
                current.targets.insert(.targetWhere(object))
            } else if predicate == SHACLIRIs.severity {
                current.severity = parseSeverity(object)
            } else if predicate == SHACLIRIs.deactivated {
                current.isDeactivated = isTrueBooleanTerm(object)
            } else if predicate == SHACLIRIs.property {
                current.propertyShapeIRIs.insert(object)
            } else if predicate == SHACLIRIs.rule {
                current.ruleIRIs.insert(object)
            } else if predicate == SHACLIRIs.sparql {
                current.sparqlConstraintIRIs.insert(object)
            } else if predicate == SHACLIRIs.target {
                current.sparqlTargetIRIs.insert(object)
            } else if predicate == SHACLIRIs.path {
                current.pathIRI = object
            } else if predicate == SHACLIRIs.expression {
                current.expressionIRI = object
            } else if predicate == SHACLIRIs.class {
                current.classIRI = object
            } else if predicate == SHACLIRIs.nodeKind {
                current.nodeKind = parseNodeKind(object)
                current.nodeKindTerm = object
            } else if predicate == SHACLIRIs.datatype {
                current.datatypeIRI = object
            } else if predicate == SHACLIRIs.minLength {
                guard let length = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.minLength = length
            } else if predicate == SHACLIRIs.maxLength {
                guard let length = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.maxLength = length
            } else if predicate == SHACLIRIs.singleLine {
                current.singleLine = isStrictTrueBooleanTerm(object)
            } else if predicate == SHACLIRIs.minListLength {
                guard let length = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.minListLength = length
            } else if predicate == SHACLIRIs.maxListLength {
                guard let length = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.maxListLength = length
            } else if predicate == SHACLIRIs.minInclusive {
                current.minInclusive = object
            } else if predicate == SHACLIRIs.maxInclusive {
                current.maxInclusive = object
            } else if predicate == SHACLIRIs.minExclusive {
                current.minExclusive = object
            } else if predicate == SHACLIRIs.maxExclusive {
                current.maxExclusive = object
            } else if predicate == SHACLIRIs.pattern {
                current.pattern = parsedLiteralLexicalForm(object)
            } else if predicate == SHACLIRIs.hasValue {
                current.hasValue = object
            } else if predicate == SHACLIRIs.in {
                current.inValues.insert(object)
            } else if predicate == SHACLIRIs.languageIn {
                current.languageInValues.insert(object)
            } else if predicate == SHACLIRIs.uniqueLang {
                current.uniqueLang = isStrictTrueBooleanTerm(object)
            } else if predicate == SHACLIRIs.uniqueMembers {
                current.uniqueMembers = isStrictTrueBooleanTerm(object)
            } else if predicate == SHACLIRIs.equals {
                current.equalsIRI = object
            } else if predicate == SHACLIRIs.disjoint {
                current.disjointIRI = object
            } else if predicate == SHACLIRIs.lessThan {
                current.lessThanIRI = object
            } else if predicate == SHACLIRIs.lessThanOrEquals {
                current.lessThanOrEqualsIRI = object
            } else if predicate == SHACLIRIs.closed {
                current.isClosed = isTrueBooleanTerm(object)
            } else if predicate == SHACLIRIs.ignoredProperties {
                current.ignoredPropertyIRIs.insert(object)
            } else if predicate == SHACLIRIs.nodeByExpression {
                current.nodeByExpressionIRI = object
            } else if predicate == SHACLIRIs.node {
                current.nodeShapeReferenceIRI = object
            } else if predicate == SHACLIRIs.and {
                current.andShapeIRIs.insert(object)
            } else if predicate == SHACLIRIs.or {
                current.orShapeIRIs.insert(object)
            } else if predicate == SHACLIRIs.xone {
                current.xoneShapeIRIs.insert(object)
            } else if predicate == SHACLIRIs.not {
                current.notShapeIRI = object
            } else if predicate == SHACLIRIs.reifierShape {
                current.reifierShapeIRI = object
            } else if predicate == SHACLIRIs.reificationRequired {
                current.reificationRequired = isStrictTrueBooleanTerm(object)
            } else if predicate == SHACLIRIs.memberShape {
                current.memberShapeIRI = object
            } else if predicate == SHACLIRIs.qualifiedValueShape {
                current.qualifiedValueShapeIRI = object
            } else if predicate == SHACLIRIs.someValue {
                if current.qualifiedValueShapeIRI == nil {
                    current.qualifiedValueShapeIRI = object
                }
                if current.qualifiedMinCount == nil {
                    current.qualifiedMinCount = 1
                }
            } else if predicate == SHACLIRIs.qualifiedValueShapesDisjoint {
                current.qualifiedValueShapesDisjoint = isTrueBooleanTerm(object)
            } else if predicate == SHACLIRIs.qualifiedMinCount {
                guard let count = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.qualifiedMinCount = count
            } else if predicate == SHACLIRIs.qualifiedMaxCount {
                guard let count = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.qualifiedMaxCount = count
            } else if predicate == SHACLIRIs.minCount {
                guard let count = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.minCount = count
            } else if predicate == SHACLIRIs.maxCount {
                guard let count = Int(object) else {
                    throw SHACLError.invalidIntegerLiteral(object)
                }
                current.maxCount = count
            } else if predicate == SHACLIRIs.condition {
                var rule = rules[subject] ?? PartialRule()
                rule.conditionShapeIRIs.insert(object)
                rules[subject] = rule
            } else if predicate == SHACLIRIs.order {
                guard let order = Double(parsedLiteralLexicalForm(object) ?? object) else {
                    throw SHACLError.invalidShapesGraph("Rule \(subject) has invalid sh:order value \(object)")
                }
                var rule = rules[subject] ?? PartialRule()
                rule.ruleOrder = order
                rules[subject] = rule
            } else if predicate == SHACLIRIs.subject {
                var rule = rules[subject] ?? PartialRule()
                rule.subjectTerm = object
                rules[subject] = rule
            } else if predicate == SHACLIRIs.predicate {
                var rule = rules[subject] ?? PartialRule()
                rule.predicateTerm = object
                rules[subject] = rule
            } else if predicate == SHACLIRIs.object {
                var rule = rules[subject] ?? PartialRule()
                rule.objectTerm = object
                rules[subject] = rule
            } else if predicate == SHACLIRIs.select {
                var sparql = sparqlDefinitions[subject] ?? PartialSPARQL()
                sparql.selectQuery = parsedLiteralLexicalForm(object) ?? object
                sparqlDefinitions[subject] = sparql
            } else if predicate == SHACLIRIs.ask {
                var sparql = sparqlDefinitions[subject] ?? PartialSPARQL()
                sparql.askQuery = parsedLiteralLexicalForm(object) ?? object
                sparqlDefinitions[subject] = sparql
            } else if predicate == SHACLIRIs.message {
                var sparql = sparqlDefinitions[subject] ?? PartialSPARQL()
                sparql.message = parsedLiteralLexicalForm(object) ?? object
                sparqlDefinitions[subject] = sparql
            } else if predicate == SHACLIRIs.prefixes {
                var sparql = sparqlDefinitions[subject] ?? PartialSPARQL()
                sparql.prefixesIRIs.insert(object)
                sparqlDefinitions[subject] = sparql
            }

            shapes[subject] = current

            if predicate == SHACLIRIs.union
                || predicate == SHACLIRIs.shnexUnion
                || predicate == SHACLIRIs.intersection
                || predicate == SHACLIRIs.shnexIntersection {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                if predicate == SHACLIRIs.union || predicate == SHACLIRIs.shnexUnion {
                    expression.unionMemberObjects.insert(object)
                } else {
                    expression.intersectionMemberObjects.insert(object)
                }
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexNodes {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.nodesObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexExists {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.existsObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexCount {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.countObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexVar {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.variableNames.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexDistinct {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.distinctObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexMatchAll {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.matchAllObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexFilterShape {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.filterShapeObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexInstancesOf {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.instancesOfObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexNodesMatching {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.nodesMatchingObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexMin {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.minObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexMax {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.maxObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexSum {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.sumObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexIf {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.ifObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexThen {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.thenObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexElse {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.elseObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexPathValues {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.pathValuesObject = object
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexFocusNode {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.pathValuesFocusNodeObject = object
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexConcat {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.concatObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexRemove {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.removeObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexFlatMap {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.flatMapObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexLimit {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.limitObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexOffset {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.offsetObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexFindFirst {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.findFirstObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexOrderBy {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.orderByObjects.insert(object)
                nodeExpressions[subject] = expression
            } else if predicate == SHACLIRIs.shnexDesc {
                var expression = nodeExpressions[subject] ?? PartialNodeExpression()
                expression.orderByDescending = isTrueBooleanTerm(object)
                nodeExpressions[subject] = expression
            }
        }

        let triplesBySubject = Dictionary(grouping: triples, by: \.subject)

        var expressionDefinitions = nodeExpressions.compactMap { expressionIRI, partial -> SHACLNodeExpressionDefinition? in
            let unionMembers = resolveShapeReferenceIRIs(partial.unionMemberObjects, triplesBySubject: triplesBySubject).sorted()
            if !unionMembers.isEmpty {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .union(unionMembers)
                )
            }

            let intersectionMembers = resolveShapeReferenceIRIs(partial.intersectionMemberObjects, triplesBySubject: triplesBySubject).sorted()
            if !intersectionMembers.isEmpty {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .intersection(intersectionMembers)
                )
            }

            if let shapeTerm = resolveShapeReferenceIRIs(partial.matchAllObjects, triplesBySubject: triplesBySubject).sorted().first,
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticListMembers = resolveStaticRDFListMembers(inputObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .matchAll(inputTerm: resolvedInput, shapeTerm: shapeTerm, staticListMembers: staticListMembers)
                )
            }

            if let shapeTerm = resolveShapeReferenceIRIs(partial.filterShapeObjects, triplesBySubject: triplesBySubject).sorted().first,
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticListMembers = resolveStaticRDFListMembers(inputObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .filterShape(inputTerm: resolvedInput, shapeTerm: shapeTerm, staticListMembers: staticListMembers)
                )
            }

            if let removeObject = partial.removeObjects.sorted().first,
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticInputListMembers = resolveStaticRDFListMembers(inputObject, triplesBySubject: triplesBySubject)
                let resolvedRemove = resolveShapeReferenceIRIs([removeObject], triplesBySubject: triplesBySubject).sorted().first ?? removeObject
                let staticRemoveListMembers = resolveStaticRDFListMembers(removeObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .remove(
                        inputTerm: resolvedInput,
                        removeTerm: resolvedRemove,
                        staticInputListMembers: staticInputListMembers,
                        staticRemoveListMembers: staticRemoveListMembers
                    )
                )
            }

            if let mapTerm = resolveShapeReferenceIRIs(partial.flatMapObjects, triplesBySubject: triplesBySubject).sorted().first,
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticInputListMembers = resolveStaticRDFListMembers(inputObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .flatMap(inputTerm: resolvedInput, mapTerm: mapTerm, staticInputListMembers: staticInputListMembers)
                )
            }

            if let limitObject = partial.limitObjects.sorted().first,
               let limitCount = Int(parsedLiteralLexicalForm(limitObject) ?? limitObject),
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticListMembers = resolveStaticRDFListMembers(inputObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .limit(inputTerm: resolvedInput, count: limitCount, staticListMembers: staticListMembers)
                )
            }

            if let offsetObject = partial.offsetObjects.sorted().first,
               let offsetCount = Int(parsedLiteralLexicalForm(offsetObject) ?? offsetObject),
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticListMembers = resolveStaticRDFListMembers(inputObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .offset(inputTerm: resolvedInput, count: offsetCount, staticListMembers: staticListMembers)
                )
            }

            if let shapeTerm = resolveShapeReferenceIRIs(partial.findFirstObjects, triplesBySubject: triplesBySubject).sorted().first,
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticOrderedInputMembers = rdfListLength(inputObject, triplesBySubject: triplesBySubject) != nil
                    ? resolveRDFListOrDirectValueOrdered(inputObject, triplesBySubject: triplesBySubject)
                    : nil
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .findFirst(inputTerm: resolvedInput, shapeTerm: shapeTerm, staticOrderedInputMembers: staticOrderedInputMembers)
                )
            }

            if let keyTerm = resolveShapeReferenceIRIs(partial.orderByObjects, triplesBySubject: triplesBySubject).sorted().first,
               let inputObject = partial.nodesObjects.sorted().first {
                let resolvedInput = resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted().first ?? inputObject
                let staticListMembers = rdfListLength(inputObject, triplesBySubject: triplesBySubject) != nil
                    ? resolveShapeReferenceIRIs([inputObject], triplesBySubject: triplesBySubject).sorted()
                    : nil
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .orderBy(
                        inputTerm: resolvedInput,
                        keyTerm: keyTerm,
                        descending: partial.orderByDescending,
                        staticListMembers: staticListMembers
                    )
                )
            }

            let nodesMembers: [String]
            if partial.nodesObjects.count == 1,
               let only = partial.nodesObjects.first,
               let staticOrdered = resolveStaticRDFListMembers(only, triplesBySubject: triplesBySubject) {
                nodesMembers = staticOrdered
            } else {
                nodesMembers = resolveShapeReferenceIRIs(partial.nodesObjects, triplesBySubject: triplesBySubject).sorted()
            }
            if !nodesMembers.isEmpty || partial.nodesObjects.contains(SHACLIRIs.rdfNil) {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .nodes(nodesMembers)
                )
            }

            if let concatObject = partial.concatObjects.sorted().first {
                let resolvedConcatInput = resolveShapeReferenceIRIs([concatObject], triplesBySubject: triplesBySubject).sorted().first ?? concatObject
                let staticListMembers: [String]?
                if rdfListLength(concatObject, triplesBySubject: triplesBySubject) != nil {
                    let members = resolveRDFListOrDirectValueOrdered(concatObject, triplesBySubject: triplesBySubject)
                    var flattened: [String] = []
                    for member in members {
                        if let nestedList = resolveStaticRDFListMembers(member, triplesBySubject: triplesBySubject) {
                            flattened.append(contentsOf: nestedList)
                        } else {
                            flattened.append(member)
                        }
                    }
                    staticListMembers = flattened
                } else {
                    staticListMembers = nil
                }
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .concat(inputTerm: resolvedConcatInput, staticListMembers: staticListMembers)
                )
            }

            if let existsInput = resolveShapeReferenceIRIs(partial.existsObjects, triplesBySubject: triplesBySubject).sorted().first {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .exists(existsInput)
                )
            }

            if let countObject = partial.countObjects.sorted().first {
                let resolvedCountInput = resolveShapeReferenceIRIs([countObject], triplesBySubject: triplesBySubject).sorted().first ?? countObject
                let staticListLength = rdfListLength(countObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .count(inputTerm: resolvedCountInput, staticListLength: staticListLength)
                )
            }

            if let variableNameTerm = partial.variableNames.sorted().first {
                let variableName = parsedLiteralLexicalForm(variableNameTerm) ?? variableNameTerm
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .variable(variableName)
                )
            }

            if let distinctObject = partial.distinctObjects.sorted().first {
                let resolvedDistinctInput = resolveShapeReferenceIRIs([distinctObject], triplesBySubject: triplesBySubject).sorted().first ?? distinctObject
                let staticListMembers = resolveStaticRDFListMembers(distinctObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .distinct(inputTerm: resolvedDistinctInput, staticListMembers: staticListMembers)
                )
            }

            if let classTerm = resolveShapeReferenceIRIs(partial.instancesOfObjects, triplesBySubject: triplesBySubject).sorted().first {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .instancesOf(classTerm)
                )
            }

            if let shapeTerm = resolveShapeReferenceIRIs(partial.nodesMatchingObjects, triplesBySubject: triplesBySubject).sorted().first {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .nodesMatching(shapeTerm)
                )
            }

            if let minObject = partial.minObjects.sorted().first {
                let resolvedMinInput = resolveShapeReferenceIRIs([minObject], triplesBySubject: triplesBySubject).sorted().first ?? minObject
                let staticListMembers = resolveStaticRDFListMembers(minObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .min(inputTerm: resolvedMinInput, staticListMembers: staticListMembers)
                )
            }

            if let maxObject = partial.maxObjects.sorted().first {
                let resolvedMaxInput = resolveShapeReferenceIRIs([maxObject], triplesBySubject: triplesBySubject).sorted().first ?? maxObject
                let staticListMembers = resolveStaticRDFListMembers(maxObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .max(inputTerm: resolvedMaxInput, staticListMembers: staticListMembers)
                )
            }

            if let sumObject = partial.sumObjects.sorted().first {
                let resolvedSumInput = resolveShapeReferenceIRIs([sumObject], triplesBySubject: triplesBySubject).sorted().first ?? sumObject
                let staticListMembers = resolveStaticRDFListMembers(sumObject, triplesBySubject: triplesBySubject)
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .sum(inputTerm: resolvedSumInput, staticListMembers: staticListMembers)
                )
            }

            let ifTerms = resolveShapeReferenceIRIs(partial.ifObjects, triplesBySubject: triplesBySubject).sorted()
            let thenTerms = resolveShapeReferenceIRIs(partial.thenObjects, triplesBySubject: triplesBySubject).sorted()
            let elseTerms = resolveShapeReferenceIRIs(partial.elseObjects, triplesBySubject: triplesBySubject).sorted()
            if let condition = ifTerms.first, let thenTerm = thenTerms.first {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .ifThenElse(condition: condition, thenTerm: thenTerm, elseTerm: elseTerms.first)
                )
            }

            if let pathValuesObject = partial.pathValuesObject,
               let parsedPath = parsePropertyPath(pathValuesObject, triplesBySubject: triplesBySubject) {
                return SHACLNodeExpressionDefinition(
                    expressionIRI: expressionIRI,
                    kind: .pathValues(path: parsedPath, focusNodeTerm: partial.pathValuesFocusNodeObject)
                )
            }

            return nil
        }

        let definedExpressionIRIs = Set(expressionDefinitions.map(\.expressionIRI))
        let rdfListHeadIRIs = Set(
            triplesBySubject.compactMap { subject, subjectTriples in
                subjectTriples.contains(where: { $0.predicate == SHACLIRIs.rdfFirst }) ? subject : nil
            }
        )
        let synthesizedListExpressions = rdfListHeadIRIs
            .subtracting(definedExpressionIRIs)
            .sorted()
            .map { listHeadIRI in
                SHACLNodeExpressionDefinition(
                    expressionIRI: listHeadIRI,
                    kind: .nodes(resolveRDFListOrDirectValueOrdered(listHeadIRI, triplesBySubject: triplesBySubject))
                )
            }
        expressionDefinitions.append(contentsOf: synthesizedListExpressions)
        expressionDefinitions.sort(by: { $0.expressionIRI < $1.expressionIRI })
        let expressionIRIs = Set(expressionDefinitions.map(\.expressionIRI))

        let definitions = shapes.compactMap { shapeIRI, partial -> SHACLShapeDefinition? in
            let kind: SHACLShapeKind
            if let explicitKind = partial.kind {
                kind = explicitKind
            } else if partial.pathIRI != nil || partial.expressionIRI != nil {
                // W3C fixtures often omit rdf:type sh:PropertyShape on nested blank nodes.
                kind = .propertyShape
            } else {
                // Untyped shapes without sh:path/sh:expression are treated as node shapes.
                kind = .nodeShape
            }
            let resolvedTargetNodes = partial.targets.compactMap { selector -> String? in
                if case .targetNode(let node) = selector {
                    return node
                }
                return nil
            }
            let derivedSPARQLTargetIRIs = Set(
                resolvedTargetNodes.filter { targetNode in
                    if let sparql = sparqlDefinitions[targetNode] {
                        return sparql.selectQuery != nil
                    }
                    return false
                }
            )
            let normalizedTargets = partial.targets.compactMap { selector -> SHACLTargetSelector? in
                if case .targetNode(let node) = selector {
                    if expressionIRIs.contains(node) {
                        return .targetNodeExpression(node)
                    }
                    if derivedSPARQLTargetIRIs.contains(node) {
                        return nil
                    }
                }
                return selector
            }
            let normalizedSPARQLTargetIRIs = resolveShapeReferenceIRIs(partial.sparqlTargetIRIs, triplesBySubject: triplesBySubject)
                .union(derivedSPARQLTargetIRIs)
            return SHACLShapeDefinition(
                shapeIRI: shapeIRI,
                kind: kind,
                isRDFSClass: partial.isRDFSClass,
                isDeactivated: partial.isDeactivated,
                severity: partial.severity,
                targets: normalizedTargets.sorted(by: { targetSortKey($0) < targetSortKey($1) }),
                propertyShapeIRIs: partial.propertyShapeIRIs.sorted(),
                tripleRuleIRIs: resolveShapeReferenceIRIs(partial.ruleIRIs, triplesBySubject: triplesBySubject).sorted(),
                sparqlConstraintIRIs: resolveShapeReferenceIRIs(partial.sparqlConstraintIRIs, triplesBySubject: triplesBySubject).sorted(),
                sparqlTargetIRIs: normalizedSPARQLTargetIRIs.sorted(),
                pathIRI: partial.pathIRI,
                propertyPath: partial.pathIRI.flatMap { parsePropertyPath($0, triplesBySubject: triplesBySubject) },
                expressionIRI: partial.expressionIRI,
                classIRI: partial.classIRI,
                nodeKind: partial.nodeKind ?? partial.nodeKindTerm.flatMap { term in
                    parseNodeKindConstraint(term, triplesBySubject: triplesBySubject)
                },
                datatypeIRI: partial.datatypeIRI,
                minLength: partial.minLength,
                maxLength: partial.maxLength,
                singleLine: partial.singleLine,
                minListLength: partial.minListLength,
                maxListLength: partial.maxListLength,
                minInclusive: partial.minInclusive,
                maxInclusive: partial.maxInclusive,
                minExclusive: partial.minExclusive,
                maxExclusive: partial.maxExclusive,
                pattern: partial.pattern,
                hasValue: partial.hasValue,
                inValues: resolveInValues(partial.inValues, triplesBySubject: triplesBySubject).sorted(),
                languageInValues: resolveInValues(partial.languageInValues, triplesBySubject: triplesBySubject).sorted(),
                uniqueLang: partial.uniqueLang,
                uniqueMembers: partial.uniqueMembers,
                equalsIRI: partial.equalsIRI,
                disjointIRI: partial.disjointIRI,
                lessThanIRI: partial.lessThanIRI,
                lessThanOrEqualsIRI: partial.lessThanOrEqualsIRI,
                isClosed: partial.isClosed,
                ignoredPropertyIRIs: resolveShapeReferenceIRIs(partial.ignoredPropertyIRIs, triplesBySubject: triplesBySubject).sorted(),
                nodeByExpressionIRI: partial.nodeByExpressionIRI,
                nodeShapeReferenceIRI: partial.nodeShapeReferenceIRI,
                andShapeIRIs: resolveShapeReferenceIRIs(partial.andShapeIRIs, triplesBySubject: triplesBySubject).sorted(),
                orShapeIRIs: resolveShapeReferenceIRIs(partial.orShapeIRIs, triplesBySubject: triplesBySubject).sorted(),
                xoneShapeIRIs: resolveShapeReferenceIRIs(partial.xoneShapeIRIs, triplesBySubject: triplesBySubject).sorted(),
                notShapeIRI: partial.notShapeIRI,
                reifierShapeIRI: partial.reifierShapeIRI,
                reificationRequired: partial.reificationRequired,
                memberShapeIRI: partial.memberShapeIRI,
                qualifiedValueShapeIRI: partial.qualifiedValueShapeIRI,
                qualifiedValueShapesDisjoint: partial.qualifiedValueShapesDisjoint,
                qualifiedMinCount: partial.qualifiedMinCount,
                qualifiedMaxCount: partial.qualifiedMaxCount,
                minCount: partial.minCount,
                maxCount: partial.maxCount
            )
        }
        .sorted(by: { $0.shapeIRI < $1.shapeIRI })

        let referencedRuleIRIs = Set(definitions.flatMap(\.tripleRuleIRIs))
        let tripleRuleDefinitions = try referencedRuleIRIs.sorted().map { ruleIRI in
            guard let partial = rules[ruleIRI] else {
                throw SHACLError.invalidShapesGraph("Shape references missing rule \(ruleIRI)")
            }
            guard partial.isTripleRule else {
                throw SHACLError.invalidShapesGraph("Rule \(ruleIRI) is missing rdf:type sh:TripleRule")
            }
            guard let subjectTerm = partial.subjectTerm else {
                throw SHACLError.invalidShapesGraph("Rule \(ruleIRI) is missing sh:subject")
            }
            guard let predicateTerm = partial.predicateTerm else {
                throw SHACLError.invalidShapesGraph("Rule \(ruleIRI) is missing sh:predicate")
            }
            guard let objectTerm = partial.objectTerm else {
                throw SHACLError.invalidShapesGraph("Rule \(ruleIRI) is missing sh:object")
            }
            return SHACLTripleRuleDefinition(
                ruleIRI: ruleIRI,
                ruleOrder: partial.ruleOrder,
                conditionShapeIRIs: resolveShapeReferenceIRIs(partial.conditionShapeIRIs, triplesBySubject: triplesBySubject).sorted(),
                subjectTerm: subjectTerm,
                predicateTerm: predicateTerm,
                objectTerm: objectTerm
            )
        }

        let targetNodeReferencedSPARQLIRIs = Set(
            definitions.flatMap(\.targets).compactMap { target -> String? in
                if case .targetNode(let iri) = target, sparqlDefinitions[iri] != nil {
                    return iri
                }
                return nil
            }
        )
        let referencedSPARQLIRIs = Set(
            definitions.flatMap(\.sparqlConstraintIRIs)
                + definitions.flatMap(\.sparqlTargetIRIs)
                + Array(targetNodeReferencedSPARQLIRIs)
        )
        let parsedSPARQLDefinitions = try referencedSPARQLIRIs.sorted().map { sparqlIRI in
            guard let partial = sparqlDefinitions[sparqlIRI] else {
                throw SHACLError.invalidShapesGraph("Shape references missing SPARQL definition \(sparqlIRI)")
            }
            if partial.selectQuery == nil && partial.askQuery == nil {
                throw SHACLError.invalidShapesGraph("SPARQL definition \(sparqlIRI) is missing sh:select/sh:ask")
            }
            let prefixes = resolveSPARQLPrefixes(
                for: partial.prefixesIRIs,
                triplesBySubject: triplesBySubject
            )
            return SHACLSPARQLDefinition(
                sparqlIRI: sparqlIRI,
                selectQuery: partial.selectQuery,
                askQuery: partial.askQuery,
                message: partial.message,
                prefixes: prefixes
            )
        }

        return SHACLShapesGraph(
            shapes: definitions,
            nodeExpressions: expressionDefinitions,
            tripleRules: tripleRuleDefinitions,
            sparqlDefinitions: parsedSPARQLDefinitions
        )
    }
}
