import Foundation

extension SHACLCoreValidator {
    private func extractIntegerValue(_ value: String) -> Int? {
        if let direct = Int(value) {
            return direct
        }

        guard let lexical = extractLiteralLexicalForm(value) else {
            return nil
        }
        return Int(lexical)
    }

    func parseNumericValue(_ value: String) -> (number: Double, isInteger: Bool)? {
        if let direct = Double(value) {
            return (direct, Int(value) != nil)
        }
        guard let lexical = extractLiteralLexicalForm(value), let parsed = Double(lexical) else {
            return nil
        }
        return (parsed, Int(lexical) != nil)
    }

    func compareRangeValueTerm(_ valueTerm: String, toBoundTerm boundTerm: String) -> ComparisonResult? {
        guard let valueComparable = parseRangeComparable(valueTerm),
              let boundComparable = parseRangeComparable(boundTerm) else {
            return nil
        }

        switch (valueComparable, boundComparable) {
        case (.number(let value, _), .number(let bound, _)):
            if value < bound {
                return .orderedAscending
            }
            if value > bound {
                return .orderedDescending
            }
            return .orderedSame
        case (.dateTime(let valueDate, let valueHasTimezone), .dateTime(let boundDate, let boundHasTimezone)):
            guard valueHasTimezone == boundHasTimezone else {
                return nil
            }
            return valueDate.compare(boundDate)
        default:
            return nil
        }
    }

    func rangeTypeViolationMessage(valueTerm: String, boundTerm: String) -> String {
        if case .number(_, let isInteger)? = parseRangeComparable(boundTerm), isInteger {
            return "range violation: value \(valueTerm) is not an integer literal"
        }
        if case .number = parseRangeComparable(boundTerm) {
            return "range violation: value \(valueTerm) is not a numeric literal"
        }
        if case .dateTime = parseRangeComparable(boundTerm) {
            return "range violation: value \(valueTerm) is not comparable to xsd:dateTime boundary"
        }
        return "range violation: value \(valueTerm) is not comparable to boundary \(boundTerm)"
    }

    private func parseRangeComparable(_ term: String) -> SHACLRangeComparable? {
        if let numeric = parseNumericValue(term) {
            return .number(numeric.number, isInteger: numeric.isInteger)
        }

        guard inferredDatatypeIRI(for: term) == SHACLIRIs.xsdDateTime,
              let lexical = extractLiteralLexicalForm(term),
              let parsedDate = parseDateTimeLexicalForm(lexical) else {
            return nil
        }
        return .dateTime(parsedDate.date, hasTimezone: parsedDate.hasTimezone)
    }

    func parseDateTimeLexicalForm(_ lexical: String) -> (date: Date, hasTimezone: Bool)? {
        let hasTimezone = lexical.hasSuffix("Z")
            || lexical.range(of: #"[+-]\d{2}:\d{2}$"#, options: .regularExpression) != nil

        if hasTimezone {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let parsed = formatter.date(from: lexical) {
                return (parsed, true)
            }
            formatter.formatOptions = [.withInternetDateTime]
            if let parsed = formatter.date(from: lexical) {
                return (parsed, true)
            }
            return nil
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let parsed = formatter.date(from: lexical) else {
            return nil
        }
        return (parsed, false)
    }
}
