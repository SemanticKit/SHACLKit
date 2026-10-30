import Foundation
import IRIKit
import RDFCore
import RDFKit

/// The values of literals, as SHACL's constraints compare them.
extension Literal {
    /// A literal of `xsd:boolean`.
    init(_ value: Bool) {
        // xsd:boolean is never xsd:string or a language-tagged datatype.
        self = try! Literal(value ? "true" : "false", datatype: XSD.boolean.metadata.id)
    }

    /// A literal of `xsd:integer`.
    init(_ value: Int) {
        self = try! Literal(String(value), datatype: XSD.integer.metadata.id)
    }

    /// The value of an `xsd:boolean` literal: its lexical space is `true`,
    /// `false`, `1` and `0` (XML Schema 1.1 Part 2 §3.3.2.1).
    var booleanValue: Bool? {
        guard datatypeIRI == XSD.boolean.metadata.id else { return nil }
        switch lexicalForm {
        case "true", "1": return true
        case "false", "0": return false
        default: return nil
        }
    }

    /// Whether the literal is the `xsd:boolean` value true.
    var isTrue: Bool { booleanValue == true }

    /// The value of a literal of an integer datatype.
    var integerValue: Int? {
        guard Self.integerDatatypes.contains(datatypeIRI) else { return nil }
        return Int(lexicalForm.trimmingCharacters(in: .whitespaces))
    }

    /// The value of a literal of a numeric datatype (XML Schema 1.1 Part 2
    /// §3.3.3 to §3.3.5 and the integer datatypes derived from
    /// `xsd:decimal`), as a binary floating-point number.
    var numericValue: Double? {
        let datatype = datatypeIRI
        guard Self.integerDatatypes.contains(datatype) || datatype == XSD.decimal.metadata.id
            || datatype == XSD.double.metadata.id || datatype == XSDDatatypes.float.metadata.id else { return nil }
        let lexical = lexicalForm.trimmingCharacters(in: .whitespaces)
        switch lexical {
        case "INF", "+INF": return .infinity
        case "-INF": return -.infinity
        case "NaN": return .nan
        default: return Double(lexical)
        }
    }

    /// Whether the literal's datatype is an integer datatype.
    var isInteger: Bool { Self.integerDatatypes.contains(datatypeIRI) }

    /// The instant of an `xsd:dateTime` literal, and whether it has a time
    /// zone: XML Schema 1.1 Part 2 §3.3.7 orders a dateTime with a time
    /// zone and one without only when they are far apart, so they are not
    /// compared here.
    var dateTimeValue: (date: Date, hasTimezone: Bool)? {
        guard datatypeIRI == XSDDatatypes.dateTime.metadata.id else { return nil }
        return Self.dateTime(lexicalForm)
    }

