import RDFCore
import RDFKit

/// The SHACL vocabulary: the shapes, constraint parameters, severities, node
/// kinds and constraint components SHACL 1.2 Core, SHACL 1.2 SPARQL and SHACL
/// 1.2 Rules define in the `sh:` namespace.
///
/// Each term is a Swift declaration: a class is a protocol, a property a term
/// type, and an individual (`sh:Violation`, `sh:IRI`,
/// `sh:MinCountConstraintComponent`) the one object of its class. Inside the
/// runtime the term is that declaration. Its IRI is read from its metadata
/// only where a shapes graph is decoded or a report leaves the runtime.
@Ontology
public struct SHACL: Ontology {
    public var body: some Content {
        Namespace("http://www.w3.org/ns/shacl#")

        Class("Shape") {
            Type(RDFS.Class)
            Label("Shape")
            Comment("A shape: a set of conditions that focus nodes are validated against.")
        }

        Class("NodeShape") {
            Type(RDFS.Class)
            SubClassOf(SHACL.Shape)
            Label("NodeShape")
            Comment("A shape that is not the subject of sh:path, whose conditions apply to the focus node itself.")
        }

        Class("PropertyShape") {
            Type(RDFS.Class)
            SubClassOf(SHACL.Shape)
            Label("PropertyShape")
            Comment("A shape with an sh:path, whose conditions apply to the value nodes the path reaches.")
        }

        Class("ShapeClass") {
            Type(RDFS.Class)
            Label("ShapeClass")
            Comment("A class that is also a node shape, whose instances are its implicit focus nodes.")
        }

        Class("Severity") {
            Type(RDFS.Class)
            Label("Severity")
            Comment("The class of severities a validation result can have.")
        }

        Class("NodeKind") {
            Type(RDFS.Class)
            Label("NodeKind")
            Comment("The class of node kinds: IRIs, blank nodes, literals and their combinations.")
        }

        Class("ConstraintComponent") {
            Type(RDFS.Class)
            Label("ConstraintComponent")
            Comment("The class of constraint components, which a validation result names as its source.")
        }

        Class("TripleRule") {
            Type(RDFS.Class)
            Label("TripleRule")
            Comment("A rule that infers triples from a subject, predicate and object node expression.")
        }

        Individual("Violation") {
            Type(SHACL.Severity)
            Label("Violation")
            Comment("The severity of a constraint violation.")
        }

        Individual("Warning") {
            Type(SHACL.Severity)
            Label("Warning")
            Comment("The severity of a warning.")
        }

        Individual("Info") {
            Type(SHACL.Severity)
            Label("Info")
            Comment("The severity of an informational result.")
        }

        Individual("IRI") {
            Type(SHACL.NodeKind)
            Label("IRI")
            Comment("The node kind of IRIs.")
        }

        Individual("Literal") {
            Type(SHACL.NodeKind)
            Label("Literal")
            Comment("The node kind of literals.")
        }

        Individual("BlankNode") {
            Type(SHACL.NodeKind)
            Label("BlankNode")
            Comment("The node kind of blank nodes.")
        }

        Individual("BlankNodeOrIRI") {
            Type(SHACL.NodeKind)
            Label("BlankNodeOrIRI")
            Comment("The node kind of blank nodes and IRIs.")
        }

        Individual("BlankNodeOrLiteral") {
            Type(SHACL.NodeKind)
            Label("BlankNodeOrLiteral")
            Comment("The node kind of blank nodes and literals.")
        }

        Individual("IRIOrLiteral") {
            Type(SHACL.NodeKind)
            Label("IRIOrLiteral")
            Comment("The node kind of IRIs and literals.")
        }

        Individual("this") {
            Label("this")
            Comment("The focus node, where a rule or expression names it.")
        }

        Individual("ClassConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("ClassConstraintComponent")
            Comment("The constraint component of sh:class.")
        }

        Individual("DatatypeConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("DatatypeConstraintComponent")
            Comment("The constraint component of sh:datatype.")
        }

        Individual("NodeKindConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("NodeKindConstraintComponent")
            Comment("The constraint component of sh:nodeKind.")
        }

        Individual("MinCountConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("MinCountConstraintComponent")
            Comment("The constraint component of sh:minCount.")
        }

        Individual("MaxCountConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("MaxCountConstraintComponent")
            Comment("The constraint component of sh:maxCount.")
        }

        Individual("MinExclusiveConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("MinExclusiveConstraintComponent")
            Comment("The constraint component of sh:minExclusive.")
        }

        Individual("MinInclusiveConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("MinInclusiveConstraintComponent")
            Comment("The constraint component of sh:minInclusive.")
        }

        Individual("MaxExclusiveConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("MaxExclusiveConstraintComponent")
            Comment("The constraint component of sh:maxExclusive.")
        }

        Individual("MaxInclusiveConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("MaxInclusiveConstraintComponent")
            Comment("The constraint component of sh:maxInclusive.")
        }

        Individual("MinLengthConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("MinLengthConstraintComponent")
            Comment("The constraint component of sh:minLength.")
        }

        Individual("MaxLengthConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("MaxLengthConstraintComponent")
            Comment("The constraint component of sh:maxLength.")
        }

        Individual("PatternConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("PatternConstraintComponent")
            Comment("The constraint component of sh:pattern.")
        }

        Individual("SingleLineConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("SingleLineConstraintComponent")
            Comment("The constraint component of sh:singleLine.")
        }

        Individual("LanguageInConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("LanguageInConstraintComponent")
            Comment("The constraint component of sh:languageIn.")
        }

        Individual("UniqueLangConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("UniqueLangConstraintComponent")
            Comment("The constraint component of sh:uniqueLang.")
        }

        Individual("EqualsConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("EqualsConstraintComponent")
            Comment("The constraint component of sh:equals.")
        }

        Individual("DisjointConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("DisjointConstraintComponent")
            Comment("The constraint component of sh:disjoint.")
        }

        Individual("LessThanConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("LessThanConstraintComponent")
            Comment("The constraint component of sh:lessThan.")
        }

        Individual("LessThanOrEqualsConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("LessThanOrEqualsConstraintComponent")
            Comment("The constraint component of sh:lessThanOrEquals.")
        }

        Individual("NotConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("NotConstraintComponent")
            Comment("The constraint component of sh:not.")
        }

        Individual("AndConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("AndConstraintComponent")
            Comment("The constraint component of sh:and.")
        }

        Individual("OrConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("OrConstraintComponent")
            Comment("The constraint component of sh:or.")
        }

        Individual("XoneConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("XoneConstraintComponent")
            Comment("The constraint component of sh:xone.")
        }

        Individual("NodeConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("NodeConstraintComponent")
            Comment("The constraint component of sh:node.")
        }

        Individual("QualifiedMinCountConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("QualifiedMinCountConstraintComponent")
            Comment("The constraint component of sh:qualifiedValueShape and sh:qualifiedMinCount.")
        }

        Individual("QualifiedMaxCountConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("QualifiedMaxCountConstraintComponent")
            Comment("The constraint component of sh:qualifiedValueShape and sh:qualifiedMaxCount.")
        }

        Individual("ClosedConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("ClosedConstraintComponent")
            Comment("The constraint component of sh:closed.")
        }

        Individual("HasValueConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("HasValueConstraintComponent")
            Comment("The constraint component of sh:hasValue.")
        }

        Individual("InConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("InConstraintComponent")
            Comment("The constraint component of sh:in.")
        }

        Individual("ExpressionConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("ExpressionConstraintComponent")
            Comment("The constraint component of sh:expression.")
        }

        Individual("NodeByExpressionConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("NodeByExpressionConstraintComponent")
            Comment("The constraint component of sh:nodeByExpression.")
        }

        Individual("ReifierShapeConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("ReifierShapeConstraintComponent")
            Comment("The constraint component of sh:reifierShape and sh:reificationRequired.")
        }

        Individual("MemberShapeConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("MemberShapeConstraintComponent")
            Comment("The constraint component of sh:memberShape.")
        }

        Individual("MinListLengthConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("MinListLengthConstraintComponent")
            Comment("The constraint component of sh:minListLength.")
        }

        Individual("MaxListLengthConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("MaxListLengthConstraintComponent")
            Comment("The constraint component of sh:maxListLength.")
        }

        Individual("UniqueMembersConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("UniqueMembersConstraintComponent")
            Comment("The constraint component of sh:uniqueMembers.")
        }

        Individual("SPARQLConstraintComponent") {
            Type(SHACL.ConstraintComponent)
            Label("SPARQLConstraintComponent")
            Comment("The constraint component of sh:sparql.")
        }

        Property("targetClass") {
            Type(RDF.Property)
            Label("targetClass")
            Comment("Each instance of the class, through rdf:type and rdfs:subClassOf, is a focus node of the shape.")
        }

        Property("targetNode") {
            Type(RDF.Property)
            Label("targetNode")
            Comment("The node is a focus node of the shape.")
        }

        Property("targetSubjectsOf") {
            Type(RDF.Property)
            Label("targetSubjectsOf")
            Comment("Each subject of a triple with the property is a focus node of the shape.")
        }

        Property("targetObjectsOf") {
            Type(RDF.Property)
            Label("targetObjectsOf")
            Comment("Each object of a triple with the property is a focus node of the shape.")
        }

        Property("targetWhere") {
            Type(RDF.Property)
            Label("targetWhere")
            Comment("Each node that conforms to the shape given is a focus node of the shape.")
        }

        Property("target") {
            Type(RDF.Property)
            Label("target")
            Comment("A target given by a SPARQL-based target definition.")
        }

        Property("shape") {
            Type(RDF.Property)
            Label("shape")
            Comment("A node of the data graph that names a shape it is a focus node of.")
        }

        Property("order") {
            Type(RDF.Property)
            Label("order")
            Comment("The relative order of a rule or a property shape.")
        }

        Property("deactivated") {
            Type(RDF.Property)
            Label("deactivated")
            Comment("Whether the shape is deactivated: a deactivated shape has no validation results.")
        }

        Property("severity") {
            Type(RDF.Property)
            Label("severity")
            Comment("The severity of the results the shape produces.")
        }

        Property("message") {
            Type(RDF.Property)
            Label("message")
            Comment("The message of the results the shape or SPARQL constraint produces.")
        }

        Property("property") {
            Type(RDF.Property)
            Label("property")
            Comment("A property shape whose conditions apply to the focus nodes of the shape.")
        }

        Property("path") {
            Type(RDF.Property)
            Label("path")
            Comment("The property path of a property shape.")
        }

        Property("inversePath") {
            Type(RDF.Property)
            Label("inversePath")
            Comment("The inverse of a path.")
        }

        Property("alternativePath") {
            Type(RDF.Property)
            Label("alternativePath")
            Comment("The list of paths any one of which is followed.")
        }

        Property("zeroOrMorePath") {
            Type(RDF.Property)
            Label("zeroOrMorePath")
            Comment("A path followed zero or more times.")
        }

        Property("oneOrMorePath") {
            Type(RDF.Property)
            Label("oneOrMorePath")
            Comment("A path followed one or more times.")
        }

        Property("zeroOrOnePath") {
            Type(RDF.Property)
            Label("zeroOrOnePath")
            Comment("A path followed zero or one times.")
        }

        Property("class") {
            Type(RDF.Property)
            Label("class")
            Comment("Each value node is an instance of the class.")
        }

        Property("datatype") {
            Type(RDF.Property)
            Label("datatype")
            Comment("Each value node is a literal with the datatype.")
        }

        Property("nodeKind") {
            Type(RDF.Property)
            Label("nodeKind")
            Comment("Each value node has the node kind.")
        }

        Property("minCount") {
            Type(RDF.Property)
            Label("minCount")
            Comment("The minimum number of value nodes.")
        }

        Property("maxCount") {
            Type(RDF.Property)
            Label("maxCount")
            Comment("The maximum number of value nodes.")
        }

        Property("minExclusive") {
            Type(RDF.Property)
            Label("minExclusive")
            Comment("Each value node is greater than the value.")
        }

        Property("minInclusive") {
            Type(RDF.Property)
            Label("minInclusive")
            Comment("Each value node is greater than or equal to the value.")
        }

        Property("maxExclusive") {
            Type(RDF.Property)
            Label("maxExclusive")
            Comment("Each value node is less than the value.")
        }

        Property("maxInclusive") {
            Type(RDF.Property)
            Label("maxInclusive")
            Comment("Each value node is less than or equal to the value.")
        }

        Property("minLength") {
            Type(RDF.Property)
            Label("minLength")
            Comment("The minimum string length of each value node.")
        }

        Property("maxLength") {
            Type(RDF.Property)
            Label("maxLength")
            Comment("The maximum string length of each value node.")
        }

        Property("pattern") {
            Type(RDF.Property)
            Label("pattern")
            Comment("A regular expression each value node matches.")
        }

        Property("flags") {
            Type(RDF.Property)
            Label("flags")
            Comment("The flags of the regular expression of sh:pattern.")
        }

        Property("singleLine") {
            Type(RDF.Property)
            Label("singleLine")
            Comment("Whether each value node is a string without line breaks.")
        }

        Property("languageIn") {
            Type(RDF.Property)
            Label("languageIn")
            Comment("The list of language ranges the language tag of each value node matches.")
        }

        Property("uniqueLang") {
            Type(RDF.Property)
            Label("uniqueLang")
            Comment("Whether no two value nodes share a language tag.")
        }

        Property("equals") {
            Type(RDF.Property)
            Label("equals")
            Comment("The values of the property are the value nodes.")
        }

        Property("disjoint") {
            Type(RDF.Property)
            Label("disjoint")
            Comment("No value of the property is a value node.")
        }

        Property("lessThan") {
            Type(RDF.Property)
            Label("lessThan")
            Comment("Each value node is less than each value of the property.")
        }

        Property("lessThanOrEquals") {
            Type(RDF.Property)
            Label("lessThanOrEquals")
            Comment("Each value node is less than or equal to each value of the property.")
        }

        Property("not") {
            Type(RDF.Property)
            Label("not")
            Comment("Each value node does not conform to the shape.")
        }

        Property("and") {
            Type(RDF.Property)
            Label("and")
            Comment("Each value node conforms to every shape of the list.")
        }

        Property("or") {
            Type(RDF.Property)
            Label("or")
            Comment("Each value node conforms to at least one shape of the list.")
        }

        Property("xone") {
            Type(RDF.Property)
            Label("xone")
            Comment("Each value node conforms to exactly one shape of the list.")
        }

        Property("node") {
            Type(RDF.Property)
            Label("node")
            Comment("Each value node conforms to the node shape.")
        }

        Property("nodeByExpression") {
            Type(RDF.Property)
            Label("nodeByExpression")
            Comment("Each value node conforms to each shape the node expression gives.")
        }

        Property("qualifiedValueShape") {
            Type(RDF.Property)
            Label("qualifiedValueShape")
            Comment("The shape that the qualified value nodes conform to.")
        }

        Property("qualifiedValueShapesDisjoint") {
            Type(RDF.Property)
            Label("qualifiedValueShapesDisjoint")
            Comment("Whether qualified value nodes must not conform to sibling qualified value shapes.")
        }

        Property("qualifiedMinCount") {
            Type(RDF.Property)
            Label("qualifiedMinCount")
            Comment("The minimum number of value nodes that conform to the qualified value shape.")
        }

        Property("qualifiedMaxCount") {
            Type(RDF.Property)
            Label("qualifiedMaxCount")
            Comment("The maximum number of value nodes that conform to the qualified value shape.")
        }

        Property("someValue") {
            Type(RDF.Property)
            Label("someValue")
            Comment("At least one value node conforms to the shape.")
        }

        Property("closed") {
            Type(RDF.Property)
            Label("closed")
            Comment("Whether the focus node has only the properties of the shape's property shapes.")
        }

        Property("ignoredProperties") {
            Type(RDF.Property)
            Label("ignoredProperties")
            Comment("The list of properties a closed shape also allows.")
        }

        Property("hasValue") {
            Type(RDF.Property)
            Label("hasValue")
            Comment("One of the value nodes is the value.")
        }

        Property("in") {
            Type(RDF.Property)
            Label("in")
            Comment("The list of values each value node is a member of.")
        }

        Property("expression") {
            Type(RDF.Property)
            Label("expression")
            Comment("A node expression whose output is true for each focus node.")
        }

        Property("reifierShape") {
            Type(RDF.Property)
            Label("reifierShape")
            Comment("The shape the reifiers of each value triple conform to.")
        }

        Property("reificationRequired") {
            Type(RDF.Property)
            Label("reificationRequired")
            Comment("Whether each value triple has a reifier.")
        }

        Property("memberShape") {
            Type(RDF.Property)
            Label("memberShape")
            Comment("The shape each member of each value node, a list, conforms to.")
        }

        Property("minListLength") {
            Type(RDF.Property)
            Label("minListLength")
            Comment("The minimum number of members of each value node, a list.")
        }

        Property("maxListLength") {
            Type(RDF.Property)
            Label("maxListLength")
            Comment("The maximum number of members of each value node, a list.")
        }

        Property("uniqueMembers") {
            Type(RDF.Property)
            Label("uniqueMembers")
            Comment("Whether no member of each value node, a list, occurs twice.")
        }

        Property("rule") {
            Type(RDF.Property)
            Label("rule")
            Comment("A rule of the shape.")
        }

        Property("condition") {
            Type(RDF.Property)
            Label("condition")
            Comment("A shape each focus node of a rule conforms to.")
        }

        Property("subject") {
            Type(RDF.Property)
            Label("subject")
            Comment("The node expression giving the subjects of a triple rule's triples.")
        }

        Property("predicate") {
            Type(RDF.Property)
            Label("predicate")
            Comment("The node expression giving the predicates of a triple rule's triples.")
        }

        Property("object") {
            Type(RDF.Property)
            Label("object")
            Comment("The node expression giving the objects of a triple rule's triples.")
        }

        Property("sparql") {
            Type(RDF.Property)
            Label("sparql")
            Comment("A SPARQL-based constraint of the shape.")
        }

        Property("select") {
            Type(RDF.Property)
            Label("select")
            Comment("The SPARQL SELECT query of a SPARQL-based constraint or target.")
        }

        Property("ask") {
            Type(RDF.Property)
            Label("ask")
            Comment("The SPARQL ASK query of a SPARQL-based constraint.")
        }

        Property("prefixes") {
            Type(RDF.Property)
            Label("prefixes")
            Comment("The prefix declarations a SPARQL query uses.")
        }

        Property("declare") {
            Type(RDF.Property)
            Label("declare")
            Comment("A prefix declaration.")
        }

        Property("prefix") {
            Type(RDF.Property)
            Label("prefix")
            Comment("The prefix of a prefix declaration.")
        }

        Property("namespace") {
            Type(RDF.Property)
            Label("namespace")
            Comment("The namespace of a prefix declaration.")
        }

        Property("union") {
            Type(RDF.Property)
            Label("union")
            Comment("The union of the outputs of the node expressions of the list.")
        }

        Property("intersection") {
            Type(RDF.Property)
            Label("intersection")
            Comment("The intersection of the outputs of the node expressions of the list.")
        }
    }
}
