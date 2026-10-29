import Foundation

func isTrueOnlyExpressionSet(_ outputNodes: Set<String>) -> Bool {
    guard outputNodes.count == 1, let only = outputNodes.first else {
        return false
    }
    return only == "true"
        || only == "1"
        || only == "\"true\""
        || only == "\"true\"^^\(SHACLIRIs.xsdBoolean)"
        || only == "\"1\"^^\(SHACLIRIs.xsdBoolean)"
}

func numericExtremeTerm(from outputNodes: Set<String>, findMaximum: Bool) -> String? {
    var chosen: (term: String, value: Double)?
    for term in outputNodes {
        guard let value = nodeExpressionNumericTerm(term)?.value else {
            continue
        }
        guard let current = chosen else {
            chosen = (term, value)
            continue
        }
        if findMaximum {
            if value > current.value {
                chosen = (term, value)
            }
        } else if value < current.value {
            chosen = (term, value)
        }
    }
    return chosen?.term
}

func numericSum(from outputNodes: Set<String>) -> String {
    var total = 0.0
    var sawDecimal = false
    for term in outputNodes {
        guard let parsed = nodeExpressionNumericTerm(term) else {
            continue
        }
        total += parsed.value
        if !parsed.isInteger {
            sawDecimal = true
        }
    }

    if !sawDecimal && floor(total) == total {
        return String(Int(total))
    }
    if sawDecimal && floor(total) == total {
        return "\(Int(total)).0"
    }

    var text = String(total)
    if text.contains(".") {
        while text.last == "0" {
            text.removeLast()
        }
        if text.last == "." {
            text.removeLast()
        }
    }
    return text
}

func nodeExpressionNumericTerm(_ term: String) -> (value: Double, isInteger: Bool)? {
    if let direct = Double(term) {
        return (direct, Int(term) != nil)
    }
    guard let lexical = nodeExpressionLiteralLexicalForm(term),
          let parsed = Double(lexical) else {
        return nil
    }
    return (parsed, Int(lexical) != nil)
}

private func nodeExpressionLiteralLexicalForm(_ value: String) -> String? {
    guard value.hasPrefix("\"") else {
        return nil
    }
    guard let closing = value.dropFirst().firstIndex(of: "\"") else {
        return nil
    }
    let start = value.index(after: value.startIndex)
    return String(value[start..<closing])
}
