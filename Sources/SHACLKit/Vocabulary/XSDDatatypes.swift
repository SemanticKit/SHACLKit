import IRIKit
import RDF
import struct RDFCore.Literal
import RDFCore
import RDFKit

/// The XML Schema 1.1 datatypes whose value spaces SHACL validation compares.
///
/// SHACL 1.2 Core §4.2.2 (`sh:datatype`) asks whether a literal is
/// well-formed for its datatype, and §4.4 (value range constraints) compares
/// literals by their values. Which literals are numbers, dates and times,
/// and the bounds of the derived integer datatypes, follow from XML Schema
/// 1.1 Part 2 §3.3 and §3.4.
@Ontology
struct XSDDatatypes: Ontology {
    var body: some Content {
        Namespace("http://www.w3.org/2001/XMLSchema#")

        Datatype("string") {
            Type(RDF.Datatype)
            Label("string")
            Comment("The datatype of character strings.")
        }
        Datatype("boolean") {
            Type(RDF.Datatype)
            Label("boolean")
            Comment("The datatype of the truth values true and false.")
        }
        Datatype("decimal") {
            Type(RDF.Datatype)
            Label("decimal")
            Comment("The datatype of decimal numbers.")
        }
        Datatype("integer") {
            Type(RDF.Datatype)
            Label("integer")
            Comment("The datatype of integers.")
        }
        Datatype("double") {
            Type(RDF.Datatype)
            Label("double")
            Comment("The datatype of IEEE double-precision 64-bit floating-point numbers.")
        }
        Datatype("nonNegativeInteger") {
            Type(RDF.Datatype)
            Label("nonNegativeInteger")
            Comment("The datatype of integers greater than or equal to zero.")
        }
        Datatype("float") {
            Type(RDF.Datatype)
            Label("float")
            Comment("The datatype of IEEE single-precision 32-bit floating-point numbers.")
        }
        Datatype("dateTime") {
            Type(RDF.Datatype)
            Label("dateTime")
            Comment("The datatype of instants: a date and a time of day, with an optional time zone.")
        }
        Datatype("date") {
            Type(RDF.Datatype)
            Label("date")
            Comment("The datatype of calendar dates, with an optional time zone.")
        }
        Datatype("long") {
            Type(RDF.Datatype)
            Label("long")
            Comment("The datatype of integers from -9223372036854775808 to 9223372036854775807.")
        }
        Datatype("int") {
            Type(RDF.Datatype)
            Label("int")
            Comment("The datatype of integers from -2147483648 to 2147483647.")
        }
        Datatype("short") {
            Type(RDF.Datatype)
            Label("short")
            Comment("The datatype of integers from -32768 to 32767.")
        }
        Datatype("byte") {
            Type(RDF.Datatype)
            Label("byte")
            Comment("The datatype of integers from -128 to 127.")
        }
        Datatype("nonPositiveInteger") {
            Type(RDF.Datatype)
            Label("nonPositiveInteger")
            Comment("The datatype of integers less than or equal to zero.")
        }
        Datatype("negativeInteger") {
            Type(RDF.Datatype)
            Label("negativeInteger")
            Comment("The datatype of integers less than zero.")
        }
        Datatype("positiveInteger") {
            Type(RDF.Datatype)
            Label("positiveInteger")
            Comment("The datatype of integers greater than zero.")
        }
        Datatype("unsignedLong") {
            Type(RDF.Datatype)
            Label("unsignedLong")
            Comment("The datatype of integers from 0 to 18446744073709551615.")
        }
        Datatype("unsignedInt") {
            Type(RDF.Datatype)
            Label("unsignedInt")
            Comment("The datatype of integers from 0 to 4294967295.")
        }
        Datatype("unsignedShort") {
            Type(RDF.Datatype)
            Label("unsignedShort")
            Comment("The datatype of integers from 0 to 65535.")
        }
        Datatype("unsignedByte") {
            Type(RDF.Datatype)
            Label("unsignedByte")
            Comment("The datatype of integers from 0 to 255.")
        }
    }
}
