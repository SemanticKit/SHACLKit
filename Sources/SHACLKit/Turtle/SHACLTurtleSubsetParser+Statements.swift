import Foundation

extension SHACLTurtleSubsetParser {
    func parseStatement(
        _ statement: String,
        prefixes: [String: String],
        listCounter: inout Int,
        blankNodeCounter: inout Int
    ) throws -> [SHACLTriple] {
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

        func parseObjectWithOptionalReifier(
            subject: String,
            predicate: String
        ) throws -> String {
            let object = try parseTerm(
                tokens: tokens,
                index: &index,
                prefixes: prefixes,
                triples: &triples,
                listCounter: &listCounter,
                blankNodeCounter: &blankNodeCounter,
                statement: statement
            )
            if index < tokens.count, tokens[index] == "{|" {
                _ = takeToken()
                blankNodeCounter += 1
                let reifierNode = "_:shacl_reifier_\(blankNodeCounter)"
                triples.append(SHACLTriple(subject: reifierNode, predicate: SHACLIRIs.rdfSubject, object: subject))
                triples.append(SHACLTriple(subject: reifierNode, predicate: SHACLIRIs.rdfPredicate, object: predicate))
                triples.append(SHACLTriple(subject: reifierNode, predicate: SHACLIRIs.rdfObject, object: object))

                while index < tokens.count {
                    if tokens[index] == "|}" {
                        _ = takeToken()
                        break
                    }
                    guard let annotationPredicateToken = takeToken() else {
                        throw SHACLError.invalidStatement(statement)
                    }
                    let annotationPredicate = try resolveTerm(annotationPredicateToken, prefixes: prefixes)
                    var annotationObjects: [String] = [
                        try parseTerm(
                            tokens: tokens,
                            index: &index,
                            prefixes: prefixes,
                            triples: &triples,
                            listCounter: &listCounter,
                            blankNodeCounter: &blankNodeCounter,
                            statement: statement
                        )
                    ]
                    while index < tokens.count, tokens[index] == "," {
                        _ = takeToken()
                        annotationObjects.append(
                            try parseTerm(
                                tokens: tokens,
                                index: &index,
                                prefixes: prefixes,
                                triples: &triples,
                                listCounter: &listCounter,
                                blankNodeCounter: &blankNodeCounter,
                                statement: statement
                            )
                        )
                    }
                    for annotationObject in annotationObjects {
                        triples.append(SHACLTriple(subject: reifierNode, predicate: annotationPredicate, object: annotationObject))
                    }
                    if index < tokens.count, tokens[index] == ";" {
                        _ = takeToken()
                    }
                }
            }
            return object
        }

        var triples: [SHACLTriple] = []
        let subject = try parseTerm(
            tokens: tokens,
            index: &index,
            prefixes: prefixes,
            triples: &triples,
            listCounter: &listCounter,
            blankNodeCounter: &blankNodeCounter,
            statement: statement
        )

        while index < tokens.count {
            guard let predicateToken = takeToken() else {
                throw SHACLError.invalidStatement(statement)
            }

            if predicateToken == ";" {
                continue
            }

            let predicate = try resolveTerm(predicateToken, prefixes: prefixes)

            var objects: [String] = [
                try parseObjectWithOptionalReifier(subject: subject, predicate: predicate)
            ]

            while index < tokens.count, tokens[index] == "," {
                _ = takeToken()
                objects.append(
                    try parseObjectWithOptionalReifier(subject: subject, predicate: predicate)
                )
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

    private func parseObjectList(
        tokens: [String],
        index: inout Int,
        prefixes: [String: String],
        triples: inout [SHACLTriple],
        listCounter: inout Int,
        blankNodeCounter: inout Int,
        statement: String
    ) throws -> String {
        var values: [String] = []
        var sawClose = false

        while index < tokens.count {
            let token = tokens[index]
            if token == ")" {
                index += 1
                sawClose = true
                break
            }
            if token == ";" || token == "," {
                throw SHACLError.invalidStatement(statement)
            }
            values.append(
                try parseTerm(
                    tokens: tokens,
                    index: &index,
                    prefixes: prefixes,
                    triples: &triples,
                    listCounter: &listCounter,
                    blankNodeCounter: &blankNodeCounter,
                    statement: statement
                )
            )
        }

        if !sawClose {
            throw SHACLError.invalidStatement(statement)
        }

        if values.isEmpty {
            return SHACLIRIs.rdfNil
        }

        func nextListNode() -> String {
            defer { listCounter += 1 }
            return "_:ListNode\(listCounter)"
        }

        let head = nextListNode()
        var current = head

        for position in values.indices {
            triples.append(
                SHACLTriple(subject: current, predicate: SHACLIRIs.rdfFirst, object: values[position])
            )
            let isLast = position == values.count - 1
            let next = isLast ? SHACLIRIs.rdfNil : nextListNode()
            triples.append(
                SHACLTriple(subject: current, predicate: SHACLIRIs.rdfRest, object: next)
            )
            current = next
        }

        return head
    }

    private func parseBlankNodePropertyList(
        tokens: [String],
        index: inout Int,
        prefixes: [String: String],
        triples: inout [SHACLTriple],
        listCounter: inout Int,
        blankNodeCounter: inout Int,
        statement: String
    ) throws -> String {
        func nextBlankNode() -> String {
            defer { blankNodeCounter += 1 }
            return "_:BNode\(blankNodeCounter)"
        }

        let blankNode = nextBlankNode()

        while index < tokens.count {
            let token = tokens[index]
            if token == "]" {
                index += 1
                return blankNode
            }
            if token == ";" {
                index += 1
                continue
            }
            if token == "," || token == ")" {
                throw SHACLError.invalidStatement(statement)
            }

            let predicateToken = token
            index += 1
            let predicate = try resolveTerm(predicateToken, prefixes: prefixes)

            var objects: [String] = [
                try parseTerm(
                    tokens: tokens,
                    index: &index,
                    prefixes: prefixes,
                    triples: &triples,
                    listCounter: &listCounter,
                    blankNodeCounter: &blankNodeCounter,
                    statement: statement
                )
            ]

            while index < tokens.count, tokens[index] == "," {
                index += 1
                objects.append(
                    try parseTerm(
                        tokens: tokens,
                        index: &index,
                        prefixes: prefixes,
                        triples: &triples,
                        listCounter: &listCounter,
                        blankNodeCounter: &blankNodeCounter,
                        statement: statement
                    )
                )
            }

            for object in objects {
                triples.append(SHACLTriple(subject: blankNode, predicate: predicate, object: object))
            }

            if index < tokens.count, tokens[index] == ";" {
                index += 1
            }
        }

        throw SHACLError.invalidStatement(statement)
    }

    private func parseTerm(
        tokens: [String],
        index: inout Int,
        prefixes: [String: String],
        triples: inout [SHACLTriple],
        listCounter: inout Int,
        blankNodeCounter: inout Int,
        statement: String
    ) throws -> String {
        guard index < tokens.count else {
            throw SHACLError.invalidStatement(statement)
        }

        let token = tokens[index]
        if token == ";" || token == "," || token == ")" || token == "]" || token == "{|" || token == "|}" {
            throw SHACLError.invalidStatement(statement)
        }

        if token == "(" {
            index += 1
            return try parseObjectList(
                tokens: tokens,
                index: &index,
                prefixes: prefixes,
                triples: &triples,
                listCounter: &listCounter,
                blankNodeCounter: &blankNodeCounter,
                statement: statement
            )
        }

        if token == "[" {
            index += 1
            return try parseBlankNodePropertyList(
                tokens: tokens,
                index: &index,
                prefixes: prefixes,
                triples: &triples,
                listCounter: &listCounter,
                blankNodeCounter: &blankNodeCounter,
                statement: statement
            )
        }

        index += 1
        return try resolveTerm(token, prefixes: prefixes)
    }
}