    /// Whether the literal is well-formed for `datatype`: its datatype is
    /// `datatype` and, for the datatypes whose lexical space is checked
    /// here, its lexical form is in that space. SHACL 1.2 Core §4.2.2:
    /// "A literal ... is not a well-formed lexical form for the datatype
    /// ... is a validation result".
    func isWellFormed(as datatype: IRI) -> Bool {
        guard datatypeIRI == datatype else { return false }
        let lexical = lexicalForm
        if datatype == XSD.boolean.metadata.id { return booleanValue != nil }
        if datatype == XSD.decimal.metadata.id { return lexical.wholeMatch(of: /[+-]?(\d+(\.\d*)?|\.\d+)/) != nil }
        if datatype == XSD.double.metadata.id || datatype == XSDDatatypes.float.metadata.id {
            return lexical.wholeMatch(of: /[+-]?((\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?|INF)|NaN/) != nil
        }
        if datatype == XSDDatatypes.dateTime.metadata.id { return Self.dateTime(lexical) != nil }
        if datatype == XSDDatatypes.date.metadata.id {
            return lexical.wholeMatch(of: /-?\d{4,}-\d{2}-\d{2}(Z|[+-]\d{2}:\d{2})?/) != nil
        }
        if let bounds = Self.integerBounds(of: datatype) {
            guard lexical.wholeMatch(of: /[+-]?\d+/) != nil else { return false }
            guard let value = Int(lexical) else { return bounds == nil }
            return bounds.map { $0.contains(value) } ?? true
        }
        return true
    }

    /// Orders two literals by value: numbers by number, and `xsd:dateTime`
    /// instants that both have, or both lack, a time zone. SHACL 1.2 Core
    /// §4.4 compares with SPARQL's `<` operator; other pairs are not
    /// comparable.
    func compare(to other: Literal) -> ComparisonResult? {
        if let value = numericValue, let bound = other.numericValue {
            if value.isNaN || bound.isNaN { return nil }
            return value < bound ? .orderedAscending : value > bound ? .orderedDescending : .orderedSame
        }
        if let value = dateTimeValue, let bound = other.dateTimeValue, value.hasTimezone == bound.hasTimezone {
            return value.date.compare(bound.date)
        }
        return nil
    }

    // MARK: - Datatypes

    /// `xsd:integer` and the datatypes derived from it (XML Schema 1.1 Part
    /// 2 §3.4.13 to §3.4.25).
    private static var integerDatatypes: Set<IRI> {
        [
            XSD.integer.metadata.id, XSD.nonNegativeInteger.metadata.id,
            XSDDatatypes.long.metadata.id, XSDDatatypes.int.metadata.id, XSDDatatypes.short.metadata.id,
            XSDDatatypes.byte.metadata.id, XSDDatatypes.nonPositiveInteger.metadata.id,
            XSDDatatypes.negativeInteger.metadata.id, XSDDatatypes.positiveInteger.metadata.id,
            XSDDatatypes.unsignedLong.metadata.id, XSDDatatypes.unsignedInt.metadata.id,
            XSDDatatypes.unsignedShort.metadata.id, XSDDatatypes.unsignedByte.metadata.id,
        ]
    }

    /// The value bounds of an integer datatype: `.some(nil)` for an
    /// unbounded one, `nil` for a datatype that is not an integer datatype.
    private static func integerBounds(of datatype: IRI) -> ClosedRange<Int>?? {
        switch datatype {
        case XSD.integer.metadata.id: .some(nil)
        case XSD.nonNegativeInteger.metadata.id: 0...Int.max
        case XSDDatatypes.long.metadata.id: Int.min...Int.max
        case XSDDatatypes.int.metadata.id: -2_147_483_648...2_147_483_647
        case XSDDatatypes.short.metadata.id: -32_768...32_767
        case XSDDatatypes.byte.metadata.id: -128...127
        case XSDDatatypes.nonPositiveInteger.metadata.id: Int.min...0
        case XSDDatatypes.negativeInteger.metadata.id: Int.min...(-1)
        case XSDDatatypes.positiveInteger.metadata.id: 1...Int.max
        case XSDDatatypes.unsignedLong.metadata.id: 0...Int.max
        case XSDDatatypes.unsignedInt.metadata.id: 0...4_294_967_295
        case XSDDatatypes.unsignedShort.metadata.id: 0...65_535
        case XSDDatatypes.unsignedByte.metadata.id: 0...255
        default: nil
        }
    }

    /// An `xsd:dateTime` lexical form (XML Schema 1.1 Part 2 §3.3.7.2).
    private static func dateTime(_ lexical: String) -> (date: Date, hasTimezone: Bool)? {
        guard lexical.wholeMatch(of: /-?\d{4,}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})?/) != nil else {
            return nil
        }
        let hasTimezone = lexical.hasSuffix("Z") || lexical.wholeMatch(of: /.*[+-]\d{2}:\d{2}/) != nil
        if hasTimezone {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: lexical) { return (date, true) }
            formatter.formatOptions = [.withInternetDateTime]
            return formatter.date(from: lexical).map { ($0, true) }
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = lexical.contains(".") ? "yyyy-MM-dd'T'HH:mm:ss.SSS" : "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.date(from: lexical).map { ($0, false) }
    }
}
