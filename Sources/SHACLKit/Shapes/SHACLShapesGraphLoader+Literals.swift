import Foundation

extension SHACLShapesGraphLoader {
    func isTrueBooleanTerm(_ term: String) -> Bool {
        term == "true"
            || term == "1"
            || term == "\"true\""
            || term == "\"true\"^^\(SHACLIRIs.xsdBoolean)"
            || term == "\"1\"^^\(SHACLIRIs.xsdBoolean)"
    }

    func isStrictTrueBooleanTerm(_ term: String) -> Bool {
        term == "true"
            || term == "\"true\""
            || term == "\"true\"^^\(SHACLIRIs.xsdBoolean)"
    }

    func parsedLiteralLexicalForm(_ value: String) -> String? {
        if value.hasPrefix("\"\"\"") {
            let start = value.index(value.startIndex, offsetBy: 3)
            guard let closing = value.range(of: "\"\"\"", range: start..<value.endIndex)?.lowerBound else {
                return nil
            }
            return String(value[start..<closing])
        }
        guard value.hasPrefix("\"") else {
            return nil
        }
        guard let closing = value.dropFirst().firstIndex(of: "\"") else {
            return nil
        }
        let start = value.index(after: value.startIndex)
        return String(value[start..<closing])
    }

    func isIRIReferenceTerm(_ term: String) -> Bool {
        !term.hasPrefix("_:")
            && !term.hasPrefix("\"")
            && !term.isEmpty
            && term != SHACLIRIs.rdfNil
    }
}
