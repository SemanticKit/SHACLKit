import Foundation

extension SHACLCoreValidator {
    func matchesNodeKind(_ value: String, nodeKind: SHACLNodeKindConstraint) -> Bool {
        let isLiteral = parseNumericValue(value) != nil || value.hasPrefix("\"")
        let isBlankNode = value.hasPrefix("_:")
        let isIRI = !isLiteral && !isBlankNode && (value.contains("://") || value.hasPrefix("urn:"))

        switch nodeKind {
        case .iri:
            return isIRI
        case .literal:
            return isLiteral
        case .blankNode:
            return isBlankNode
        case .blankNodeOrIRI:
            return isBlankNode || isIRI
        case .blankNodeOrLiteral:
            return isBlankNode || isLiteral
        case .iriOrLiteral:
            return isIRI || isLiteral
        }
    }

    func inferredDatatypeIRI(for value: String) -> String? {
        if let numeric = parseNumericValue(value) {
            return numeric.isInteger ? SHACLIRIs.xsdInteger : SHACLIRIs.xsdDecimal
        }

        guard value.hasPrefix("\"") else {
            return nil
        }

        if let typedRange = value.range(of: "^^") {
            return String(value[typedRange.upperBound...])
        }

        if value.contains("\"@") {
            return SHACLIRIs.rdfLangString
        }

        return SHACLIRIs.xsdString
    }

    func isLexicallyValidLiteral(_ valueNode: String, forDatatypeIRI datatypeIRI: String) -> Bool {
        if let numeric = parseNumericValue(valueNode) {
            switch datatypeIRI {
            case SHACLIRIs.xsdInteger:
                return numeric.isInteger
            case SHACLIRIs.xsdDecimal:
                return true
            case SHACLIRIs.xsdByte:
                guard numeric.isInteger else {
                    return false
                }
                let intValue = Int(numeric.number)
                return (-128...127).contains(intValue)
            default:
                break
            }
        }

        guard let lexical = extractLiteralLexicalForm(valueNode) else {
            return false
        }

        switch datatypeIRI {
        case SHACLIRIs.xsdInteger:
            return Int(lexical) != nil
        case SHACLIRIs.xsdDecimal:
            return lexical.range(of: #"^-?\d+(\.\d+)?$"#, options: .regularExpression) != nil
        case SHACLIRIs.xsdBoolean:
            return lexical == "true" || lexical == "false" || lexical == "1" || lexical == "0"
        case SHACLIRIs.xsdDateTime:
            return parseDateTimeLexicalForm(lexical) != nil
        case SHACLIRIs.xsdByte:
            guard let parsed = Int(lexical) else {
                return false
            }
            return (-128...127).contains(parsed)
        default:
            return true
        }
    }
}
