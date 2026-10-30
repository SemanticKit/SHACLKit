import Foundation
import IRIKit
import RDF
import RDFCore
import RDFFormats
import struct RDFCore.Literal

/// The values of literals, as SHACL's constraints compare them.
extension Literal {
    /// A literal of `xsd:boolean`.
    init(_ value: Bool) {
        self = Literal(value ? "true" : "false", datatype: IRIKit.IRI(of: XSDDatatypes.booleanIndividual.self)!)
    }

    /// A literal of `xsd:integer`.
    init(_ value: Int) {
        self = Literal(String(value), datatype: IRIKit.IRI(of: XSDDatatypes.integerIndividual.self)!)
    }

    /// The literal's datatype IRI as RDF 1.2 Concepts §3.4 gives it:
    /// `rdf:dirLangString` for a directional language-tagged string,
    /// `rdf:langString` for any other language-tagged string, `xsd:string`
    /// for a simple literal, and ``datatype`` otherwise.
    private var datatypeIRI: IRI {
        if languageTag != nil {
            return IRIKit.IRI(of: baseDirection == nil ? RDF.langStringIndividual.self : RDF.dirLangStringIndividual.self)!
        }
        return datatype ?? IRIKit.IRI(of: XSDDatatypes.stringIndividual.self)!
    }

    /// The value of an `xsd:boolean` literal: its lexical space is `true`,
    /// `false`, `1` and `0` (XML Schema 1.1 Part 2 §3.3.2.1).
    var booleanValue: Bool? {
        guard datatypeIRI == IRIKit.IRI(of: XSDDatatypes.booleanIndividual.self)! else { return nil }
        switch lexicalForm {
        case "true", "1": return true
        case "false", "0": return false
        default: return nil
        }
    }

    /// Whether the literal is `true` of `xsd:boolean`: SHACL's boolean
    /// parameters are activated by `true` only, not by the other lexical
    /// form `1` of the same value.
    var isTrue: Bool { datatypeIRI == IRIKit.IRI(of: XSDDatatypes.booleanIndividual.self)! && lexicalForm == "true" }

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
        guard Self.integerDatatypes.contains(datatype) || datatype == IRIKit.IRI(of: XSDDatatypes.decimalIndividual.self)!
            || datatype == IRIKit.IRI(of: XSDDatatypes.doubleIndividual.self)! || datatype == IRIKit.IRI(of: XSDDatatypes.floatIndividual.self)! else { return nil }
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
        guard datatypeIRI == IRIKit.IRI(of: XSDDatatypes.dateTimeIndividual.self)! else { return nil }
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
        if datatype == IRIKit.IRI(of: XSDDatatypes.booleanIndividual.self)! { return booleanValue != nil }
        if datatype == IRIKit.IRI(of: XSDDatatypes.decimalIndividual.self)! { return lexical.wholeMatch(of: /[+-]?(\d+(\.\d*)?|\.\d+)/) != nil }
        if datatype == IRIKit.IRI(of: XSDDatatypes.doubleIndividual.self)! || datatype == IRIKit.IRI(of: XSDDatatypes.floatIndividual.self)! {
            return lexical.wholeMatch(of: /[+-]?((\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?|INF)|NaN/) != nil
        }
        if datatype == IRIKit.IRI(of: XSDDatatypes.dateTimeIndividual.self)! { return Self.dateTime(lexical) != nil }
        if datatype == IRIKit.IRI(of: XSDDatatypes.dateIndividual.self)! {
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
            IRIKit.IRI(of: XSDDatatypes.integerIndividual.self)!, IRIKit.IRI(of: XSDDatatypes.nonNegativeIntegerIndividual.self)!,
            IRIKit.IRI(of: XSDDatatypes.longIndividual.self)!, IRIKit.IRI(of: XSDDatatypes.intIndividual.self)!, IRIKit.IRI(of: XSDDatatypes.shortIndividual.self)!,
            IRIKit.IRI(of: XSDDatatypes.byteIndividual.self)!, IRIKit.IRI(of: XSDDatatypes.nonPositiveIntegerIndividual.self)!,
            IRIKit.IRI(of: XSDDatatypes.negativeIntegerIndividual.self)!, IRIKit.IRI(of: XSDDatatypes.positiveIntegerIndividual.self)!,
            IRIKit.IRI(of: XSDDatatypes.unsignedLongIndividual.self)!, IRIKit.IRI(of: XSDDatatypes.unsignedIntIndividual.self)!,
            IRIKit.IRI(of: XSDDatatypes.unsignedShortIndividual.self)!, IRIKit.IRI(of: XSDDatatypes.unsignedByteIndividual.self)!,
        ]
    }

    /// The value bounds of an integer datatype: `.some(nil)` for an
    /// unbounded one, `nil` for a datatype that is not an integer datatype.
    private static func integerBounds(of datatype: IRI) -> ClosedRange<Int>?? {
        switch datatype {
        case IRIKit.IRI(of: XSDDatatypes.integerIndividual.self)!: .some(nil)
        case IRIKit.IRI(of: XSDDatatypes.nonNegativeIntegerIndividual.self)!: 0...Int.max
        case IRIKit.IRI(of: XSDDatatypes.longIndividual.self)!: Int.min...Int.max
        case IRIKit.IRI(of: XSDDatatypes.intIndividual.self)!: -2_147_483_648...2_147_483_647
        case IRIKit.IRI(of: XSDDatatypes.shortIndividual.self)!: -32_768...32_767
        case IRIKit.IRI(of: XSDDatatypes.byteIndividual.self)!: -128...127
        case IRIKit.IRI(of: XSDDatatypes.nonPositiveIntegerIndividual.self)!: Int.min...0
        case IRIKit.IRI(of: XSDDatatypes.negativeIntegerIndividual.self)!: Int.min...(-1)
        case IRIKit.IRI(of: XSDDatatypes.positiveIntegerIndividual.self)!: 1...Int.max
        case IRIKit.IRI(of: XSDDatatypes.unsignedLongIndividual.self)!: 0...Int.max
        case IRIKit.IRI(of: XSDDatatypes.unsignedIntIndividual.self)!: 0...4_294_967_295
        case IRIKit.IRI(of: XSDDatatypes.unsignedShortIndividual.self)!: 0...65_535
        case IRIKit.IRI(of: XSDDatatypes.unsignedByteIndividual.self)!: 0...255
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
